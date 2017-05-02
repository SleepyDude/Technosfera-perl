package Notes::Schema::Notes;

use Notes::DBconnector;
use Notes::Schema::Users;
use Exporter 'import';

my $dbc = Notes::DBconnector->instance();
my $dbh = $dbc->{ DB };

use DDP;

sub create_post {
	my ($author, $title, $text, @users) = @_;

	my $sth = $dbh->prepare( 'INSERT INTO notes (author, title, text) VALUES (?, ?, ?)' );
	$sth->execute($author, $title, $text);

	my $sth = $dbh->prepare( 'SELECT id FROM notes ORDER BY id DESC LIMIT 1' );
	$sth->execute();
	my $note_id = $sth->fetchrow_hashref()->{id};

	# filter shared users
	my @sh_users = filter_users(@users);
	# add author to shared users
	push @sh_users, $author;
	#prepare data to insert
	@data = map { $_, $note_id } @sh_users;

	my $sth = $dbh->prepare( 
		'REPLACE INTO relations (username, note_id) VALUES' .
		'(?, ?),'x(scalar @data / 2 - 1) . ' (?, ?)'
	);
	$sth->execute(@data);
	
	$dbh->commit;
}

sub get_notes_by_username {
	my $username = shift;

	my $sth = $dbh->prepare( 
		'SELECT notes.*, relations.username AS sharedUsers FROM relations r 
		INNER JOIN notes ON notes.id = r.note_id 
		INNER JOIN relations ON r.note_id = relations.note_id 
		WHERE r.username = ?' 
	);
	$sth->execute($username);
	my $res = $sth->fetchall_arrayref({});
	my %notes;
	my @sh;
	foreach my $note (@{ $res }) {
		push @{ $notes{ $note->{id} }->{sharedUsers} }, $note->{sharedUsers};
		$notes{ $note->{id} }->{author} = $note->{author};
		$notes{ $note->{id} }->{text} = $note->{text};
		$notes{ $note->{id} }->{title} = $note->{title};
	}
	return \%notes;
}

sub get_notes_by_author {
	my $author = shift;

	my $sth = $dbh->prepare( 
		'SELECT * FROM notes
		INNER JOIN relations ON notes.id = relations.note_id
		WHERE author = ?' 
	);
	$sth->execute($author);
	my %notes;
	my $res = $sth->fetchall_arrayref({});
	foreach my $note (@{ $res }) {
		push @{ $notes{ $note->{id} }->{sharedUsers} }, $note->{username};
		$notes{ $note->{id} }->{author} = $note->{author};
		$notes{ $note->{id} }->{text} = $note->{text};
		$notes{ $note->{id} }->{title} = $note->{title};
	}
	return \%notes;
}

our @EXPORT = qw(create_post get_notes_by_username get_notes_by_author);

1;