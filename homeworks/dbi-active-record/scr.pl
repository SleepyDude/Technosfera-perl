use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Local::MusicLib::DB::SQLite;

my $db = Local::MusicLib::DB::SQLite->instance;

my $dbh = $db->connection;



my $last_insert_id;

my $table = 'tracks';
my $autoinc_field = 'id';
my $fields = [ 'album_id',       'track_name', 'track_length', 'track_addtime'];
my $values = [        '1', 'Sultans of Swing',         '3600',            '42'];


my $fields_str = join ", ", @$fields;
my $placeholders = join ", ", map { "?" } @$fields; 

$dbh->begin_work;

if($dbh->do("INSERT INTO $table ($fields_str) VALUES ($placeholders)", {}, @$values)) {
    $last_insert_id = $autoinc_field ? $dbh->last_insert_id("", "", $table, $autoinc_field) : 0;
    $dbh->commit; 
} else {
    $dbh->rollback;
    print "can't do insert request!\n";
}

print "last_id = $last_insert_id\n";