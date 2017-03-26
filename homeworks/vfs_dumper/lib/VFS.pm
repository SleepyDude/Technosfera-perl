package VFS;
# use utf8;
use strict;
use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
no warnings 'experimental::smartmatch';
use DDP;
use Data::Dumper;
use Encode qw(decode encode);

sub mode2s {
	my $rights = shift;
	my %mode;
	$mode{other}{execute} = (0b00000001 & $rights) == 1 ? JSON::XS::true : JSON::XS::false;
	$mode{other}{write} = (0b00000010 & $rights) == 2 ? JSON::XS::true : JSON::XS::false;
	$mode{other}{read} = (0b00000100 & $rights) == 4 ? JSON::XS::true : JSON::XS::false;
	$mode{group}{execute} = (0b00001000 & $rights) == 8 ? JSON::XS::true : JSON::XS::false;
	$mode{group}{write} = (0b00010000 & $rights) == 16 ? JSON::XS::true : JSON::XS::false;
	$mode{group}{read} = (0b00100000 & $rights) == 32 ? JSON::XS::true : JSON::XS::false;
	$mode{user}{execute} = (0b01000000 & $rights) == 64 ? JSON::XS::true : JSON::XS::false;
	$mode{user}{write} = (0b10000000 & $rights) == 128 ? JSON::XS::true : JSON::XS::false;
	$mode{user}{read} = (0b100000000 & $rights) == 256 ? JSON::XS::true : JSON::XS::false;
	return \%mode;
}

our @chars;

sub parse {
	my $buf = shift;
	@chars = split //,$buf;
	my $tree;
	if ($chars[0] eq 'Z') {
		return {};
	}
	if ($chars[0] ne 'Z' and $chars[0] ne 'D') {
		die("The blob should start from 'D' or 'Z'");
	}
	$tree = _create_list();
	return $tree->[0];
}

sub _create_directory {
	my %dir;
	my $len_byte = 2;
	my $right_byte = 2;
	$dir{type} = "directory";
	my $name_len = unpack "n", join '', @chars[0..$len_byte - 1];
	my $name = join '', @chars[$len_byte..$name_len + $len_byte - 1];
	$dir{name} = decode('utf-8', $name);
	my $rights = unpack "n", join '', @chars[$name_len + $len_byte..$name_len + $len_byte + $right_byte - 1];
	$dir{mode} = mode2s($rights);

	@chars = @chars[$name_len + $len_byte + $right_byte..$#chars];
	return \%dir;
}

sub _create_file {
	my %file;
	my $len_byte = 2;
	my $right_byte = 2;
	my $size_byte = 4;
	my $sha1_byte = 20;
	$file{type} = "file";
	my $name_len = unpack "n", join '', @chars[0..$len_byte - 1];
	my $name = join '', @chars[$len_byte..$name_len + $len_byte - 1];
	$file{name} = decode('utf-8', $name);
	my $rights = unpack "n", join '', @chars[$name_len + $len_byte..$name_len + $len_byte + $right_byte - 1];
	$file{mode} = mode2s($rights);
	my $size = unpack "N", 
				join '', @chars[$name_len + $len_byte + $right_byte..
								$name_len + $len_byte + $right_byte + $size_byte - 1];
	$file{size} = $size;
	my $hash = join '', @chars[$name_len + $len_byte + $right_byte + $size_byte..
								$name_len + $len_byte + $right_byte + $size_byte + $sha1_byte - 1];
	$file{hash} = unpack 'H*', $hash;

	@chars = @chars[$name_len + $len_byte + $right_byte + $size_byte + $sha1_byte..$#chars];
	return \%file;
}

sub _create_list {
	my @list;
	while (scalar @chars) {
		my $command = shift @chars;
		if ($command eq 'D'){
			push @list, _create_directory();
		} elsif ($command eq 'F') {
			push @list, _create_file();
		} elsif ($command eq 'I') {
			$list[-1]->{list} = _create_list();
		} elsif ($command eq 'U') {
			return \@list;
		} elsif ($command eq 'Z') {
			die("Garbage ae the end of the buffer") if (scalar @chars);
			return \@list;
		}
	}
}

1;
