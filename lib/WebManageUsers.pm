package WebManageUsers;
use Mojo::Base 'Mojolicious';

use Modern::Perl;
use utf8;
use WebManageUsers::DB;
use WebManageUsers::Model::Users;

sub startup {
    my $self = shift;

    my $config = $self->plugin('Config');
    
    # авторизационные данные в шаблоне
    $self->hook( before_render => sub {
        my ($c, $args) = @_;
        $args->{auth_id}   = $c->stash->{auth_id};
        $args->{auth_name} = $c->stash->{auth_name};
    });
    
    # устанавливаем авторизационные данные в stash
    $self->hook( before_dispatch => sub {
		    my ($self) = @_;
		    my ( $auth_id, $auth_name ) = $self->auth;
		    $self->stash( auth_id   => $auth_id );
		    $self->stash( auth_name => $auth_name );
	  });
    
    # роуты
    my $r = $self->routes;
    $r->get('/')->to('index#index');
    $r->get('/join')->via('get')->to('join#index');
    $r->get('/join')->via('post')->to('join#join');
    $r->get('/login')->via('get')->to('login#index');
    $r->get('/login')->via('post')->to('login#login');
    $r->get('/profile')->to('profile#index');
    $r->get('/exit')->to('exit#exit');
    
    # возвращает параметр cookie для авторизации
    $self->helper(
        cookie_name => sub {
            return $config->{'cookie_name'};
        }
    );
  
    # возвращает id пользователя и логин при авторизации по сессии пользователя
    $self->helper(
        auth => sub {
            my $self = shift;
            my $obj = WebManageUsers::Model::Users->new();
            # производим авторизацию
            $obj = $obj->auth_by_sess( $self->cookie( $self->cookie_name() ) );
            if ( $obj ) {
                return( $obj->id, $obj->login );
            }
            else {
                return( 0, 'Гость' );
            }
        }
    );

}




1;
