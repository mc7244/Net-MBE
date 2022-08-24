package Net::MBE {
    use Moo;
    use namespace::clean;
    use SOAP::Lite +trace => [ qw/all -objects/ ];
    use MIME::Base64;
    use HTTP::Headers;
    use Arthas::Defaults::536;

	#$SOAP::Constants::DEFAULT_HTTP_CONTENT_TYPE = 'text/xml';
	#$SOAP::Constants::DO_NOT_USE_CHARSET = 1;

    #sub LWP::UserAgent::get_basic_credentials {
    sub SOAP::Transport::HTTP::Client::get_basic_credentials {
        #return 'NEGOZIOCOLTELLINAI@Italy' => 'kGEJ5HzzwjkeMi8pudpLaWD7fX7dn4gZ';
        warn "\n\nAAAA: @_\n";
    }

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
                    'Authorization', 'Basic '.encode_base64($args->{Username} . ':' . $args->{Passphrase})
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
		#$soapClient->register_ns('','xsd');

        $class->soapClient($soapClient);
        $class->credentials({'Username' => '', Passphrase => ''});
	}

	# ShippingOptionsRequest
	# ----------------------
	# Gets shipping options for an indicated shipment parameters.
	#	$internalReferenceID	->	string that is returned as is by the server.
	#	$shippingParameters		->	object of type ShippingParameters with all
	#									the required info.
	sub ShippingOptions($self, $args) {
		# $internalReferenceID,
		# $shippingParameters,
		croak 'Invalid-InternalReferenceID' if !$args->{InternalReferenceID};

        my $params = SOAP::Data->name('RequestContainer' => \SOAP::Data->value(
            SOAP::Data->name('System' => $self->system),
            SOAP::Data->name('Credentials' => \SOAP::Data->value(
                SOAP::Data->name('Username' => ''),
                SOAP::Data->name('Passphrase' => ''),
            )),
            SOAP::Data->name('InternalReferenceID', $args->{InternalReferenceID}),
            SOAP::Data->name('ShippingParameters' => \SOAP::Data->value(
                SOAP::Data->name('DestinationInfo' => \SOAP::Data->value(
                    SOAP::Data->name('ZipCode' => '33085'),
                    SOAP::Data->name('Country' => 'IT'),
                )),
                SOAP::Data->name('ShipType', 'EXPORT'),
                SOAP::Data->name('PackageType', 'GENERIC'),
                SOAP::Data->name('Items' => \SOAP::Data->value(
                    SOAP::Data->name('Item' =>  \SOAP::Data->value(
                        SOAP::Data->name('Weight', '1'),
                        SOAP::Data->name('Dimensions' =>  \SOAP::Data->value(
                            SOAP::Data->name('Lenght', '10'),
                            SOAP::Data->name('Height', '10'),
                            SOAP::Data->name('Width', '10'),
                        )),
                    )),
                )),
            )),
        ));

		# my $params = array(
		# 	'RequestContainer' =>array(
		# 		'System' => $this->system,
		# 		'Credentials' => $this->credentials,
		# 		'InternalReferenceID' => $internalReferenceID,
		# 		'ShippingParameters' => $shippingParameters->getParams()));

        my $som = $self->soapClient->call("ShippingOptionsRequest", $params);
        use Data::Dump qw/dump/; die dump($som);
        # die $som->fault->{ faultstring } if ($som->fault);
        # print $som->result, "\n";


		# $response = 
		# 	$this->soapClient
		# 		->ShippingOptionsRequest($params);

		# if ($debug) {
		# 	return 
		# 		'Request : ' . 
		# 		htmlentities($this->soapClient->__getLastRequest()) . 
		# 		'Response: <br/>' . 
		# 		var_dump($response->RequestContainer);
		# } else {
		# 	return $response->RequestContainer;
		# }

	}
=pod 

	// SOAP Operations

	// AddAtachmentRequest
	// -------------------
	// Attaches one or more files to a shipment.
	//	$internalReferenceId	->	string that will be returned as is
	//	$MOS					->	MBE shipment tracking number to which
	//									attach files.
	//	$filenames				->	a string or an array of string containing
	//									the names of the files to be attached
	public function AddAttachment(
		$internalReferenceId,
		$MOS,
		$filenames,
		$debug = false)
	{
		$request_container = array();
		$request_container[] = new SoapVar($this->credentials, SOAP_ENC_OBJECT, null, null, 'Credentials');
		$request_container[] = new SoapVar($internalReferenceId, XSD_STRING, null, null, 'InternalReferenceID');
		$request_container[] = new SoapVar($MOS, XSD_STRING, null, null, 'MasterTrackingMBE');

		if (!is_array($filenames)) $filenames = array($filenames);

		foreach($filenames as $filename) {
			$file = fopen($filename, "rb");
			$filedata = fread($file, filesize($filename));
			if ($filedata === false) {
				return false;
			} else {
				$attachment = array(
					'AttachmentName' => basename($filename),
					'AttachmentData' => base64_encode($filedata));
		
				$request_container[] = new SoapVar($attachment, SOAP_ENC_OBJECT, null, null, 'Attachment');
			}
			fclose($file);
		}

		$params = array();
		$params[] = new SoapVar($request_container, SOAP_ENC_OBJECT, null, null, 'RequestContainer');

		$response = 
			$this->soapClient
				->AddAttachmentRequest(
					new SoapVar($params, SOAP_ENC_OBJECT));

		if ($debug) {
			return 
				'Request : ' . 
				htmlentities($this->soapClient->__getLastRequest()) . 
				'Response: <br/>' . 
				var_dump($response->RequestContainer);
		} else {
			return $response->RequestContainer;
		}
	}

	// CloseShipmentsRequest
	// ---------------------
	// Activates procedure of closing some shipments, indicated by their MBE tracking numbers.
	//	$internalReferenceId	->	string that will be returned as is
	//	$masterTrackings is a string or an array of strings
	//					 containing the MOS of shipments to
	//					 be closed.
	public function CloseShipments(
		$internalReferenceId,
		$masterTrackings,
		$debug = false)
	{
		$request_container = array();
		$request_container[] = new SoapVar($this->system, XSD_STRING, null, null, 'SystemType');
		$request_container[] = new SoapVar($this->credentials, SOAP_ENC_OBJECT, null, null, 'Credentials');
		$request_container[] = new SoapVar($internalReferenceId, XSD_STRING, null, null, 'InternalReferenceID');

		if (!is_array($masterTrackings)) $masterTrackings = array($masterTrackings);

		foreach($masterTrackings as $masterTracking) {
			$request_container[] = new SoapVar($masterTracking, XSD_STRING, null, null, 'MasterTrackingsMBE');
		}

		$params = array();
		$params[] = new SoapVar($request_container, SOAP_ENC_OBJECT, null, null, 'RequestContainer');

		$response = 
			$this->soapClient
				->CloseShipmentsRequest(
					new SoapVar($params, SOAP_ENC_OBJECT));

		if ($debug) {
			return 
				'Request : ' . 
				htmlentities($this->soapClient->__getLastRequest()) . 
				'Response: <br/>' . 
				var_dump($response->RequestContainer);
		} else {
			return $response->RequestContainer;
		}
	}

	// CustomersListRequest
	// --------------------
	// For franchises, get a list of customers of some store.
	//	$internalReferenceId	->	string that will be returned as is
	//	$storeID				->	store code number
	public function CustomersList(
		$internalReferenceID,
		$storeID,
		$debug = false)
	{	
		$params = array(
			'RequestContainer' => array(
				'Credentials' => $this->credentials,
				'InternalReferenceID' => $internalReferenceID,
				'StoreID' => $storeID));

		$response =
			$this->soapClient
				->CustomersListRequest($params);

		if ($debug) {
			return 
				'Request : ' . 
				htmlentities($this->soapClient->__getLastRequest()) . 
				'Response: <br/>' . 
				var_dump($response->RequestContainer);
		} else {
			return $response->RequestContainer;
		}
	}

	// DeleteShipments
	// ---------------
	// Delete shipments indicated by their MBE tracking numbers.
	//	$internalReferenceId	->	string that will be returned as is
	//	$masterTrackings		->	is a string or an array of strings
	//									containing the MOS of shipments to
	//									be closed.
	public function DeleteShipments(
		$internalReferenceID,
		$masterTrackings,
		$debug = false)
	{
		$request_container = array();
		$request_container[] = new SoapVar($this->system, XSD_STRING, null, null, 'SystemType');
		$request_container[] = new SoapVar($this->credentials, SOAP_ENC_OBJECT, null, null, 'Credentials');
		$request_container[] = new SoapVar($internalReferenceID, XSD_STRING, null, null, 'InternalReferenceID');

		if (!is_array($masterTrackings)) $masterTrackings = array($masterTrackings);

		foreach($masterTrackings as $masterTracking) {
			$request_container[] = new SoapVar($masterTracking, XSD_STRING, null, null, 'MasterTrackingsMBE');
		}

		$params = array();
		$params[] = new SoapVar($request_container, SOAP_ENC_OBJECT, null, null, 'RequestContainer');

		$response = 
			$this->soapClient
				->DeleteShipmentsRequest(
					new SoapVar($params, SOAP_ENC_OBJECT));

		if ($debug) {
			return 
				'Request : ' . 
				htmlentities($this->soapClient->__getLastRequest()) . 
				'Response: <br/>' . 
				var_dump($response->RequestContainer);
		} else {
			return $response->RequestContainer;
		}
	}

	// ListDepartmentsRequest
	// ----------------------
	// List defined departments for indicated customer.
	//	$internalReferenceId	->	string that will be returned as is.
	//	$customerID				->	ID of customer as given by MBE franchise.
	public function ListDepartments(
		$internalReferenceID,
		$customerID,
		$debug = false)
	{
		$params = array(
			'RequestContainer' => array(
				'Credentials' => $this->credentials,
				'InternalReferenceID' => $internalReferenceID,
				'CustomerID' => $customerID));

		$response = 
			$this->soapClient
				->ListDepartmentsRequest($params);

		if ($debug) {
			return 
				'Request : ' . 
				htmlentities($this->soapClient->__getLastRequest()) . 
				'Response: <br/>' . 
				var_dump($response->RequestContainer);
		} else {
			return $response->RequestContainer;
		}
	}

	// ManageCustomerGET
	// -----------------
	// Makes a call to ManageCustomer with GET action.
	//	$internalReferenceId	->	string that will be returned as is.
	//	$customerID				->	id of customer as given by MBE franchise.
	public function ManageCustomerGET(
		$internalReferenceID,
		$customerID,
		$debug = false)
	{
		$params = array(
			'RequestContainer' => array(
				'SystemType' => $this->system,
				'Credentials' => $this->credentials,
				'InternalReferenceID' => $internalReferenceID,
				'Action' =>'GET',
				'CustomerID' => $customerID,
				'Customer' => ''));

		$response = 
			$this->soapClient
				->ManageCustomerRequest($params);

		if ($debug) {
			return 
				'Request : ' . 
				htmlentities($this->soapClient->__getLastRequest()) . 
				'Response: <br/>' . 
				var_dump($response->RequestContainer);
		} else {
			return $response->RequestContainer;
		}
	}


	// ManageCustomerINSERT
	// --------------------
	// Makes a call to ManageCustomer with INSERT action.
	//	$internalReferenceId	->	string that will be returned as is.
	//	$customer				->	object of type Customer with required info.
	public function ManageCustomerINSERT(
		$internalReferenceID,
		$customer,
		$debug = false)
	{
		$params = array(
			'RequestContainer' => array(
				'SystemType' => $this->system,
				'Credentials' => $this->credentials,
				'InternalReferenceID' => $internalReferenceID,
				'Action' =>'INSERT',
				'Customer' => $customer->getParams()));

		$response = 
			$this->soapClient
				->ManageCustomerRequest($params);

		if ($debug) {
			return 
				'Request : ' . 
				htmlentities($this->soapClient->__getLastRequest()) . 
				'Response: <br/>' . 
				var_dump($response->RequestContainer);
		} else {
			return $response->RequestContainer;
		}
	}

	// ShipmentRequest
	// ---------------
	//	$internalReferenceId	->	string that will be returned as is.
	//	$recipient				->	Object of type Recipient with required info.
	//	$shipment				->	Object of type Shipment with required info.
	public function Shipment(
		$internalReferenceID,
		$recipient,
		$shipment,
		$debug = false)
	{
		$params = array(
			'RequestContainer' => array(
				'System' => $this->system,
				'Credentials' => $this->credentials,
				'InternalReferenceID' => $internalReferenceID,
				'Recipient' => $recipient->getParams(),
				'Shipment' => $shipment->getParams()));

		$response = 
			$this->soapClient
				->ShipmentRequest($params);

		if ($debug) {
			return 
				'Request : ' . 
				htmlentities($this->soapClient->__getLastRequest()) . 
				'Response: <br/>' . 
				var_dump($response->RequestContainer);
		} else {
			return $response->RequestContainer;
		}
	}

	// ShippingOptionsRequest
	// ----------------------
	// Gets shipping options for an indicated shipment parameters.
	//	$internalReferenceID	->	string that is returned as is by the server.
	//	$shippingParameters		->	object of type ShippingParameters with all
	//									the required info.
	public function ShippingOptions(
		$internalReferenceID,
		$shippingParameters,
		$debug = false)
	{
		$params = array(
			'RequestContainer' =>array(
				'System' => $this->system,
				'Credentials' => $this->credentials,
				'InternalReferenceID' => $internalReferenceID,
				'ShippingParameters' => $shippingParameters->getParams()));

		$response = 
			$this->soapClient
				->ShippingOptionsRequest($params);

		if ($debug) {
			return 
				'Request : ' . 
				htmlentities($this->soapClient->__getLastRequest()) . 
				'Response: <br/>' . 
				var_dump($response->RequestContainer);
		} else {
			return $response->RequestContainer;
		}

	}

	// TrackingRequest
	// ---------------
	// Gets tracking information from a shipment.
	//	$internalReferenceID	->	string for reference returned as is.
	//	$trackingMBE			->	MBE tracking number off the shipment to
	//									get tracking info about.
	public function Tracking(
		$internalReferenceID,
		$trackingMBE,
		$debug = false
	) {
		$params = array(
			'RequestContainer' => array(
				'System' => $this->system,
				'Credentials' => $this->credentials,
				'InternalReferenceID' => $internalReferenceID,
				'TrackingMBE' => $trackingMBE));

		$response =
			$this->soapClient
				->TrackingRequest($params);

		if ($debug) {
			return
				'Request : ' .
				htmlentitites($this->soapClient->__getLastRequest()) .
				'Response: <br/>' .
				var_dump($response->RequestContainer);
		} else {
			return $response->RequestContainer;
		}
	}
}
=cut

}

1;