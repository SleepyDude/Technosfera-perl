package Local::MusicLib::Artist;

use DBI::ActiveRecord;
use Local::MusicLib::DB::MySQL;

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