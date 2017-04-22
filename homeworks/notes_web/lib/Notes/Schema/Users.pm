package Notes::Schema::Users;

use Notes::DBconnector;
use Exporter 'import';
use DDP;

my $dbc = Notes::DBconnector->instance();
my $dbh = $dbc->{ DB };

sub get_user_by_name {
	my $username = shift;

    my $sth = $dbh->prepare( 'SELECT * FROM users WHERE username = ?' );
	$sth->execute($username);

	my $user = $sth->fetchrow_hashref() || '';
	return $user;
}

sub create_user {
	my ($username, $password) = @_;

	my $sth = $dbh->prepare( 'INSERT INTO users (username, passwd) VALUES (?, ?)' );
	$sth->execute($username, $password);
	$dbh->commit;
}

sub filter_users {
	my @list = @_;
	
	my $sth = $dbh->prepare(
		'SELECT users.username FROM users WHERE username = ?' .
		' OR username = ?'x(scalar @list - 1)
	);
    $sth->execute(@list);
    my @users = map { $_->[0] } @{ $sth->fetchall_arrayref() };
  
    return @users;	
}

our @EXPORT = qw(get_user_by_name create_user filter_users);

1;