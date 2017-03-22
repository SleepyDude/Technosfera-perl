package myconst;

use strict;
use warnings;
use Scalar::Util 'looks_like_number';
use Exporter qw/import/;
use DDP;
use Data::Dumper;


=encoding utf8

=head1 NAME

myconst - pragma to create exportable and groupped constants

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
package aaa;

use myconst math => {
        PI => 3.14,
        E => 2.7,
    },
    ZERO => 0,
    EMPTY_STRING => '';

package bbb;

use aaa qw/:math PI ZERO/;

print ZERO;             # 0
print PI;               # 3.14
=cut

our %EXPORT_TAGS;
our %constants;

sub import {
	my ($module, @str) = @_;
	my %h = (@str);

	my @deep = ("all");
	hash_parser(\%h, @deep);

	my $caller = caller;
	for my $key (keys %constants) {
		no strict 'refs';
		*{"$caller::$key"} = sub() { $constants{$key}; };
		use strict 'refs';
	}
}


sub hash_parser {
	my $href = shift;
	my @deep = @_;
	my %h = %{ $href };

	foreach my $key (keys %h) {
		if ( !ref $h{$key} ) {
			for my $group (@deep) {
				push @{ $EXPORT_TAGS{ $group } }, $key;
				$constants{$key} = $h{$key};
			}
		} elsif ( ref $h{$key} eq 'HASH' ) {
			push @deep, $key;
			hash_parser($h{$key}, @deep);
			pop @deep;
		}
	}
}

1;
