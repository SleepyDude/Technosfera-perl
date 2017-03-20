package Local::Row::Simple;

use strict;
use warnings;
use parent 'Local::Row';

=encoding utf8

=head1 NAME

Local::Row::Simple - Simple row class

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new {
	my ($class, %params) = @_;
	my @strings = split ",", $params{str};
	my %log;
	foreach my $str (@strings) {
		my ($key, $value) = split ":", $str;
		$log{$key} = $value;
	}
	my %res = ('log', \%log);
	return bless \%res, $class;
}

1;