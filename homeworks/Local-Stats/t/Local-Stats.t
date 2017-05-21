# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Local-Stats.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use ExtUtils::testlib;

use Test::More tests => 4;
BEGIN { use_ok('Local::Stats') };

my $obj = Local::Stats->new( \&ret_func );

subtest 'object has methods' => sub {
	isa_ok($obj, 'Local::Stats');
	new_ok("Local::Stats" => [\&ret_func]);
	can_ok($obj, qw(add stat));
};

subtest 'add method' => sub {
	
	$obj->add('me', 40);
	is_deeply(
		$obj->{metrics}->{me},
		{
			cnt => 1,
			avg => 40,
			sum => 40,
			max => 40,
			min => 40,
		},
		'metric me->40'
	);
	is_deeply(
		$obj->{avg_info}->{me},
		{
			cnt => 1,
			sum => 40,
		},
		'avg_info me->40'
	);

	$obj->add('m3', 15);
	is_deeply(
		$obj->{metrics}->{m3},
		{
			avg => 15,
		},
		'add m3->15'
	);
	is_deeply(
		$obj->{avg_info}->{m3},
		{
			cnt => 1,
			sum => 15,
		},
		'avg_info m3->40'
	);

	$obj->add('me', 20);
	is_deeply(
		$obj->{metrics}->{me},
		{
			cnt => 2,
			avg => 30,
			sum => 60,
			max => 40,
			min => 20,
		},
		'metrics me->40, me->20'
	);
	is_deeply(
		$obj->{avg_info}->{me},
		{
			cnt => 2,
			sum => 60,
		},
		'avg_info me->40, me->20'
	);

	$obj->add('m3', 75);
	is_deeply(
		$obj->{metrics}->{m3},
		{
			avg => 45,
		},
		'metrics m3->15, m3->45'
	);
	is_deeply(
		$obj->{avg_info}->{m3},
		{
			cnt => 2,
			sum => 90,
		},
		'avg_info m3->15, m3->45'
	);

	$obj->add('nothing', 100);
	is( $obj->{metrics}->{nothing}, undef, 'add to metric with empty config');
};

subtest 'stat method' => sub {
	my $res = $obj->stat;
	is_deeply(
		$res,
		{
			me => {
				cnt => 2,
				avg => 30,
				sum => 60,
				max => 40,
				min => 20,
			},
			m3 => {
				avg => 45,				
			},
		},
		'result hash'
	);
	is_deeply($obj->metrics, {}, 'metrics empty now');
	is_deeply($obj->avg_info, {}, 'avg_info empty now');
};

sub ret_func {
	my $name = shift;
	return qw(cnt avg sum max min) if $name eq 'me';
	return qw(avg) if $name eq 'm3';
	return qw();
}
#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.