package Local::MusicLib::Util;

use DateTime;
use Exporter 'import';

sub dtSerializer {
	$_[0]->format_cldr("YYYY-MM-dd HH:mm:ss");
}

sub dtDeserializer {
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
}

sub extSerializer {
	my $dt = shift;
	my ($h,$m,$s) = split /:/, $dt;
	return $h*3600 + $m*60 + $s;
}

sub extDeserializer {
	my $seconds = shift;
	my $s = $seconds % 60;
	my $m = int($seconds / 60) % 60;
	my $h = int($seconds / 3600);
	my $result = sprintf("%.2d:%.2d:%.2d", $h,$m,$s);
	return $result;
}

@EXPORT_OK = qw(dtSerializer dtDeserializer extSerializer extDeserializer);