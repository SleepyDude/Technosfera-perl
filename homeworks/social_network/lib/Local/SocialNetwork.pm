package Local::SocialNetwork;

use strict;
use warnings;
use IO::Uncompress::Unzip qw(unzip $UnzipError);
use FindBin;
use Exporter 'import';
use Local::SocialNetwork::User;
use DDP;
use feature qw(say);

=encoding utf8

=head1 NAME

Local::SocialNetwork - social network user information queries interface

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub friends_responce {
    my $id_XX = shift;
    my $id_YY = shift;

    my $user_XX = Local::SocialNetwork::User->get_by_id($id_XX);
    my $user_YY = Local::SocialNetwork::User->get_by_id($id_YY);

    my @friends_XX = @{ $user_XX->get_friends() };
    my @friends_YY = @{ $user_YY->get_friends() };

    my %original;
    map { $original{$_} = 1 } @friends_XX;
    my @isect = grep { $original{$_} } @friends_YY;
    my @u;
    foreach (@isect) {
        my $user_id = $_;
        my $user = Local::SocialNetwork::User->get_by_id($user_id);
        push @u, $user->get();
    }
    my $json = JSON::XS->new->utf8->pretty(1)->encode(\@u);

    print $json;
    file_print($json);
}

sub loners_responce {
    my $loners = Local::SocialNetwork::User->get_loners();
    my $json = JSON::XS->new->utf8->pretty(1)->encode($loners);

    print $json;
    file_print($json);
}

sub handshakes_responce {
    my $id_XX = shift;
    my $id_YY = shift;

    my $handshakes = 0;
    my %selected_h = ($id_XX => 1);
    my $i = 0;
    while (!defined $selected_h{$id_YY}) {
        my @friends = @{ Local::SocialNetwork::User->get_friends_by_list($id_YY, keys %selected_h) };
        foreach (@friends) {
            my $id = $_;
            $selected_h{$id} = 1;
        }
        $handshakes++;
    }

    my $json = JSON::XS->new->utf8->pretty(1)->encode({ "num_handshakes" => $handshakes });
    print $json;
    file_print($json);
}

sub file_print {
    my $json = shift;
    open(my $fh, ">", "output.txt")
        or die "Can't open > output.txt: $!";
    print $fh $json;
    close $fh;
}

our @EXPORT = qw(friends_responce loners_responce handshakes_responce);

1;
