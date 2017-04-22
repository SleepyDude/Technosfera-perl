package Notes::Login;
use Mojo::Base 'Mojolicious::Controller';
use DDP;
use Digest::MD5 'md5_hex';
use feature qw(say);

use Notes::Schema::Users;

sub get_user {
	my $username = shift;

	my $user = get_user_by_name($username);
	return $user;
}

sub on_user_login {
	my $self = shift;

	my $validation = $self->validation;
		return $self->render(text => 'Bad CSRF token!', status => 403)
			if $validation->csrf_protect->has_error('csrf_token');
	my $input   = $validation->input;

	if (!$input->{username} || !$input->{password}) {
		$self->redirect_to('/login')
	} else {
		my $dbh = Notes::DBconnector->instance()->{ DB };
		my $username = $self->param('username');
		my $password = md5_hex( $self->param('password') );

		my $user = get_user($username);

		if ($user) {
			if ($user->{passwd} eq $password) {
				$self->session(logged_in => 1);
		        $self->session(username => $username);
		        $self->redirect_to('restricted_area');
		    } else {
		    	$self->render(
		    		template => 'info/user_exist', 
		    		status => 403
		    	);
		    }
		} else {
			$self->session(logged_in => 1);
		    $self->session(username => $username);
			create_user($username, $password);
	        $self->render(name => $username, status => 200, template => 'info/create_new');
	    }
	}
}

sub is_logged_in {
    my $self = shift;

    return 1 if $self->session('logged_in');

    $self->render(
        template => 'info/not_login', 
        status => 403
    );
}

sub logout {
	my $self = shift;
	$self->session(expires => 1);
	$self->redirect_to('/');
}

1;