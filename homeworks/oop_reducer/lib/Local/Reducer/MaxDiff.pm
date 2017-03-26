package Local::Reducer::MaxDiff;

use strict;
use warnings;
use parent 'Local::Reducer';
use Scalar::Util qw(looks_like_number);

=encoding utf8

=head1 NAME

Local::Reducer::MaxDiff - MaxDiff reducer class

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub reduce_n {
	my ($self, $n) = @_;
	my ($source, $row_class, $res, $top, $bottom) = @{$self}{qw(source row_class reduced top bottom)};
	for (1..$n) {
		my $string = $source->next();
		my $row = $row_class->new(str => $string);
		if (looks_like_number($row->get($top, 0)) and looks_like_number($row->get($bottom, 0))) {
			my $diff = $row->get($top, 0) - $row->get($bottom, 0);
			$res = $diff if ($diff > $res);
		}
	}
	$self->{reduced} = $res;
	return $res;
}

sub reduce_all {
	my $self = shift;
	my ($source, $row_class, $res, $top, $bottom) = @{$self}{qw(source row_class reduced top bottom)};
	while (defined (my $string = $source->next())) {
		my $row = $row_class->new(str => $string); 
		if (looks_like_number($row->get($top, 0)) and looks_like_number($row->get($bottom, 0))) {
			my $diff = $row->get($top, 0) - $row->get($bottom, 0);
			$res = $diff if ($diff > $res);
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