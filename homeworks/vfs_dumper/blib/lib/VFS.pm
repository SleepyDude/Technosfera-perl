package VFS;
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
	return {
		other => {
			execute => $rights & 1 ? JSON::XS::true : JSON::XS::false,
			write => $rights & 2 ? JSON::XS::true : JSON::XS::false,
			read => $rights & 4 ? JSON::XS::true : JSON::XS::false,
		},
		group => {
			execute => $rights & 8 ? JSON::XS::true : JSON::XS::false,
			write => $rights & 16 ? JSON::XS::true : JSON::XS::false,
			read => $rights & 32 ? JSON::XS::true : JSON::XS::false,
		},
		user => {
			execute => $rights & 64 ? JSON::XS::true : JSON::XS::false,
			write => $rights & 128 ? JSON::XS::true : JSON::XS::false,
			read => $rights & 256 ? JSON::XS::true : JSON::XS::false,
		}
	}
}

our $buf;

sub parse {
	$buf = shift;
	my $tree;

	my $char = unpack "A", $buf;

	if ($char eq 'Z') {
		return {};
	}
	if ($char ne 'Z' and $char ne 'D') {
		die("The blob should start from 'D' or 'Z'");
	}
	$tree = _create_list();
	return $tree->[0];
}

sub _create_hash {
	my $flag = shift;
	my %h;
	my $len_byte = 2;
	my $right_byte = 2;
	my $size_byte = 4;
	my $sha1_byte = 20;

	my $name_len = unpack "n", $buf;
	my ($name, $rights) = unpack "x$len_byte A$name_len n", $buf;
	$h{name} = decode('utf-8', $name);
	$h{mode} = mode2s($rights);

	if ($flag eq "F") {
		my ($size, $hash) = unpack "x$len_byte x$name_len x$right_byte N A$sha1_byte", $buf;
		$buf = substr $buf, $len_byte + $name_len + $right_byte + $size_byte + $sha1_byte;
		$h{type} = "file";
		$h{size} = $size;
		$h{hash} = unpack "H*", $hash;
	} elsif ($flag eq "D") {
		$buf = substr $buf, $right_byte + $len_byte + $name_len;
		$h{type} = "directory";
	}

	return \%h;
}

sub _create_list {
	my @list;
	while ($buf) {
		my $command = unpack "A", $buf;
		$buf = substr $buf, 1;
		if ($command eq 'D'){
			push @list, _create_hash('D');
		} elsif ($command eq 'F') {
			push @list, _create_hash('F');
		} elsif ($command eq 'I') {
			$list[-1]->{list} = _create_list();
		} elsif ($command eq 'U') {
			return \@list;
		} elsif ($command eq 'Z') {
			die("Garbage ae the end of the buffer") if ($buf);
			return \@list;
		}
	}
}

1;
