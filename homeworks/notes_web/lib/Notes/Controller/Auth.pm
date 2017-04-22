package Notes::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';

sub login_form {
	my $self = shift;
	$self->render();
}

1;