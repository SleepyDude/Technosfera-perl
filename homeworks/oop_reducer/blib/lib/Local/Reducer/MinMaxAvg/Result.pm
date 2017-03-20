package Local::Reducer::MinMaxAvg::Result;

use strict;
use warnings;
use parent 'Local::Reducer';
use Scalar::Util qw(looks_like_number);

=encoding utf8

=head1 NAME

Local::Reducer::MaxDiff - Result class for MinMaxAvg

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new {
	my ($class, %params) = @_;
	%params = (min => 0, max => 0, sum => 0, count => 0, avg => 0);
	return bless \%params, $class;
}

sub set_item {
	my $self = shift;
	self->{min} = $_[0] if self->{min} > $_[0];
	self->{max} = $_[0] if self->{max} < $_[0];
	self->{sum} += $_[0];
	self->{count} += 1;
}

sub get_min {
	my $self = shift;
	return $self->{min};
}

sub get_max {
	my $self = shift;
	return $self->{max};
}

sub get_avg {
	my $self = shift;
	return $self->{avg};
}

1;