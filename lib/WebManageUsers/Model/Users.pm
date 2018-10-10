package WebManageUsers::Model::Users;
################################################################################
#  Управление пользователями
################################################################################
use Modern::Perl;
use utf8;
use Digest::MD5;
use WebManageUsers::DB;
use parent "WebManageUsers::Model::Users::Crypt";

my %SESSION;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub get {
    my ($self, $id) = @_;
    return if $id !~ /^\d+$/; # неверные данные
    return 1 if $self->{id};  # данные уже извлечены из базы
    
    # получаем данные из базы
    my $strin = db->prepare( qq{
          SELECT u.id, u.login, u.last_time, s.salt
            FROM users u 
          LEFT OUTER JOIN users_salt s ON s.id = u.id
            WHERE u.id = ?;
    } );
    $strin->execute($id);
    my @values = $strin->fetchrow_array;
    $strin->finish;
    return unless defined $values[0];
    
    # заполняем
    $self->{id}        = $values[0];
    $self->{login}     = $values[1];
    $self->{last_time} = $values[2];
    $self->{salt}      = $values[3];
    
    return 1;
}

# регистрируем пользователя
sub create {
    my $self = shift;
    my $param = {@_};
    
    # проверяем доступность логина
    return( 0, "логин занят" ) if _login_exists( $param->{login} ); # логин занят
    
    # регистрируем
    my $salt       = __PACKAGE__->_gen_salt(); # генерируем соль
    $param->{pass} = __PACKAGE__->_crypt_pass( $param->{pass}, $salt ); # получаем хэшь пароля с солью
    
    # записываем пользователя и получаем его id
    my $strin = db->prepare("INSERT INTO users ( login, pass ) VALUES ( ?, ? ) RETURNING id");
    $strin->execute( $param->{login}, $param->{pass} );
    my @values = $strin->fetchrow_array;
    $strin->finish;
    return( 0, "ошибка базы данных, попробуйте позднее" ) unless defined $values[0];
    my $user_id = $values[0];
    
    # сохраняем соль пользователя
    db->do( "INSERT INTO users_salt ( id, salt ) VALUES ( ?, ? );", undef, $user_id, $salt );
    
    # получаем данные
    !$self->get($user_id) ? return : return 1;
}

# авторизируем пользователя по логину и паролю, возвращаем ложь или истину при удаче
sub auth_by_pass {
    my ( $self, $form_login, $form_pass ) = @_;
    return if (!defined $form_login || !defined $form_pass);
    
    # ищем в базе по логину, заодно получаем соль пользователя
    my $strin = db->prepare( qq{
                                   SELECT u.id, u.pass, s.salt 
                                     FROM users u 
                                     LEFT OUTER JOIN users_salt s ON s.id = u.id
                                   WHERE u.login = ?;
    } );
    $strin->execute($form_login);
    my @values = $strin->fetchrow_array;
    $strin->finish;
    return unless $values[0];
    
    my $user_id   = $values[0];
    my $user_pass = $values[1];
    my $user_salt = $values[2];
    $form_pass = __PACKAGE__->_crypt_pass( $form_pass, $user_salt ); # получаем хэшь пароля с солью
    
    # проверяем пароль
    return if $user_pass ne $form_pass;
    
    # данные верны, пользователь авторизован
    # генерируем новую сессию
    my $sess = __PACKAGE__->_gen_sess();
    db->do( "INSERT INTO users_sess (sess,user_id) VALUES ( ?, ? );", undef, $sess, $user_id );
    $self->{sess} = $sess;
    
    # меняем время последней авторизации
    db->do( "UPDATE users SET last_time=now() WHERE id = ?;", undef, $user_id );
    
    # получаем данные
    return unless $self->get($user_id);

    return 1;
}

# авторизируем пользователя по сессии, возвращаем ложь или ссылку на объект с заполненными данными
sub auth_by_sess {
    my ( $self, $sess ) = @_;
    return unless defined $sess;
    return if ($sess !~ /^[a-zA-Z0-9]+$/);

    # проверяем кеширование
    if (exists $SESSION{$sess}) {
        # сессия уже есть, можно отдать
        return $SESSION{$sess};
    }
    
    # ищем в базе
    my $strin = db->prepare("SELECT user_id FROM users_sess WHERE sess = ?;");
    $strin->execute($sess);
    my @values = $strin->fetchrow_array;
    $strin->finish;
    return unless defined $values[0];
    
    # получаем информацию
    $SESSION{$sess} = $self;
    !$self->get($values[0]) ? return : return $SESSION{$sess};
}

# аксессоры
sub id        { return shift->{id}; }
sub login     { return shift->{login}; }
sub last_time { return shift->{last_time}; }
sub salt      { return shift->{salt}; }
sub sess      { return shift->{sess}; }


# проверяем доступность логина и возвращаем идентификатор, либо ложь
sub _login_exists {
    my $login = shift;
    my $strin = db->prepare("SELECT id FROM users WHERE login = ?;");
    $strin->execute($login);
    my @values = $strin->fetchrow_array;
    $strin->finish;
    $values[0] ? return $values[0] : return;
}

1;
