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
	my $dbh = Local::DBconnector->instance()->{ DB };
	my $sth = $dbh->prepare(
		'SELECT users.id, users.firstname, users.lastname, relations.user_id_2 from users INNER JOIN 
		relations ON users.id = relations.user_id_1 WHERE id = ?'
	);
	$sth->execute($id);
	my $usr = $sth->fetchrow_hashref();
	my @fr = map { $_->[3] } @{ $sth->fetchall_arrayref() };
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

	my $dbh = Local::DBconnector->instance()->{ DB };
	my $sth = $dbh->prepare(
		'SELECT * FROM users WHERE id NOT IN (SELECT user_id_1 FROM relations)'
	);
	$sth->execute();
	my $loners = $sth->fetchall_hashref('id') || '';
	return $loners;
}

sub get_friends_by_list {
	my $pkg = shift;
	my $id_YY = shift;
	my @list = @_;
	my %h;
	my $chunk_num = 1000;
	my @chunks = group_by ($chunk_num, @list);
	my $dbh = Local::DBconnector->instance()->{ DB };
	foreach (@chunks) {
		my @chunk = @{ $_ };
		my $sth = $dbh->prepare(
			'SELECT * FROM users INNER JOIN relations ON users.id = relations.user_id_1 WHERE user_id_1 = ?' .
			' OR user_id_1 = ?'x(scalar @chunk - 1)
		);
	    $sth->execute(@chunk);
	    my @res = map { $_->[4] } @{ $sth->fetchall_arrayref() };
	    foreach (@res) {
	    	$h{$_} = 1;
	    	return [ keys %h ] if $id_YY == $_;
	    }
	}
    return [ keys %h ];
}

sub group_by {
	my $n = shift;
	my @array = @_;

	my @groups;
	push @groups, [ splice @array, 0, $n ] while @array;

	return @groups;
}

sub has_friends {
	my $pkg = shift;
	my $id = shift;
	my $dbh = Local::DBconnector->instance()->{ DB };
	my $sth = $dbh->prepare(
		'SELECT relations.user_id_2 FROM relations WHERE user_id_1 = ?'
	);
	$sth->execute($id);
	my @fr = map { $_->[0] } @{ $sth->fetchall_arrayref() };
	return 1 if scalar @fr;
	return 0;
}

1;