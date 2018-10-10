package WebManageUsers::Model::Users::Crypt;
################################################################################
#  Управление пользователями: шифрование
################################################################################
use Modern::Perl;
use utf8;
use Crypt::Random;
use Crypt::Eksblowfish::Bcrypt;
use WebManageUsers::DB;
use WebManageUsers::Config;

# расчитываем хэш пароля
sub _crypt_pass {
    my ( $self, $pass, $salt ) = @_;
    $pass = Crypt::Eksblowfish::Bcrypt::bcrypt_hash( {
            key_nul => 1,
            cost => 8,
            salt => substr $salt . _get_perm_salt(), 0, 16,
        }, $pass);
    return Crypt::Eksblowfish::Bcrypt::en_base64($pass);
}

# генерируем сессию
sub _gen_sess {
   my @sess = ("A".."Z","a".."z",0..9);
   return join( "", @sess[map { rand @sess } (1..50) ] );
}

# возвращаем статическую соль из конфига проекта
sub _get_perm_salt {
    my $config = config();
    return ${ $config->{secrets} }[0];
}

# генерируем соль
sub _gen_salt {
    my $salt = Crypt::Eksblowfish::Bcrypt::en_base64(Crypt::Random::makerandom_octet(Length=>16));
    $salt = substr $salt, 0, 10;
    return $salt;
}

1;
