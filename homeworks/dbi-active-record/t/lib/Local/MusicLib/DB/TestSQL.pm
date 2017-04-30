package Local::MusicLib::DB::TestSQL;

use Test::Class::Moose extends => 'Local::Test';
use DDP;

sub test_sql_methods {
	my $self = shift;

	my $table = 'tracks';
	my $key_field = 'id';
	my @fields = ( 'album_id',             'name', 'extension',         'create_time');
	my @values = (        '1', 'Sultans of Swing',       '360', '1978-05-13 11:10:09');

	# Вставляем данные и получаем индекс поля
	my $key_value = $self->{dbh}->_insert($table, $key_field, \@fields, \@values);
	# Извлекаем данные по этому индексу для проверки
	my $select_res = $self->{dbh}->_select($table, \@fields, $key_field, [ $key_value ]);
	# Проверяем данные
	foreach my $i (0..$#fields) {
		is($select_res->[0]->{ $fields[$i] }, $values[$i], 'insert equality');
	}
	# Новые значения поля
	my @ch_values = ('5','Money for Nothing','505','1985-07-17 07:15:22');
	# Изменяем данные 
	my $has_update = $self->{dbh}->_update($table, $key_field, $key_value, \@fields, \@ch_values);
	is($has_update, 1, 'update success');
	# #Проверяем их
	my $select_ch_res = $self->{dbh}->_select($table, \@fields, $key_field, [ $key_value ]);
	foreach my $i (0..$#fields) {
		is($select_ch_res->[0]->{ $fields[$i] }, $ch_values[$i], 'update equality');
	}
	# Удаляем запись
	my $has_delete = $self->{dbh}->_delete($table, $key_field, $key_value);
	# Проверяем успешно ли удаление 
	is($has_delete, 1, 'delete success');

	return;
}

1;