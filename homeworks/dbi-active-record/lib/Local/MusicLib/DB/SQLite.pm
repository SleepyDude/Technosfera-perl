package Local::MusicLib::DB::SQLite;
use Mouse;
extends 'DBI::ActiveRecord::DB::SQLite';

use FindBin;

sub _build_connection_params {
    my ($self) = @_;
    return [
        'dbi:SQLite:dbname=muslib.db', '', '', {}
    ];
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;