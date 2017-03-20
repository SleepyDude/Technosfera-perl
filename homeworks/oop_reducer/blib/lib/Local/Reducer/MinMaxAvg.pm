package Local::Reducer::MinMaxAvg;

use strict;
use warnings;
use parent 'Local::Reducer';
use Scalar::Util qw(looks_like_number);

=encoding utf8

=head1 NAME

Local::Reducer::MaxDiff - MinMaxAvg reducer class

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub reduce_n {
	my ($self, $n) = @_;
	my ($source, $row_class, $field) = @{$self}{qw(source row_class field)};
	$self->{reduced} = 'Local::Reducer::MinMaxAvg::Result'->new();
	for (1..$n) {
		my $string = $source->next();
		my $row = $row_class->new(str => $string);
		if (looks_like_number($row->get($field, 0))) {
			$self->{reduced}->set_item($row->get($field, 0));
		}
	}
	return $self->{reduced};
}

sub reduce_all {
	my $self = shift;
	my ($source, $row_class, $field) = @{$self}{qw(source row_class field)};
	$self->{reduced} = 'Local::Reducer::MinMaxAvg::Result'->new();
	while (defined (my $string = $source->next())) {
		my $row = $row_class->new(str => $string); 
		if (looks_like_number($row->get($field, 0))) {
			$self->{reduced}->set_item($row->get($field, 0));
		}
	}
	return $self->{reduced};
}

sub reduced {
  my $self = shift;
  return $self->{reduced};
}

1;