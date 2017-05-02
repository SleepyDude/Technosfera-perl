package Local::MusicLib::Artist;

use DBI::ActiveRecord;
use Local::MusicLib::DB::MySQL;

use Local::MusicLib::Util qw(dtSerializer dtDeserializer);
use DateTime;

db "Local::MusicLib::DB::MySQL";

table 'artists';

has_field id => (
    isa => 'Int',
    auto_increment => 1,
    index => 'primary',
);

has_field name => (
    isa => 'Str',
    index => 'common',
    default_limit => 100,
);

has_field country => (
    isa => 'Str',
);

has_field create_time => (
    isa => 'DateTime',
    serializer => \&dtSerializer,
    deserializer => \&dtDeserializer,
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;