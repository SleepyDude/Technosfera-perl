package Local::DBconnector;
use strict;
use warnings;
use base 'Class::Singleton';
use DBI;
use JSON::XS;

use FindBin;

sub _new_instance {
    my $class = shift;
    my $self  = bless {}, $class;
    my $db    = shift || "network";    
    my $host  = shift || "localhost";

    my $config_text = do {
		open(my $json_fh, "<:encoding(UTF-8)", "$FindBin::Bin/../etc/config")
			or die("Can't open \$filename\": $!\n");
		local $/;
		<$json_fh>
	};
	my $conf_ref = JSON::XS->new->utf8->decode ($config_text);
    
    $self->{ DB } = DBI->connect(@$conf_ref)
        || die "Cannot connect to database: $DBI::errstr";

    return $self->{ DB };
}

1;