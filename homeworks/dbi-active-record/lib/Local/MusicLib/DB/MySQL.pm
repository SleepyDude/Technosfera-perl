package Local::MusicLib::DB::MySQL;
use Mouse;
extends 'DBI::ActiveRecord::DB::MySQL';

use FindBin;

sub _build_connection_params {
    my ($self) = @_;
    return [
        "DBI:mysql:database=muslib;host=localhost:3151426",
		"root",
		"pass",
		{
			"RaiseError" => 1, 
			"AutoCommit" => 0, 
			"mysql_enable_utf8" => 1,
		},
    ]
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;