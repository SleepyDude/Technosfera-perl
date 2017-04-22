package Notes::DBconnector;
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
    		open(my $json_fh, "<:encoding(UTF-8)", "$FindBin::Bin/config")
    			or die("Can't open \$filename\": $!\n");
    		local $/;
    		<$json_fh>
    	};

    	my $conf_ref = JSON::XS->new->utf8->decode ($config_text);
        
        $instance->{ DB } = DBI->connect(@$conf_ref[0..3])
            || die "Cannot connect to database: $DBI::errstr";
    }
    return $instance;
}

sub DESTROY {
    print "\n"."DESTROYED ". __PACKAGE__ ."\n";
}

1;