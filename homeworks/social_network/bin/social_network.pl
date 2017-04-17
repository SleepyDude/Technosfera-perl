#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use FindBin;
use lib "$FindBin::Bin/../lib";	
use Local::SocialNetwork;
use Local::DBconnector;
use DDP;
use Getopt::Long;
use JSON::XS;

my $command = shift;
die(wrong_com()) if !defined $command;
my @users;

GetOptions ("user=i" => \@users);

if ($command eq 'friends') {
	die(wrong_com()) if scalar @users != 2;
	print get_json(friends_responce(@users));
} elsif ($command eq 'nofriends') {
	die(wrong_com()) if scalar @users != 0;
	print get_json(loners_responce());
} elsif ($command eq 'num_handshakes') {
	die(wrong_com()) if scalar @users != 2;
	print get_json(handshakes_responce(@users));
} else {
	die(wrong_com());
}

sub wrong_com {
	say "Supported commands:";
	say "`friends --user XX --user YY` | Common friends list users with id XX and YY";
	say "`nofriends` | List of users who have no friends";
	say "`num_handshakes --user XX --user YY` | Number of handshakes between users with id XX and YY";
}

sub get_json {
	my $res = shift;
	return JSON::XS->new->utf8->pretty(1)->encode($res);
}