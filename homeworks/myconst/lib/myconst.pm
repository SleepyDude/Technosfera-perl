package myconst;

use strict;
use warnings;
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

our %constants;
our %exp_groups;

sub import {
	my ($module, @str) = @_;
	die if scalar @str == 1;

	foreach (@str) {
		die if !defined $_;
	}

	my %h = (@str);
	foreach my $key (keys %h) {
		die if $key eq '';
		if ( !ref $h{$key} ) {
			die if $h{$key} eq '';
			push @{ $exp_groups{all} }, $key;
			$constants{$key} = $h{$key};
		} elsif ( ref $h{$key} eq 'HASH' ) {
			if( %{ $h{$key} } ) {
				foreach my $inside_key (keys %{ $h{$key} }) {
					die if $inside_key eq '';
					die if $h{$key}->{$inside_key} eq '';
					die if ref $h{$key}->{$inside_key};
					push @{ $exp_groups{all} }, $inside_key;
					push @{ $exp_groups{$key} }, $inside_key;
					$constants{$inside_key} = $h{$key}->{$inside_key};
				}
			} else { 
				die; 
			}
		} else {
			die;
		}
	}

	my $caller = caller;
	no strict 'refs';
	for my $key (keys %constants) {
		*{"$caller::$key"} = sub() { $constants{$key}; };
	}
	
	*{"$caller"."::import"} = sub { 
		shift;
		my @params = @_;
		my %already_use;
		my $caller = caller;
		for my $p (@params) {
			if ($p =~ /^:(.+)$/) {
				for my $c (@{ $exp_groups{ $1 } }) {
					*{"$caller::$c"} = sub() { $constants{$c}; } if !exists $already_use{$c};
					$already_use{$c} = 1;
				}
			} else {
				*{"$caller::$p"} = sub() { $constants{$p}; } if !exists $already_use{$p};
				$already_use{$p} = 1;
			}
		}
	};
}

1;
