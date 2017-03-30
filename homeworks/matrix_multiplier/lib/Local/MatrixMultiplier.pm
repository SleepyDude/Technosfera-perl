package Local::MatrixMultiplier;

use strict;
use warnings;
use feature qw(say);
use DDP;


sub mult {
    my ($mat_a, $mat_b, $max_child) = @_;
    _validate_m($mat_a, $mat_b);
    my $res = [];
    my $size_m = scalar @$mat_a;
    $max_child = $size_m*$size_m if $size_m*$size_m < $max_child;

    my @pairs;

    for my $i (0 .. $size_m - 1) {
    	for my $j (0 .. $size_m - 1) {
    		push @pairs, [$i, $j];
    	}
    }

    my @pids;
	my @kids;

	my $pelem = int scalar @pairs / $max_child;
	my $post = scalar @pairs % $max_child;
 
	foreach my $count (0 .. $max_child-1) {
	    my $pid = open(my $out, "-|");
	    die "Failed to fork: $!" unless defined $pid;
	    push @kids, $out;
	    push @pids, $pid;
	    unless ($pid) {
	        # Child.
	        if ($count == $max_child-1 and $post != 0) {
		        for (@pairs[$count * $pelem .. ($count + 1) * $pelem + $post - 1]) {
		        	my $pair = $_;
		        	my $res = _mult($mat_a, $mat_b, $pair->[0], $pair->[1]);
		        	print "$pair->[0]:$pair->[1]:$res\n";
		        }
		    } else {
		        for (@pairs[$count * $pelem .. ($count + 1) * $pelem - 1]) {
		        	my $pair = $_;
		        	my $res = _mult($mat_a, $mat_b, $pair->[0], $pair->[1]);
		        	print "$pair->[0]:$pair->[1]:$res\n";
		        }
		    }
	        exit;
	    }
	}

	foreach my $fh (@kids) {
	    my @lines = <$fh>;
	    chomp @lines;
	    foreach my $line (@lines) {
	    	$line =~ /^(.):(.):(\d+)$/;
	    	$res->[$1]->[$2] = $3;
	    }
	}

	foreach (@pids) {
		waitpid($_,0);
	}

    return $res;
}

sub _validate_m {
	my ($mat_a, $mat_b) = @_;
	die("Wrong matrix") if scalar @$mat_a != scalar @$mat_b;

	for (@$mat_a) {
    	die("Wrong matrix") if scalar @$mat_a != scalar @$_;
    }

    for (@$mat_b) {
    	die("Wrong matrix") if scalar @$mat_b != scalar @$_;
    }
}

sub _mult {
	my ($mat_a, $mat_b, $row, $col) = @_;
	my $res;
	my $col_num = 0;
	foreach my $i (0 .. scalar @$mat_a - 1) {
		$res+= $mat_a->[$row]->[$i] * $mat_b->[$i]->[$col];
	}
	return $res;
}
1;
