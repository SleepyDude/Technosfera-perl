package Local::MusicLib::AlbumTest;
use Test::Class::Moose extends => 'Local::Test';

use Local::MusicLib::Album;
use DDP;
use feature 'say';

my $dt_1 = DateTime->new (
	year       => 2016,
	month      => 7,
	day        => 23,
	hour       => 13,
	minute     => 22,
	second     => 11,
);

my $dt_2 = DateTime->new (
	year       => 2015,
	month      => 4,
	day        => 2,
	hour       => 8,
	minute     => 12,
	second     => 05,
);

my $dt_3 = DateTime->new (
	year       => 2014,
	month      => 3,
	day        => 22,
	hour       => 21,
	minute     => 30,
	second     => 43,
);

my $album_1 = Local::MusicLib::Album->new (
	artist_id => 1,
	name      => 'Communique',
	year      => 1979,
	type      => 'studio',
	create_time => $dt_1,
);

my $album_2 = Local::MusicLib::Album->new (
	artist_id => 2,
	name      => 'Boston',
	year      => 1976,
	type      => 'studio',
	create_time => $dt_2,
);

my $album_3 = Local::MusicLib::Album->new (
	artist_id => 1,
	name      => 'Alchemy',
	year      => 1983,
	type      => 'live',
	create_time => $dt_3,
);

sub test_set_get {
	my $self = shift;

	my $album = Local::MusicLib::Album->new();

	my $dt = DateTime->new (
		year       => 2016,
		month      => 7,
		day        => 23,
		hour       => 13,
		minute     => 22,
		second     => 11,
	);

	$album->artist_id(1);
	$album->name('Communique');
	$album->year(1979);
	$album->type('studio');
	$album->create_time($dt);

	is($album->artist_id, 1, 'artist_id test');
	is($album->name, 'Communique', 'name test');
	is($album->year, 1979, 'year test');
	is($album->type, 'studio', 'type test');
	is($album->create_time, '2016-07-23T13:22:11', 'create_time test');
}

sub test_insert_select {
	my $self = shift;

	my $has_ins = $album_1->insert;
	is($has_ins, 1);

	my $last_id = $album_1->id;

	my $selected_album = Local::MusicLib::Album->select_by_id($last_id);
	is($selected_album->id, $album_1->id, 'eq id');
	is($selected_album->artist_id, $album_1->artist_id, 'eq artist_id');
	is($selected_album->name, $album_1->name, 'eq name');
	is($selected_album->year, $album_1->year, 'eq year');
	is($selected_album->type, $album_1->type, 'eq type');
	is($selected_album->create_time, $album_1->create_time, 'eq create_time');

	$album_1->delete;
}

sub test_insert_select_id {
	my $self = shift;

	my @albums = ($album_1, $album_2, $album_3);

	$album_1->insert;
	$album_2->insert;
	$album_3->insert;

	my $id_1 = $album_1->id;
	my $id_2 = $album_2->id;
	my $id_3 = $album_3->id;

	my @selected = @{ Local::MusicLib::Album->select_by_id([$id_1, $id_2, $id_3]) };

	foreach my $i (0..$#selected) {
		is($selected[$i]->id, $albums[$i]->id, 'eq id');
		is($selected[$i]->artist_id, $albums[$i]->artist_id, 'eq artist_id');
		is($selected[$i]->name, $albums[$i]->name, 'eq name');
		is($selected[$i]->year, $albums[$i]->year, 'eq year');
		is($selected[$i]->type, $albums[$i]->type, 'eq type');
		is($selected[$i]->create_time, $albums[$i]->create_time, 'eq create_time');
	}

	$album_1->delete;
	$album_2->delete;
	$album_3->delete;
}

sub test_insert_select_artist {
	my $self = shift;

	$album_1->insert;
	$album_2->insert;
	$album_3->insert;

	my $boston = Local::MusicLib::Album->select_by_artist_id(2);

	is($boston->id, $album_2->id, 'select by artist_id is ok');

	$album_1->delete;
	$album_2->delete;
	$album_3->delete;
}

sub test_insert_select_name {
	my $self = shift;

	$album_1->insert;
	$album_2->insert;
	$album_3->insert;

	my $alchemy = Local::MusicLib::Album->select_by_name('Alchemy');

	is($alchemy->id, $album_3->id, 'select by name is ok');

	$album_1->delete;
	$album_2->delete;
	$album_3->delete;
}

sub test_insert_select_type {
	my $self = shift;

	$album_1->insert;
	$album_2->insert;
	$album_3->insert;

	my $alchemy = Local::MusicLib::Album->select_by_type('live');

	is($alchemy->id, $album_3->id, 'select by type is ok');

	$album_1->delete;
	$album_2->delete;
	$album_3->delete;
}

sub test_update {
	my $self = shift;

	$album_1->insert;

	$album_1->name('Sultans of Swing');

	$album_1->update;

	my $id = $album_1->id;
	my $selected = Local::MusicLib::Album->select_by_id($id);
	is($selected->name, 'Sultans of Swing', 'ok update');

	$album_1->delete;
}

1;