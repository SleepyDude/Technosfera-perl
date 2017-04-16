package Local::SocialNetwork::User;

use strict;
use warnings;

use Local::DBconnector;
use utf8;
use DDP;
use Data::Dumper;
use feature qw(say);
use Mouse;

has id => (is => 'ro', isa => 'Num', required => 1);
has first_name => (is => 'ro', isa => 'Str', required => 1);
has last_name => (is => 'ro', isa => 'Str', required => 1);
has friends => (is => 'ro', required => 0);

sub get_by_id {
	my $self = shift;
	my $id = shift;
	my $dbh = Local::DBconnector->get();
	my $sth = $dbh->prepare(
		'SELECT * FROM users WHERE id = ?'
	);
	$sth->execute($id);
	my $usr = $sth->fetchrow_hashref();

	$sth = $dbh->prepare(
		'SELECT * FROM relations WHERE user_id_1 = ?'
	);
	$sth->execute($id);
	my $friends = $sth->fetchall_hashref('user_id_2');
	my @fr = keys %{ $friends };
	$dbh->disconnect();
	return $self->new(
		id => $id,
		first_name => $usr->{firstname},
		last_name => $usr->{lastname},
		friends => \@fr,
	);
}

sub get_friends {
	my $self = shift;
	return $self->{friends};
}

sub get_full_name {
	my $self = shift;
	return $self->{first_name} . " " . $self->{last_name};
}

sub get {
	my $self = shift;
	my $h;
	$h->{id} = $self->{id};
	$h->{full_name} = $self->get_full_name();
	return $h;
}

sub get_loners {
	my $pkg = shift;

	my $dbh = Local::DBconnector->get();
	my $sth = $dbh->prepare(
		'SELECT * FROM users WHERE id NOT IN (SELECT user_id_1 FROM relations)'
	);
	$sth->execute();
	my $loners = $sth->fetchall_hashref('id') || '';
	$dbh->disconnect();
	return $loners;
}

sub get_friends_by_list {
	my $pkg = shift;
	my $id_YY = shift;
	my @list = @_;
	my %h;
	my $dbh = Local::DBconnector->get();

	foreach (@list) {
		my $id = $_;
		my $sth = $dbh->prepare(
			'SELECT user_id_2 FROM relations WHERE user_id_1 = ?'
		);
	    $sth->execute($id);
	    my @res = map { $_->[0] } @{ $sth->fetchall_arrayref() };
	    foreach (@res) {
	    	$h{$_} = 1;
	    	if ($id_YY == $_) {
	    		$dbh->disconnect();
	    		return [ keys %h ];
	    	}
	    }
	}
    $dbh->disconnect();
    return [ keys %h ];
}

1;