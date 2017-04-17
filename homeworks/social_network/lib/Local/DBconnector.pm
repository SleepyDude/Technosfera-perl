package Local::DBconnector;
use strict;
use warnings;
use DBI;
use JSON::XS;
use DDP;
use FindBin;

my $instance = undef;

sub instance {
    if (! defined $instance) {
        $instance = bless {}, shift unless $instance;
        my $config_text = do {
    		open(my $json_fh, "<:encoding(UTF-8)", "$FindBin::Bin/../etc/config")
    			or die("Can't open \$filename\": $!\n");
    		local $/;
    		<$json_fh>
    	};
    	my $conf_ref = JSON::XS->new->utf8->decode ($config_text);
        
        $instance->{ DB } = DBI->connect(@$conf_ref)
            || die "Cannot connect to database: $DBI::errstr";
    }
    return $instance;
}

sub DESTROY {
    print "DESTROYED ". __PACKAGE__ ."\n";
    # my $self = shift;
    # p $self;
}

1;