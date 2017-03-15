#!/usr/bin/perl

use strict;
use warnings;
use DDP;


my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;
    my %res;
    my $result;
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    while (my $log_line = <$fd>) {
        my %time;
        $log_line =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/;
        my $ip = $1;
        $res{$ip}->{count} += 1;
        $res{total}->{count} += 1;
        $log_line =~ /\[(\d+\/.+?\/\d+:\d+:\d+).+\]/;
        $res{$ip}->{minutes}->{$1} = 1;
        $res{total}->{minutes}->{$1} = 1;
        $log_line =~ /\s(\d{3})\s(\d+)/;
        my $status = $1;
        my $data = $2;
        $res{$ip}->{status}->{$status} += $data;
        $res{total}->{status}->{$status} += $data;
        $log_line =~ /"(\d+(?:\.\d+)?|-)"$/;
        my $zipC = $1 eq "-" ? 1 : $1;
        if ($status == 200) {
            $res{$ip}->{data} += int($zipC * $data);
            $res{total}->{data} += int($zipC * $data);
        }
    }
    close $fd;

    for my $ip (keys %res) {
        $res{$ip}->{avg} = $res{$ip}->{count} / scalar( keys %{ $res{$ip}->{minutes} } );
    }

    $result = \%res;
    return $result;
}

sub report {
    my $result = shift;
    my @stat;
    @stat = keys %{ $result->{total}->{status} };
    @stat = sort { $a <=> $b } @stat;
    print "IP\tcount\tavg\tdata";
    for (@stat) {
        print "\t$_"
    }
    print "\n";
    for my $key ((sort {$result->{$b}->{count} <=> $result->{$a}->{count}} keys %$result)[0..10]) {
        print $key . "\t";
        print $result->{$key}->{count} . "\t";
        printf "%.2f", $result->{$key}->{avg};
        print "\t";
        if (exists $result->{$key}->{data}) {
            print int $result->{$key}->{data} / 1024;
        }
        else {
            print "0";
        }
        for (@stat) {
            if (exists $result->{$key}->{status}->{$_}) {
                print "\t" . int $result->{$key}->{status}->{$_} / 1024;
            }
            else {
                print "\t0";
            }
        }
        print "\n";
    }

}
