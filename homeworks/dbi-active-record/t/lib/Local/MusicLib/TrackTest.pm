package Local::MusicLib::TrackTest;
use Test::Class::Moose extends => 'Local::Test';

use Local::MusicLib::Track;
use DDP;
use feature 'say';

sub test_set_get {
	my $self = shift;

	my $track = Local::MusicLib::Track->new();

	my $dt = DateTime->new (
		year       => 1969,
		month      => 03,
		day        => 18,
		hour       => 06,
		minute     => 13,
		second     => 59,
	);

	$track->album_id(2);
	$track->name('Lady Writer');
	$track->extension('00:03:45');
	$track->create_time($dt);

	is($track->album_id, 2, 'album_id test');
	is($track->name, 'Lady Writer', 'name test');
	is($track->extension, '00:03:45', 'extension test');
	is($track->create_time, '1969-03-18T06:13:59', 'create_time test');
}

sub test_insert_select {
	my $self = shift;

	my $dt = DateTime->new (
		year       => 1970,
		month      => 03,
		day        => 18,
		hour       => 06,
		minute     => 13,
		second     => 59,
	);

	my $track = Local::MusicLib::Track->new(
		album_id => 2,
		name => 'Lady Writer',
		extension => '00:03:45',
		create_time => $dt,
	);

	my $has_ins = $track->insert;
	is($has_ins, 1);

	my $last_id = $track->id;

	my $selected_track = Local::MusicLib::Track->select_by_id($last_id);
	is($selected_track->id, $track->id, 'eq id');
	is($selected_track->album_id, $track->album_id, 'eq album_id');
	is($selected_track->name, $track->name, 'eq name');
	is($selected_track->extension, $track->extension, 'eq extension');
	is($selected_track->create_time, $track->create_time, 'eq create_time');

	my $has_del = $track->delete;
}

sub test_insert_select_many {
	my $self = shift;

	my $dt_1 = DateTime->new (
		year       => 1976,
		month      => 9,
		day        => 17,
		hour       => 16,
		minute     => 25,
		second     => 00,
	);

	my $dt_2 = DateTime->new (
		year       => 1976,
		month      => 8,
		day        => 8,
		hour       => 16,
		minute     => 16,
		second     => 15,
	);

	my $dt_3 = DateTime->new (
		year       => 2002,
		month      => 12,
		day        => 18,
		hour       => 06,
		minute     => 13,
		second     => 59,
	);

	my $track_1 = Local::MusicLib::Track->new(
		album_id => 1,
		name => 'More Than a Feeling',
		extension => '00:04:44',
		create_time => $dt_1,
	);

	my $track_2 = Local::MusicLib::Track->new(
		album_id => 1,
		name => 'Smokin',
		extension => '00:04:22',
		create_time => $dt_2,
	);

	my $track_3 = Local::MusicLib::Track->new(
		album_id => 5,
		name => 'I Had A Good Time',
		extension => '00:04:15',
		create_time => $dt_3,
	);

	my @tracks = ($track_1, $track_2, $track_3);

	my $has_ins_1 = $track_1->insert;
	is($has_ins_1, 1);
	my $has_ins_2 = $track_2->insert;
	is($has_ins_2, 1);
	my $has_ins_3 = $track_3->insert;
	is($has_ins_3, 1);

	my $id_1 = $track_1->id;
	my $id_2 = $track_2->id;
	my $id_3 = $track_3->id;

	my @selected = @{ Local::MusicLib::Track->select_by_id([$id_1, $id_2, $id_3]) };

	foreach my $i (0..$#selected) {
		is($selected[$i]->id, $tracks[$i]->id, 'id check');
		is($selected[$i]->extension, $tracks[$i]->extension, 'extension check');
		is($selected[$i]->name, $tracks[$i]->name, 'name check');
		is($selected[$i]->album_id, $tracks[$i]->album_id, 'album_id check');
		is($selected[$i]->create_time, $tracks[$i]->create_time, 'create_time check');
	}

	my $has_del_1 = $track_1->delete;
	is($has_del_1, 1, 'del 1');
	my $has_del_2 = $track_2->delete;
	is($has_del_2, 1, 'del 2');
	my $has_del_3 = $track_3->delete;
	is($has_del_3, 1, 'del 3');
}

sub test_insert_select_id {
	my $self = shift;

	my $dt_1 = DateTime->new (
		year       => 1976,
		month      => 9,
		day        => 17,
		hour       => 16,
		minute     => 25,
		second     => 00,
	);

	my $dt_2 = DateTime->new (
		year       => 1976,
		month      => 8,
		day        => 8,
		hour       => 16,
		minute     => 16,
		second     => 15,
	);

	my $dt_3 = DateTime->new (
		year       => 2002,
		month      => 12,
		day        => 18,
		hour       => 06,
		minute     => 13,
		second     => 59,
	);

	my $track_1 = Local::MusicLib::Track->new(
		album_id => 1,
		name => 'More Than a Feeling',
		extension => '00:04:44',
		create_time => $dt_1,
	);

	my $track_2 = Local::MusicLib::Track->new(
		album_id => 1,
		name => 'Smokin',
		extension => '00:04:22',
		create_time => $dt_2,
	);

	my $track_3 = Local::MusicLib::Track->new(
		album_id => 5,
		name => 'I Had A Good Time',
		extension => '00:04:15',
		create_time => $dt_3,
	);

	my @tracks = ($track_1, $track_2, $track_3);

	my $has_ins_1 = $track_1->insert;
	is($has_ins_1, 1, 'ok ins 1');
	my $has_ins_2 = $track_2->insert;
	is($has_ins_2, 1, 'ok ins 2');
	my $has_ins_3 = $track_3->insert;
	is($has_ins_3, 1, 'ok ins 3');

	my $id_1 = $track_1->id;
	my $id_2 = $track_2->id;
	my $id_3 = $track_3->id;

	my @selected = @{ Local::MusicLib::Track->select_by_id([$id_1, $id_2, $id_3]) };

	foreach my $i (0..$#selected) {
		is($selected[$i]->id, $tracks[$i]->id, 'id check');
		is($selected[$i]->extension, $tracks[$i]->extension, 'extension check');
		is($selected[$i]->name, $tracks[$i]->name, 'name check');
		is($selected[$i]->album_id, $tracks[$i]->album_id, 'album_id check');
		is($selected[$i]->create_time, $tracks[$i]->create_time, 'create_time check');
	}

	my $has_del_1 = $track_1->delete;
	is($has_del_1, 1, 'del 1');
	my $has_del_2 = $track_2->delete;
	is($has_del_2, 1, 'del 2');
	my $has_del_3 = $track_3->delete;
	is($has_del_3, 1, 'del 3');
}

sub test_insert_select_name {
	my $self = shift;

	my $dt_1 = DateTime->new (
		year       => 1976,
		month      => 9,
		day        => 17,
		hour       => 16,
		minute     => 25,
		second     => 00,
	);

	my $dt_2 = DateTime->new (
		year       => 1976,
		month      => 8,
		day        => 8,
		hour       => 16,
		minute     => 16,
		second     => 15,
	);

	my $dt_3 = DateTime->new (
		year       => 2002,
		month      => 12,
		day        => 18,
		hour       => 06,
		minute     => 13,
		second     => 59,
	);

	my $track_1 = Local::MusicLib::Track->new(
		album_id => 1,
		name => 'More Than a Feeling',
		extension => '00:04:44',
		create_time => $dt_1,
	);

	my $track_2 = Local::MusicLib::Track->new(
		album_id => 1,
		name => 'Smokin',
		extension => '00:04:22',
		create_time => $dt_2,
	);

	my $track_3 = Local::MusicLib::Track->new(
		album_id => 5,
		name => 'I Had A Good Time',
		extension => '00:04:15',
		create_time => $dt_3,
	);

	my @tracks = ($track_1, $track_2, $track_3);

	my $has_ins_1 = $track_1->insert;
	is($has_ins_1, 1, 'ok ins 1');
	my $has_ins_2 = $track_2->insert;
	is($has_ins_2, 1, 'ok ins 2');
	my $has_ins_3 = $track_3->insert;
	is($has_ins_3, 1, 'ok ins 3');

	my $smokin = Local::MusicLib::Track->select_by_name('Smokin');

	is($smokin->id, $track_2->id, 'select by name is ok');

	$smokin->delete;
	$track_3->delete;
	$track_1->delete;
}

sub test_insert_select_album {
	my $self = shift;

	my $dt_1 = DateTime->new (
		year       => 1976,
		month      => 9,
		day        => 17,
		hour       => 16,
		minute     => 25,
		second     => 00,
	);

	my $dt_2 = DateTime->new (
		year       => 1976,
		month      => 8,
		day        => 8,
		hour       => 16,
		minute     => 16,
		second     => 15,
	);

	my $dt_3 = DateTime->new (
		year       => 2002,
		month      => 12,
		day        => 18,
		hour       => 06,
		minute     => 13,
		second     => 59,
	);

	my $track_1 = Local::MusicLib::Track->new(
		album_id => 1,
		name => 'More Than a Feeling',
		extension => '00:04:44',
		create_time => $dt_1,
	);

	my $track_2 = Local::MusicLib::Track->new(
		album_id => 1,
		name => 'Smokin',
		extension => '00:04:22',
		create_time => $dt_2,
	);

	my $track_3 = Local::MusicLib::Track->new(
		album_id => 5,
		name => 'I Had A Good Time',
		extension => '00:04:15',
		create_time => $dt_3,
	);

	my @tracks = ($track_1, $track_2);

	my $has_ins_1 = $track_1->insert;
	is($has_ins_1, 1, 'ok ins 1');
	my $has_ins_2 = $track_2->insert;
	is($has_ins_2, 1, 'ok ins 2');
	my $has_ins_3 = $track_3->insert;
	is($has_ins_3, 1, 'ok ins 3');

	my @selected = @{ Local::MusicLib::Track->select_by_album_id([1]) };

	foreach my $i (0..$#selected) {
		is($selected[$i]->id, $tracks[$i]->id, 'id sel by album_id check');
	}

	$track_1->delete;
	$track_2->delete;
	$track_3->delete;
}

sub test_update {
	my $self = shift;

	my $dt_1 = DateTime->new (
		year       => 1976,
		month      => 9,
		day        => 17,
		hour       => 16,
		minute     => 25,
		second     => 00,
	);

	my $dt_2 = DateTime->new (
		year       => 1976,
		month      => 8,
		day        => 8,
		hour       => 16,
		minute     => 16,
		second     => 15,
	);

	my $track_1 = Local::MusicLib::Track->new(
		album_id => 1,
		name => 'More Than a Feeling',
		extension => '00:04:44',
		create_time => $dt_1,
	);

	my $track_2 = Local::MusicLib::Track->new(
		album_id => 1,
		name => 'Smokin',
		extension => '00:04:22',
		create_time => $dt_2,
	);

	$track_1->insert;

	$track_1->album_id(1);
	$track_1->name('Smokin');
	$track_1->extension('00:04:22');
	$track_1->create_time($dt_2);

	$track_1->update;
	my $id = $track_1->id;
	my $selected = Local::MusicLib::Track->select_by_id($id);
	is($selected->name, 'Smokin', 'ok update');

	$track_1->delete;
}

1;