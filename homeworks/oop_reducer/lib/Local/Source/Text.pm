package Local::Source::Text;

use strict;
use warnings;
use parent 'Local::Source';

=encoding utf8

=head1 NAME

Local::Source::Text - Text source class

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new {
	my ($class, %params) = @_;
	my $delim;
	if (exists $params{delimiter}) {
		$delim = $params{delimiter};
	} else {
		$delim = "\n";
	}
	my @a = split $delim, $params{text};
	my %h;
	$h{array} = \@a;
	return bless \%h, $class;
}

1;