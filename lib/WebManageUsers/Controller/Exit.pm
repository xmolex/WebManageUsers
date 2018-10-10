package WebManageUsers::Controller::Exit;
use Mojo::Base 'Mojolicious::Controller';
use WebManageUsers::DB;
use WebManageUsers::Model::Users;


sub exit {
    my $self = shift;
  
    # чистим куки от сессии
    $self->cookie( $self->cookie_name() => 0, { expires => -1 } );

    # переходим на исходную страницу
    $self->redirect_to("/");
}

1;
