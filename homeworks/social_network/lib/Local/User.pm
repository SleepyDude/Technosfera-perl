package Local::User;

use strict;
use warnings;

use Local::DBconnector;
use utf8;
use DDP;
use Data::Dumper;
use feature qw(say);
use Exporter 'import';
use Mouse;

has id   => (is => 'ro', isa => 'Num', required => 1);
has first_name  => (is => 'ro', isa => 'Str', required => 1);
has last_name => (is => 'ro', isa => 'Str', required => 1);
has friends => (is => 'ro', required => 0);



# sub new {
# 	my ($pkg, %params) = @_;
# 	my $self = bless {}, $pkg;
# 	# $self->{id} = $params{id};
# 	# $self->{first_name} = $params{first_name};
# 	# $self->{last_name} = $params{last_name};
# 	# $self->{friends} = $params{friends};
# }

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
	# print Dumper($friends);
	$dbh->disconnect();
	# $self->{id} = $id;
	# $self->{first_name} = $usr->{firstname};
	# $self->{last_name} = $usr->{lastname};
	# $self->{friends} = \@fr;
	return $self->new(
        id   => $id,
        first_name  => $usr->{firstname},
        last_name => $usr->{lastname},
        friends => \@fr,
    );
}

our @EXPORT = qw(get_by_id);

1;