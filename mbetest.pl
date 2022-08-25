#!/usr/bin/env perl 



use lib './lib';
use Net::MBE;
use Net::MBE::DestinationInfo;
use Net::MBE::ShippingParameters;
use Arthas::Defaults::536;

my $mbe = Net::MBE->new({
    system => 'IT',
    Username => 'NEGOZIOCOLTELLINAI@Italy',
    Passphrase => 'kGEJ5HzzwjkeMi8pudpLaWD7fX7dn4gZ',
});

my $dest = Net::MBE::DestinationInfo->new({
    zipCode => '33085',
    country => 'IT', 
    state => 'PN'
});

my $shipparams = Net::MBE::ShippingParameters->new({
    destinationInfo => $dest,
    shipType => 'EXPORT',
    packageType => 'GENERIC',
});
$shipparams->addItem({
    weight => 1,
    length => 10,
    width  => 10,
    height => 10,
});

my $response = $mbe->ShippingOptions({
    internalReferenceID => '48147184XTST',
    shippingParameters => $shipparams,
});

use Data::Dump qw/dump/; die dump($response);