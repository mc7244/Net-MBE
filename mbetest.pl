#!/usr/bin/env perl 



    # use strict;
    # use warnings;
    # use 5.010;
     
    # use LWP::UserAgent;
    # sub LWP::UserAgent::get_basic_credentials {
    #     warn "@_\n";
    # }
    # my $ua = LWP::UserAgent->new;
    # my $resp = $ua->get( 'https://api.mbeonline.it/ws' );

use lib './lib';
use Net::MBE;
use Arthas::Defaults::536;

my $mbe = Net::MBE->new({
    system => 'IT',
    Username => 'NEGOZIOCOLTELLINAI@Italy',
    Passphrase => 'kGEJ5HzzwjkeMi8pudpLaWD7fX7dn4gZ',
});

my $response = $mbe->ShippingOptions({
    InternalReferenceID => '48147184XTST',
});