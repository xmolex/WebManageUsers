package WebManageUsers::Controller::Login;
use Mojo::Base 'Mojolicious::Controller';
use WebManageUsers::DB;
use WebManageUsers::Model::Users;
use Mojo::JSON 'encode_json';
use Encode;

sub index {
    my $self = shift;
    $self->render();
}

sub login {
    my $self = shift;
    my %json_answer;
    
    # получаем данные
    my $login = $self->param('login');
    my $pass  = $self->param('pass');
    
    # проверки
    if ( !$login || !$pass ) {
        $json_answer{result} = 0;
    }
    else {
        # проводим авторизацию
        my $obj_user = WebManageUsers::Model::Users->new();
        if ( $obj_user->auth_by_pass( $login, $pass ) ) {
            $json_answer{result} = 1;
        
            # сохраняем cookie
            $self->cookie( $self->cookie_name() => $obj_user->sess(), {expires => time + 3600} );
        }
        else {
            $json_answer{result} = 0;
        }
    }

    # возвращаем json со статусом
    my $json = encode_json \%json_answer;
    Encode::_utf8_on($json);
    $self->render(json => $json);
}

1;
