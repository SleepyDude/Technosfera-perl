package Notes::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';
use Notes::Schema::Notes;

sub welcome {
	my $self = shift;
}

sub notes {
	my $self = shift;

	my $notes = get_notes_by_username($self->session('username'));
	my @n = map { $notes->{$_} } sort keys %{ $notes } ;
	$self->render(notes => \@n, title => 'Notes');
}

sub note_form {
	my $self = shift;
}

sub mynotes {
	my $self = shift;

	my $notes = get_notes_by_author($self->session('username'));
	my @n = map { $notes->{$_} } sort keys %{ $notes } ;
	$self->render(notes => \@n, title => 'My notes', template => 'main/notes');
}

1;
