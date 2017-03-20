package Local::Row::JSON;

use strict;
use warnings;
use JSON::XS;
use parent 'Local::Row';

=encoding utf8

=head1 NAME

Local::Row::JSON - JSON row class

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new {
	my ($class, %params) = @_;
	my $log;
	my $valid = eval { $log = JSON::XS->new->utf8->decode($params{str}); 1 };
	if ($valid) { 
		$log = JSON::XS->new->utf8->decode($params{str});
		return undef if (ref $log ne 'HASH');
	} else {
		return undef;
	}
	my %res = ('log',$log);
	return bless \%res, $class;
}

1;