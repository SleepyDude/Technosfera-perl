use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::SocialNetwork;
use Local::DBconnector;

my $dbh = Local::DBconnector->get();

parse_users($dbh);
parse_relations($dbh);

$dbh->disconnect();