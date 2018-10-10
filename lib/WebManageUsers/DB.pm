package WebManageUsers::DB;
# библиотека для работы с базой postgresql
# считаю, что singleton тут самое то, чтобы не плодить лишние объекты

use FindBin;
use Modern::Perl;
use utf8;
use DBI;
use WebManageUsers::Config;
use Exporter 'import';
our @EXPORT = qw(db);
my $conn;



# получаем экземпляр подключения к базе
# возвращаем объект или ложь
sub db {
    # возвращаем объект, если уже есть подключение
    return $conn if $conn;
    
    # если подключения нет, то вызвращаем ложь
    return unless _toconnect();
    
    # возвращаем объект
    return $conn;
}

# подключаемся к базе
sub _toconnect {
    my $config = config(); # получаем данные для подключения
    if ($config->{db}->{socket}) {
        # подключаемся через unix socket
        $conn = DBI->connect("dbi:Pg:dbname=$config->{db}->{name};host=$config->{db}->{socket}",
                              "$config->{db}->{user}",
                              "$config->{db}->{pass}",
                              {AutoCommit => 1, PrintError => 1, RaiseError => 0}
        );
    }
    else {
        # подключаемся через tcp/ip
        $conn = DBI->connect("dbi:Pg:dbname=$config->{db}->{name};host=$config->{db}->{host};port=$config->{db}->{port};",
                              "$config->{db}->{user}",
                              "$config->{db}->{pass}",
                              {AutoCommit => 1, PrintError => 1, RaiseError => 0}
        );
    }
    if ($conn) {
        # подключение удалось, устанавливаем utf-8 флаги
        $conn->{pg_enable_utf8} = 1;
        $conn->do("SET CLIENT_ENCODING TO 'UTF8';");
        return 1;
    }
    else {
        die "Don't connect database: '\"dbi:Pg:dbname=$config->{db}->{name};host=$config->{db}->{host}'\n";
    }
}

1;
