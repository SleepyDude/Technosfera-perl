#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;


print "Get ready\n";

my $filename;

GetOptions("file=s" => \$filename);

die if !defined $filename;
open(my $fh, '>', $filename) or die $!;

$SIG{INT} = \&catch_int;

my $twist_flag = 0;

my $sum = 0;
my $count = 0;

sub catch_int {
	if ($twist_flag == 1) {
		print_params();
		exit;
	}
	$twist_flag++;
	print STDERR "Double Ctrl+C for exit";
};

sub print_params {
	my $avg = $sum / $count;
	print STDOUT $sum." ".$count." ".$avg;
	close($fh);
}

select $fh;
while (<STDIN>) {
	my $line = $_;
	$twist_flag = 0;
	print $line;
	chomp $line;
	$sum += scalar split '', $line;
	$count++;
}

print_params();