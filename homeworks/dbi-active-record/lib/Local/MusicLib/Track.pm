package Local::MusicLib::Track;

use DBI::ActiveRecord;
# Теперь данный класс - наследник DBI::ActiveRecord::Object
# И к нему подключен трейт DBI::ActiveRecord::Trait::Class
use Local::MusicLib::DB::MySQL;
use feature 'say';
use DDP;

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
    serializer => sub { 
        my $dt = shift;
    	my ($h,$m,$s) = split /:/, $dt;
    	return $h*3600 + $m*60 + $s;
    },
    deserializer => sub {
        my $seconds = shift;
    	my $s = $seconds % 60;
    	my $m = int($seconds / 60) % 60;
    	my $h = int($seconds / 3600);
    	my $result = sprintf("%.2d:%.2d:%.2d", $h,$m,$s);
    	return $result;
    },
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

has_field album_id => (
    isa => 'Int',
    index => 'common',
    default_limit => 100,
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;