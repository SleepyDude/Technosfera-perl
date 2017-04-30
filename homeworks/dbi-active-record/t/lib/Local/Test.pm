package Local::Test;

use Test::Class::Moose;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Local::MusicLib::DB::MySQL;
use Local::MusicLib::DB::SQLite;

sub test_startup {
    my ($self) = @_;

    $self->next::method();

    $self->{dbh} = Local::MusicLib::DB::MySQL->instance;

    return;
}

sub test_teardown {
    my ($self) = @_;

    return;
}

1;