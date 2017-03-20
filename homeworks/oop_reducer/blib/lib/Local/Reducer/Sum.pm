package Local::Reducer::Sum;

use strict;
use warnings;
use parent 'Local::Reducer';
use Scalar::Util qw(looks_like_number);

=encoding utf8

=head1 NAME

Local::Reducer::Sum - Sum reducer class

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub reduce_n {
	my ($self, $n) = @_;
	my ($source, $row_class, $res, $field) = @{$self}{qw(source row_class reduced field)};
	for (1..$n) {
		my $string = $source->next();
		my $row = $row_class->new(str => $string);
		if (defined $row and looks_like_number($row->get($field, 0))) {
			$res += $row->get($field, 0);
		}
	}
	$self->{reduced} = $res;
	return $res;
}

sub reduce_all {
	my $self = shift;
	my ($source, $row_class, $res, $field) = @{$self}{qw(source row_class reduced field)};
	while (defined (my $string = $source->next())) {
		my $row = $row_class->new(str => $string);
		if (defined $row and looks_like_number($row->get($field, 0))) {
			$res += $row->get($field, 0);
		}
	}
	$self->{reduced} = $res;
	return $res;
}

sub reduced {
  my $self = shift;
  return $self->{reduced};
}

1;