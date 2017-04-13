#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use FindBin;
use lib "$FindBin::Bin/../lib";	
use Local::SocialNetwork;
use Local::DBconnector;
use Local::User;
use DDP;

my $user = Local::User->get_by_id(7);
p $user;