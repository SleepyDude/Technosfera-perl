package Local::MusicLib::DB::Test;

use Test::Class::Moose extends => 'Local::Test';
use DDP;

# sub test__build_connection_params {
#     my ($self) = @_;

#     p $self->{dbh}->connection_params();


#     return;
# }

sub test__insert {
	my $self = shift;

	# my $dbh = $self->{dbh}->connection;

	# my $stmt = qq(CREATE TABLE tracks
 #    (
 #    	id            INT PRIMARY KEY NOT NULL,
 #    	album_id      INT             NOT NULL,
 #    	track_name    TEXT            NOT NULL,
 #    	track_length  INT             NOT NULL,
 #    	track_addtime INT             NOT NULL,
 #    ););

	# my $rv = $dbh->do($stmt);
	# if($rv < 0){
	#    print $DBI::errstr;
	# } else {
	#    print "Table created successfully\n";
	# }

	my $table = 'tracks';
	my $autoinc_field = 'id';
	my $fields = [ 'album_id',       'track_name', 'track_length', 'track_addtime'];
	my $values = [        '1', 'Sultans of Swing',         '3600',            '42'];
	# format < $table, $autoinc_field, $fields, $values >
	my $last = $self->{dbh}->_insert($table, $autoinc_field, $fields, $values);
	print $last;
}

1;