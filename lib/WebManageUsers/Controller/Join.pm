package WebManageUsers::Controller::Join;
use Mojo::Base 'Mojolicious::Controller';
use WebManageUsers::DB;
use WebManageUsers::Model::Users;
use Mojo::JSON 'encode_json';
use Encode;

# This action will render a template
sub index {
    my $self = shift;
    $self->render();
}

sub join {
    my $self   = shift;
    my $error  = '';
    my $result = 0;
    my %json_answer;
    
    # получаем данные
    my $login = $self->param('login');
    my $pass  = $self->param('pass');
    
    # проверки
    if ( length($login) < 3 ) {
        $error = "логин должен быть не менее 3х символов";
    }
    elsif ( $login !~ /^[a-zA-Z]{1}/ ) {
        $error = "логин должен начинаться с латинской буквы";
    }
    
    if ( length($pass) < 3 ) {
        $error = "пароль должен быть не менее 3х символов";
    }

    if (!$error) {
        my $obj_user = WebManageUsers::Model::Users->new();
        ( $result, $error ) = $obj_user->create(
                                                     login => $login,
                                                     pass  => $pass
        );
    }

    if ($result) {
        $json_answer{result} = 1;
        $json_answer{error}  = $error;
    }
    else {
        $json_answer{result} = 0;
        $json_answer{error}  = $error;
    }
    
    # возвращаем json со статусом
    my $json = encode_json \%json_answer;
    Encode::_utf8_on($json);
    $self->render(json => $json);
}

1;
