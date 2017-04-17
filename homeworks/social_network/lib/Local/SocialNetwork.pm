package Local::SocialNetwork;

use strict;
use warnings;
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
    return \@u;
}

sub loners_responce {
    my $loners = Local::SocialNetwork::User->get_loners();
    return $loners;
}

sub handshakes_responce {
    my $id_XX = shift;
    my $id_YY = shift;

    if (! Local::SocialNetwork::User->has_friends($id_XX) or ! Local::SocialNetwork::User->has_friends($id_YY)) {
        Local::DBconnector->instance()->disconnect();
        die("Someone have no friends :(");
    }

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
    return { "num_handshakes" => $handshakes };
}

our @EXPORT = qw(friends_responce loners_responce handshakes_responce);

1;