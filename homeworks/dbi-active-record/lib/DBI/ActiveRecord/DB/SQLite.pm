package DBI::ActiveRecord::DB::SQLite;
use Mouse;

extends 'DBI::ActiveRecord::DB';
with 'DBI::ActiveRecord::DB::Role::SimpleSQL';

no Mouse;
__PACKAGE__->meta->make_immutable();

1;