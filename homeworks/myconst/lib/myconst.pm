package myconst;

use strict;
use warnings;
use Exporter;
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
	die if scalar @str == 1;

	foreach (@str) {
		die if !defined $_;
	}

	my %h = (@str);
	my @deep = ("all");
	hash_parser(\%h, @deep);

	my $caller = caller;
	no strict 'refs';
	for my $key (keys %constants) {
		*{"$caller::$key"} = sub() { $constants{$key}; };
	}
	use strict 'refs';
}


sub hash_parser {
	my $href = shift;
	my @deep = @_;
	my %h = %{ $href };

	foreach my $key (keys %h) {
		die if $key eq '';
		if ( !ref $h{$key} ) {
			die if $h{$key} eq '';
			for my $group (@deep) {
				push @{ $EXPORT_TAGS{ $group } }, $key;
				$constants{$key} = $h{$key};
			}
		} elsif ( ref $h{$key} eq 'HASH' ) {
			if( %{ $h{$key} } ) {
				push @deep, $key;
				hash_parser($h{$key}, @deep);
				pop @deep;
			} else { 
				die; 
			}
		} else {
			die;
		}
	}
}

1;
