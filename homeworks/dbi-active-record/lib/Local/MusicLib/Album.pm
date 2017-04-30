package Local::MusicLib::Album;

use DBI::ActiveRecord;
use Local::MusicLib::DB::MySQL;
use Carp qw/confess/;

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
    serializer => sub {
        my $data = quotemeta(shift);
        my $valid = 'single studio soundtrack box live collection';
        if ($valid =~ /$data/) {
            return $data;
        } else {
            confess 'Wrong type!';
        }
    },
);

has_field year => (
    isa => 'Int',
);

has_field create_time => (
    isa => 'DateTime',
    serializer => sub { $_[0]->format_cldr("YYYY-MM-dd HH:mm:ss"); },
    deserializer => sub {
        my $string = shift;
    	my @data = $string =~ /^(\d+)-(\d+)-(\d+)\s(\d+):(\d+):(\d+)$/;
    	my $dt = DateTime->new (
			year       => $data[0],
			month      => $data[1],
			day        => $data[2],
			hour       => $data[3],
			minute     => $data[4],
			second     => $data[5],
		);
		return $dt;
     },
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;