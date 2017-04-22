package Notes::Note;
use Mojo::Base 'Mojolicious::Controller';
use DDP;
use feature qw(say);

use Notes::Schema::Web_notes;

use Notes::DBconnector;
my $dbc = Notes::DBconnector->instance();
my $dbh = $dbc->{ DB };


sub create_note {
	my $self = shift;
	my $u = $self->param('users');
	my @users = $u =~ /\b(.+?)\b/g;

	my $username = $self->session('username');
	my $title = $self->param('title');
	my $text = $self->param('text');
	if ($title && $text) {
		create_post( $username, $title, $text, @users);
	}

	$self->redirect_to('restricted_area');
}

1;