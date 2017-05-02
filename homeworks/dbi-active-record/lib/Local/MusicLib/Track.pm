package Local::MusicLib::Track;

use DBI::ActiveRecord;
use Local::MusicLib::DB::MySQL;

use Local::MusicLib::Util qw(dtSerializer dtDeserializer extSerializer extDeserializer);
use DateTime;

db "Local::MusicLib::DB::MySQL";

table 'tracks';

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

has_field extension => (
    isa => 'Str',
    serializer => \&extSerializer,
    deserializer => \&extDeserializer,
);

has_field create_time => (
    isa => 'DateTime',
    serializer => \&dtSerializer,
    deserializer => \&dtDeserializer,
);

has_field album_id => (
    isa => 'Int',
    index => 'common',
    default_limit => 100,
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;