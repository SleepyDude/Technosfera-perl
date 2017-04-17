use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::Converter;
use Local::DBconnector;

my $dbh = Local::DBconnector->instance();

parse_users($dbh);
parse_relations($dbh);

$dbh->disconnect();