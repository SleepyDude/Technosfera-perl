package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;

sub calculate {
	my @members = @_;
	my @res;
	my %h;
	my $id_married = 0;
	my $id_friend = 0;
	foreach (@members) {
		if (!(ref $_)) {
			$h{$_} = [ $id_married++, $id_friend++];
		} 
		else {
			$h{$_->[0]} = [ $id_married, $id_friend++];
			$h{$_->[1]} = [ $id_married++, $id_friend++];
		}
	}
	my @transmitters = keys %h;
	my @receivers = keys %h;

	if (scalar @transmitters <= 2 or (scalar @transmitters  == 3 and $id_married == 2)) {
		return "wrong input data";
	}

	while ( scalar @transmitters > 0) {
		if (scalar @transmitters == 1 and scalar @receivers == 1) {
			if ($h{$transmitters[0]}[0] == $h{$receivers[0]}[0] or $h{$transmitters[0]}[1] == $h{$receivers[0]}[1]) {
				goto &calculate;
			}
		}
		if (scalar @transmitters == 2 and scalar @receivers == 2) {
			if ($h{$transmitters[0]}[0] == $h{$receivers[1]}[0]) {
				goto &calculate;
			}
		}
		my $i = int rand @transmitters;
		my $j = int rand @receivers;
		if ($h{$transmitters[$i]}[0] != $h{$receivers[$j]}[0] and $h{$transmitters[$i]}[1] != $h{$receivers[$j]}[1]) {
			push @res, [ $transmitters[$i], $receivers[$j] ];
			$h{$transmitters[$i]}[1] = $id_friend;
			$h{$receivers[$j]}[1] = $id_friend++;

			@transmitters = grep { $_ ne $transmitters[$i] } @transmitters;
			@receivers = grep { $_ ne $receivers[$j] } @receivers;
		}
	}
	return @res;
}

1;
