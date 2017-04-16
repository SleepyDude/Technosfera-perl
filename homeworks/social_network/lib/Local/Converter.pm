package Local::Converter;

use strict;
use warnings;
use IO::Uncompress::Unzip qw(unzip $UnzipError);
use FindBin;
use Exporter 'import';

sub parse_users {
	my $db = shift;
	my $chunk = 10000;
	my $user_dat = new IO::Uncompress::Unzip "$FindBin::Bin/../etc/user.zip"
		or die "unzip failed: $UnzipError\n";
	my @arr;
	my $counter = 0;
	my $sth;
	while (<$user_dat>) {
		my ($num, $first, $last) = split /\s+/, $_;
		push @arr, $num||'', $first||'', $last||'';
		$counter++;
		if ($counter % $chunk == 0) {
            $sth = $db->prepare(
                "REPLACE INTO users (id, firstname, lastname) VALUES" .  ' (?, ?, ?),'x($chunk-1) . ' (?, ?, ?)'
            );
            $sth->execute(@arr);
            @arr = ();
        }
	}
	my $rem = $counter % $chunk;
	if ($rem) {
        $sth = $db->prepare(
            "REPLACE INTO users (id, firstname, lastname) VALUES" .  ' (?, ?, ?),'x($rem-1) . ' (?, ?, ?)'
        );
        $sth->execute(@arr);
	}
    $db->commit;
}

sub parse_relations {
    my $dbh = shift;
    my $chunk = 100000;
    my $counter;
    warn "read from zip\n";
    my $relations_data = new IO::Uncompress::Unzip "$FindBin::Bin/../etc/user_relation.zip"
        or die "unzip failed\n";
    my @arr;
    warn "start inserting to relations\n";
    while(my $line = $relations_data->getline) {
        $counter++;
        my ($user_id_1, $user_id_2) = split /\s+/, $line;
        push @arr, $user_id_1||-1, $user_id_2||-1;
        if($counter % $chunk == 0) {
            my $sth1=$dbh->prepare(
                'REPLACE INTO relations (user_id_1, user_id_2) VALUES' . ' (?, ?),'x($chunk - 1) . ' (?, ?)'
            );
            $sth1->execute(@arr);
            $dbh->commit;
            my $sth2=$dbh->prepare('REPLACE INTO relations (user_id_2, user_id_1) VALUES' . ' (?, ?),'x(scalar $chunk - 1) . ' (?, ?)');
            $sth2->execute(@arr);
            $dbh->commit;
            @arr = ();
            warn "$counter relations inserted";
        }
    }
    if (scalar @arr) {
        my $sth1=$dbh->prepare(
            'REPLACE INTO relations (user_id_1, user_id_2) VALUES' . ' (?, ?),'x((scalar @arr)/2 - 1) . ' (?, ?)'
        );
        $sth1->execute(@arr);
        $dbh->commit;
        my $sth2=$dbh->prepare(
            'REPLACE INTO relations (user_id_2, user_id_1) VALUES' . ' (?, ?),'x((scalar @arr)/2 - 1) . ' (?, ?)'
        );
        $sth2->execute(@arr);
        $dbh->commit;
        @arr = ();
        warn "$counter relations inserted";
    }
    warn "stop inserting to relations\n";
}

our @EXPORT = qw(parse_users parse_relations);

1;