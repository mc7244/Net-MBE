package Net::MBE {
    use Moo;
    use namespace::clean;
    use Net::MBE::DestinationInfo;
    use Net::MBE::Item;
    use Net::MBE::Recipient;
    use Net::MBE::ShippingOption;
    use Net::MBE::ShippingOptionsResponse;
    use Net::MBE::ShippingParameters;
    use SOAP::Lite;
    #use SOAP::Lite +trace => [ qw/all -objects/ ];
    use MIME::Base64;
    use HTTP::Headers;
    use Data::Dump;
    use Arthas::Defaults::520;
    use version;

    our $VERSION = qv("v0.3.0");

	#$SOAP::Constants::DEFAULT_HTTP_CONTENT_TYPE = 'text/xml';
	#$SOAP::Constants::DO_NOT_USE_CHARSET = 1;

	has system => ( is => 'rw' );
	has endpoint => ( is => 'rw' );
	has credentials => ( is => 'rw' );
	has soapClient => ( is => 'rw' );
    
	# Creates a new instance of WSMBEOnline to access OnlineMBE web services.
	# ----------------------------------------------------------------------
	# Parameters:
	# 	$system		->	one of 'IT', 'ES', 'DE', 'FR', AT'. Allows correct
	# 						selection of OnlineMBE instance and endpoint.
	# 	$username	->	as supplied by MBE franchise.
	# 	$passphrase	->	as supplied by MBE franchise.
	sub BUILD($class, $args) {
		if ($args->{system} eq 'IT') {
			$class->endpoint( 'https://api.mbeonline.it/ws/e-link.wsdl' );
		} elsif ($args->{system} eq 'ES') {
			$class->endpoint( 'https://api.mbeonline.es/ws/e-link.wsdl' );
		} elsif ($args->{system} eq 'DE') {
			$class->endpoint( 'https://api.mbeonline.de/ws/e-link.wsdl' );
		} elsif ($args->{system} eq 'FR') {
			$class->endpoint( 'https://api.mbeonline.fr/ws/e-link.wsdl' );
		} elsif ($args->{system} eq 'PL') {
			$class->endpoint( 'https://api.mbeonline.pl/ws/e-link.wsdl' );
		}
		
        #use Data::Dump qw/dump/; die dump($args->{Username}, $args->{Passphrase});

        my $proxy = $class->{endpoint} =~ s/(\/e-link\.wsdl)$//xsr;
        my $soapClient = SOAP::Lite->new(
            readable   => 0,
            proxy => [
                $proxy,
                # credentials => [
                #     'api.mbeonline.it:443',
                #     undef,
                #     $args->{Username},
                #     $args->{Passphrase},
                # ],
                default_headers => HTTP::Headers->new(
                    'Content-type', 'text/xml; charset=utf-8', # MBE won't accept application/soap
                    'Authorization', 'Basic '.encode_base64($args->{username} . ':' . $args->{passphrase})
                ),
            ],
            #wsdl => $args->{endpoint},
        );

		# Server seems to only support 1.1, or at least only text/xml as content type
        $soapClient->soapversion('1.1');
        $soapClient->serializer->soapversion('1.1');

		$soapClient->ns('http://schemas.xmlsoap.org/soap/envelope/', 'SOAP-ENV');
        $soapClient->ns('http://www.onlinembe.eu/ws/','ns1');
        $soapClient->envprefix('SOAP-ENV');
        $soapClient->autotype(0);

        $class->soapClient($soapClient);
        $class->credentials({'Username' => '', Passphrase => ''});
	}

	sub ShippingOptions($self, $args) {
		croak 'Invalid-internalReferenceID' if !$args->{internalReferenceID};

        my $params = SOAP::Data->name('RequestContainer' => \SOAP::Data->value(
            SOAP::Data->name('System' => $self->system),
            SOAP::Data->name('Credentials' => \SOAP::Data->value(
                SOAP::Data->name('Username' => ''),
                SOAP::Data->name('Passphrase' => ''),
            )),
            SOAP::Data->name('InternalReferenceID', $args->{internalReferenceID}),
			SOAP::Data->name('ShippingParameters' => $args->{shippingParameters}->getSoapParams()),
        ));

        my $res = $self->_soapCall("ShippingOptions", $params);
        if ( $res->{ShippingOptions} ) {
            my @sos;
            my $so = $res->{ShippingOptions}->{ShippingOption};  # TODO/FIXME: if multiple??
            push @sos, Net::MBE::ShippingOption->new($so);
            return Net::MBE::ShippingOptionsResponse->new({ shippingOptions => \@sos });
        }
        return $res;
	}

	sub Shipment($self, $args) {
        croak 'Invalid-internalReferenceID' if !$args->{internalReferenceID};
        croak 'Invalid-recipient' if !$args->{recipient};
        croak 'Invalid-shipment' if !$args->{shipment};

        my $params = SOAP::Data->name('RequestContainer' => \SOAP::Data->value(
            SOAP::Data->name('System' => $self->system),
            SOAP::Data->name('Credentials' => \SOAP::Data->value(
                SOAP::Data->name('Username' => ''),
                SOAP::Data->name('Passphrase' => ''),
            )),
            SOAP::Data->name('InternalReferenceID', $args->{internalReferenceID}),
			SOAP::Data->name('Recipient' => $args->{recipient}->getSoapParams()),
			SOAP::Data->name('Shipment' => $args->{shipment}->getSoapParams()),
        ));

        my $res = $self->_soapCall("Shipment", $params);
        croak Data::Dump::dump($res); # TODO: make a general fault object
	}

    sub _soapCall($self, $soapmethod, $params) {
        my $som = $self->soapClient->call($soapmethod.'Request', $params);
		confess 'Invalid-request (forgotted or invalid credentals maybe?)' if !$som;
    	confess 'Request error: '.$som->fault->{ faultstring } if $som->fault;
		return $som->body->{$soapmethod.'RequestResponse'}->{RequestContainer};
    }
}

1;

=head1 NAME

Net::MBE - Perl library to access Mailboxes Etc (MBE) online webservices.

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Mailboxes Etc (MBE), formerly a UPS-owned chain of shipping service outlets, is now an Italian
independent company which operates in several european countries.

This library is for accessing their various web services for getting rates, etc.

=head1 METHODS

=head2 new($args)

Constructs the object. It accepts (and requires) 3 arguments.

    my $mbe = Net::MBE->new({
        system     => 'IT',         # 2-eltters ISO code of the country where you signed the agreement
        username   => 'XXXXX',      # Username provided after signing
        passphrase => 'YYYYYYYY',   # Password provided after signing
    });

=head2 ShippingOptions($args)

Get shipping options (i.e. rates) for sending a package. Re quires 2 paramenters:

=head3 Arguments

=over

=item internalReferenceID

A local reference (which you find intact in the response) such as an order code or other type of string.

=item shippingParameters

A L<Net::MBE::ShippingParameters> object.

=back

=head2 Shipment($args)

Request a shipment, so that the van passes to pick it up.

=head3 Arguments

=over

=item internalReferenceID

A local reference (which you find intact in the response) such as an order code or other type of string.

=item recipient

A L<Net::MBE::Recipient> object.

=item shipment

A L<Net::MBE::Shipment> object.

=back

=head1 AUTHOR

Michele Beltrame, C<arthas@cpan.org>

=head1 LICENSE

This library is free software under the Mozilla Public License 2.0.

=cut