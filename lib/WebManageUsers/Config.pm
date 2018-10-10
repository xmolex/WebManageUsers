package WebManageUsers::Config;
# библиотека для работы конфигом
# считаю, что singleton тут самое то, чтобы не плодить лишние объекты

use FindBin;
use Modern::Perl;
use utf8;
use Exporter 'import';
our @EXPORT = qw(config);
my $config;
my $config_path = "$FindBin::Bin/../web_manage_users.conf"; # путь к конфигурационному файлу


# получаем экземпляр подключения к базе
# возвращаем объект или ложь
sub config {
    # возвращаем объект, если уже есть подключение
    return $config if $config;
    
    # получаем хэш конфига
    $config = _get_config();
    
    # возвращаем объект
    return $config;
}

# получаем хэш с данными из конфига
sub _get_config {
    my $config;
    my $tmp = '';
    die qq{Can't load configuration from file "$config_path": 'file not found'} unless -f $config_path;
    open my $fh, "<:utf8", $config_path || die qq{Can't load configuration from file "$config_path": $!};
    $tmp .= $_ for <$fh>;
    close $fh;
    eval '$config = ' . $tmp . ';';
    die qq{Can't load configuration from file "$config_path": $@} if $@;
    die qq{Configuration file "$config_path" did not return a hash reference.\n} unless ref $config eq 'HASH';
    return $config;
}

1;
