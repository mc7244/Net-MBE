# NAME

Net::MBE - Perl library to access Mailboxes Etc (MBE) online webservices.

# SYNOPSIS

    use Net::MBE;

    my $mbe = Net::MBE->new({
        system => 'IT',
        username => 'XXXXX',
        passphrase => 'YYYYYYYY',
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

    use Data::Dump qw/dump/; print dump($response);

# DESCRIPTION

Mailboxes Etc (MBE), formerly a UPS-owned chain of shipping service outlets, is now an Italian
independent company which operates in several european countries.

This library is for accessing their various web services for getting rates, etc.

# METHODS

## new($args)

Constructs the object. It accepts (and requires) 3 arguments.

    my $mbe = Net::MBE->new({
        system     => 'IT',         # 2-eltters ISO code of the country where you signed the agreement
        username   => 'XXXXX',      # Username provided after signing
        passphrase => 'YYYYYYYY',   # Password provided after signing
    });

## ShippingOptions($args)

Get shipping options (i.e. rates) for sending a package. Re quires 2 paramenters:

### Arguments

- internalReferenceID

    A local reference (which you find intact in the response) such as an order code or other type of string.

- shippingParameters

    A [Net::MBE::ShippingParameters](https://metacpan.org/pod/Net%3A%3AMBE%3A%3AShippingParameters) object.

## Shipment($args)

Request a shipment, so that the van passes to pick it up.

### Arguments

- internalReferenceID

    A local reference (which you find intact in the response) such as an order code or other type of string.

- recipient

    A [Net::MBE::Recipient](https://metacpan.org/pod/Net%3A%3AMBE%3A%3ARecipient) object.

- shipment

    A [Net::MBE::Shipment](https://metacpan.org/pod/Net%3A%3AMBE%3A%3AShipment) object.

# AUTHOR

Michele Beltrame, `arthas@cpan.org`

# LICENSE

This library is free software under the Mozilla Public License 2.0.
