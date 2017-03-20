package Local::Row;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Row - base abstract row

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub get {
	my ($self, $name, $default) = @_;
	my %log = %{ $self->{'log'} };
	if (exists $log{$name}) {
		return $log{$name};
	} else {
		return $default;
	}
}

1;