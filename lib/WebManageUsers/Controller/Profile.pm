package WebManageUsers::Controller::Profile;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;
  $self->render( msg => $self->stash('auth_name') );
}

1;
