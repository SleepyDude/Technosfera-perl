package Notes;
use Mojo::Base 'Mojolicious';

use Mojolicious::Plugin::Database;
use JSON::XS;
use DDP;

sub startup {
	my $self = shift;

	$self->secrets(['F?l@CG|Bf2sn14v', 'e6rb~!6pi^5A<ph']);

    $self->app->sessions->cookie_name('notes');

	# Load configuration from hash returned by "my_app.conf"
	my $config = $self->plugin('Config');

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer') if $config->{perldoc};

	# Router
	my $r = $self->routes;

	$r->get('/')->to('main#welcome');

	$r->get('/login')->to('auth#login_form');
	$r->post('/login')->name('do_login')->to('Login#on_user_login');

	my $authorized = $r->under('/')->to('Login#is_logged_in');

	$authorized->get('/notes')->name('restricted_area')->to('main#notes');
	$authorized->get('/mynotes')->name('restricted_area')->to('main#mynotes');

	$authorized->get('/create_note')->to('main#note_form');
	$authorized->post('/create_note')->name('do_note')->to('Note#create_note');

	$r->get('/logout')->name('do_logout')->to('Login#logout');
}

1;
