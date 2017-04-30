package Local::MusicLib::ArtistTest;
use Test::Class::Moose extends => 'Local::Test';

use Local::MusicLib::Artist;
use DDP;
use feature 'say';

sub test_set_get {
	my $self = shift;

	my $artist = Local::MusicLib::Artist->new();

	my $dt = DateTime->new (
		year       => 1977,
		month      => 7,
		day        => 23,
		hour       => 13,
		minute     => 22,
		second     => 11,
	);

	$artist->name('Dire Straits');
	$artist->country('uk');
	$artist->create_time($dt);

	is($artist->name, 'Dire Straits', 'name test');
	is($artist->country, 'uk', 'country test');
	is($artist->create_time, '1977-07-23T13:22:11', 'create_time test');
}

sub test_insert_select {
	my $self = shift;

	my $dt = DateTime->new (
		year       => 1977,
		month      => 7,
		day        => 23,
		hour       => 13,
		minute     => 22,
		second     => 11,
	);

	my $artist = Local::MusicLib::Artist->new(
		name => 'Dire Straits',
		country => 'uk',
		create_time => $dt,
	);

	my $has_ins = $artist->insert;
	is($has_ins, 1);

	my $last_id = $artist->id;

	my $selected_artist = Local::MusicLib::Artist->select_by_id($last_id);
	is($selected_artist->id, $artist->id, 'eq id');
	is($selected_artist->name, $artist->name, 'eq name');
	is($selected_artist->country, $artist->country, 'eq country');
	is($selected_artist->create_time, $artist->create_time, 'eq create_time');

	$artist->delete;
}

sub test_insert_select_id {
	my $self = shift;

	my $dt_1 = DateTime->new (
		year       => 1977,
		month      => 7,
		day        => 23,
		hour       => 13,
		minute     => 22,
		second     => 11,
	);

	my $dt_2 = DateTime->new (
		year       => 1975,
		month      => 4,
		day        => 2,
		hour       => 8,
		minute     => 12,
		second     => 05,
	);

	my $dt_3 = DateTime->new (
		year       => 2005,
		month      => 3,
		day        => 22,
		hour       => 21,
		minute     => 30,
		second     => 43,
	);

	my $artist_1 = Local::MusicLib::Artist->new(
		name => 'Dire Straits',
		country => 'uk',
		create_time => $dt_1,
	);

	my $artist_2 = Local::MusicLib::Artist->new(
		name => 'Boston',
		country => 'us',
		create_time => $dt_2,
	);

	my $artist_3 = Local::MusicLib::Artist->new(
		name => 'Motorama',
		country => 'ru',
		create_time => $dt_3,
	);


	my @artists = ($artist_1, $artist_2, $artist_3);

	$artist_1->insert;
	$artist_2->insert;
	$artist_3->insert;

	my $id_1 = $artist_1->id;
	my $id_2 = $artist_2->id;
	my $id_3 = $artist_3->id;

	my @selected = @{ Local::MusicLib::Artist->select_by_id([$id_1, $id_2, $id_3]) };

	foreach my $i (0..$#selected) {
		is($selected[$i]->id, $artists[$i]->id, 'id check');
		is($selected[$i]->country, $artists[$i]->country, 'country check');
		is($selected[$i]->name, $artists[$i]->name, 'name check');
		is($selected[$i]->create_time, $artists[$i]->create_time, 'create_time check');
	}

	$artist_1->delete;
	$artist_2->delete;
	$artist_3->delete;
}

sub test_insert_select_name {
	my $self = shift;

	my $dt_1 = DateTime->new (
		year       => 1977,
		month      => 7,
		day        => 23,
		hour       => 13,
		minute     => 22,
		second     => 11,
	);

	my $dt_2 = DateTime->new (
		year       => 1975,
		month      => 4,
		day        => 2,
		hour       => 8,
		minute     => 12,
		second     => 05,
	);

	my $dt_3 = DateTime->new (
		year       => 2005,
		month      => 3,
		day        => 22,
		hour       => 21,
		minute     => 30,
		second     => 43,
	);

	my $artist_1 = Local::MusicLib::Artist->new(
		name => 'Dire Straits',
		country => 'uk',
		create_time => $dt_1,
	);

	my $artist_2 = Local::MusicLib::Artist->new(
		name => 'Boston',
		country => 'us',
		create_time => $dt_2,
	);

	my $artist_3 = Local::MusicLib::Artist->new(
		name => 'Motorama',
		country => 'ru',
		create_time => $dt_3,
	);

	$artist_1->insert;
	$artist_2->insert;
	$artist_3->insert;

	my $boston = Local::MusicLib::Artist->select_by_name('Boston');

	is($boston->id, $artist_2->id, 'select by name is ok');

	$artist_1->delete;
	$artist_2->delete;
	$artist_3->delete;
}

sub test_update {
	my $self = shift;

	my $dt_1 = DateTime->new (
		year       => 1977,
		month      => 7,
		day        => 23,
		hour       => 13,
		minute     => 22,
		second     => 11,
	);

	my $dt_2 = DateTime->new (
		year       => 1975,
		month      => 4,
		day        => 2,
		hour       => 8,
		minute     => 12,
		second     => 05,
	);

	my $artist_1 = Local::MusicLib::Artist->new(
		name => 'Dire Straits',
		country => 'uk',
		create_time => $dt_1,
	);

	$artist_1->insert;

	$artist_1->name('Boston');
	$artist_1->country('us');
	$artist_1->create_time($dt_2);

	$artist_1->update;
	my $id = $artist_1->id;
	my $selected = Local::MusicLib::Artist->select_by_id($id);
	is($selected->name, 'Boston', 'ok update');

	$artist_1->delete;
}

1;