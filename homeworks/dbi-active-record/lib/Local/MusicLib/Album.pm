package Local::MusicLib::Album;

use DBI::ActiveRecord;
use Local::MusicLib::DB::MySQL;
use Local::MusicLib::Util qw(dtSerializer dtDeserializer);
use Carp qw/confess/;
use DDP;

use Mouse::Util::TypeConstraints;

enum 'TypeEnum' => qw(single studio soundtrack box live collection);

no Mouse::Util::TypeConstraints;

use DateTime;

db "Local::MusicLib::DB::MySQL";

table 'albums';

has_field id => (
    isa => 'Int',
    auto_increment => 1,
    index => 'primary',
);

has_field artist_id => (
    isa => 'Int',
    index => 'common',
    default_limit => 100,
);

has_field name => (
    isa => 'Str',
    index => 'common',
    default_limit => 100,
);

has_field type => (
    isa => 'Str',
    index => 'common',
    default_limit => 100,
    isa => 'TypeEnum',
);

has_field year => (
    isa => 'Int',
);

has_field create_time => (
    isa => 'DateTime',
    serializer => \&dtSerializer,
    deserializer => \&dtDeserializer,
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;