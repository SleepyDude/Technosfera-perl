#!/usr/bin/perl

use strict;
use warnings;


my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;

    # you can put your code here
    my %res;
    my $result;
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    while (my $log_line = <$fd>) {

        # you can put your code here
        # $log_line contains line from log file
        my %time;
        $log_line =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/;
        my $ip = $1;
        $res{$ip}->{"count"} += 1;
        $res{"total"}->{"count"} += 1;
        $log_line =~ /\[(\d+)\/(.+)\/(\d+):(\d+):(\d+):(\d+).+\]/;
        (my $day,my $month,my $year,my $hours,my $minutes,my $seconds) = ($1, $2, $3, $4, $5, $6);
        my $sec = $seconds + $minutes * 60 + $hours * 3600 + $day * 3600 * 24;
        if (exists $res{$ip}->{"times"}) {
            if ($sec < $res{$ip}->{"times"}->[0]) {
                unshift @{ $res{$ip}->{"times"} }, $sec;
                unshift @{ $res{"total"}->{"times"} }, $sec;
            }
            elsif ($sec > $res{$ip}->{"times"}->[-1]) {
                push @{ $res{$ip}->{"times"} }, $sec;
                push @{ $res{"total"}->{"times"} }, $sec;
            }
        }
        else {
            $res{$ip}->{"times"}->[0] = $sec;
        }
        $log_line =~ /\s(\d{3})\s(\d+)/;
        my $status = $1;
        my $data = $2;
        $res{$ip}->{"status"}->{$status} += $data;
        $res{"total"}->{"status"}->{$status} += $data;
        $log_line =~ /"(\d+(\.\d+)?)"/;
        my $zipC = $1;
        if ($status == 200) {
            $res{$ip}->{"data"} += $zipC * $data;
            $res{"total"}->{"data"} += $zipC * $data;
        }
    }
    close $fd;

    for my $key (keys %res) {
        $res{$key}->{"avg"} = $res{$key}->{"count"} * 60 / ($res{$key}->{"times"}->[-1] - $res{$key}->{"times"}->[0] + 1)
    }
    $result = \%res;
    # you can put your code here

    return $result;
}

sub report {
    my $result = shift;
    my @stat;
    @stat = keys $result->{"total"}->{"status"};
    @stat = sort { $a <=> $b } @stat;
    print "IP\tcount\tavg\tdata";
    for (@stat) {
        print "\tdata_$_"
    }
    #unshift @stat, ("IP","count","avg","data");
    for my $key (keys %$result) {
        print $key . "\t";
        print $result->{$key}->{"count"} . "\t";
        printf "%.2f", $result->{$key}->{"avg"};
        print "\t";
        if (exists $result->{$key}->{"data"}) {
            print int $result->{$key}->{"data"} / 1000;
        }
        else {
            print "0";
        }
        for (@stat) {
            if (exists $result->{$key}->{"status"}->{$_}) {
                print "\t" . int $result->{$key}->{"status"}->{$_} / 1000;
            }
            else {
                print "\t0";
            }
        }
        print "\n";
    }
    

    # you can put your code here

}
