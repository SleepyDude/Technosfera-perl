package Local::MusicLib::DB::MySQL;
use Mouse;
extends 'DBI::ActiveRecord::DB::MySQL';

use FindBin;

sub _build_connection_params {
    my ($self) = @_;
    return [
        'dbi:SQLite:dbname=../muslib.db', '', '', {}
    ];
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;