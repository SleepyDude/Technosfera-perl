use ExtUtils::testlib;

use Local::Stats;
use DDP;

# my $statistic = Local::Stats->new(sub { $name = shift; return "cnt", "avg" });

my $obj = Local::Stats->new( \&ret_func );
p $obj;
$obj->add('money', 15);
p $obj;
$obj->add('me', 40);
p $obj;
$obj->add('me', 20);
p $obj;
$obj->add('m3', 12.5);
p $obj;
$obj->add('m3', 22.5);
p $obj;

sub ret_func {
	my $name = shift;
	return qw(cnt) if $name eq 'money';
	return qw(cnt avg sum max min) if $name eq 'me';
	return qw(avg) if $name eq 'm3';
	return qw();
}