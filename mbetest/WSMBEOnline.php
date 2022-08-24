<?php
/*

WSMBEOnline v1.0

Library for accessing MBEs OnlineMBE web services.

Usage:
	
- Create WSMBEOnline object.
- Create needed objects (on some requests).
- Make request.

Example:

require('WSMBEOnline.php');
$ws = new WSMBEOnline('IT','USERNAME', 'PASSPHRASE');
$dest = new DestinationInfo('20159','IT');
$params=new ShippingParameters($dest,'EXPORT', 'GENERIC');
$params->addItem(1, 10, 10, 10);
$params->addItem(2, 15, 10, 20);
$response = $ws->ShippingOptions('alfanumerico-univoco', $params);

- Accessing response data:

echo $response->MasterTrackingMBE;

Debugging:

Passing true as last argument for each request, a string with the request and the
response is returned from the function.

*/

class WSMBEOnline {
	private $system = '';
	private $endpoint = '';
	private $credentials = null;
	private $soapClient = null;

	// Creates a new instance of WSMBEOnline to access OnlineMBE web services.
	// ----------------------------------------------------------------------
	// Parameters:
	// 	$system		->	one of 'IT', 'ES', 'DE', 'FR', AT'. Allows correct
	// 						selection of OnlineMBE instance and endpoint.
	// 	$username	->	as supplied by MBE franchise.
	// 	$passphrase	->	as supplied by MBE franchise.
	public function __construct(
		$system,
		$username,
		$passphrase) 
	{
		if ($system == 'IT') {
			$endpoint = 'https://api.mbeonline.it/ws/e-link.wsdl';
			$this->system = 'IT';
		} else if ($system == 'ES') {
			$endpoint = 'https://api.mbeonline.es/ws/e-link.wsdl';
			$this->system = 'ES';
		} else if ($system == 'DE') {
			$endpoint = 'https://api.mbeonline.de/ws/e-link.wsdl';
			$this->system = 'DE';
		} else if ($system == 'FR') {
			$endpoint = 'https://api.mbeonline.fr/ws/e-link.wsdl';
			$this->system = 'FR';
		} else if ($system == 'PL') {
			$endpoint = 'https://api.mbeonline.pl/ws/e-link.wsdl';
			$this->system = 'PL';
		}
		
		$opts = array(
			'ssl' => array(
				'verify_peer' => false,
				'verify_peer_name' => false,
				'allow_self_signed' => true
			),
			'http' => array(
				'protocol_version' => 1.0
			) 
		);
		$context = stream_context_create($opts);

		$soapClientOptions = array(
			'trace' => 1,
			'stream_context' => $context,
			'login' => $username,
			'password' => $passphrase,
			'location' =>  preg_replace( '/(\/e-link\.wsdl)$/i', '', $endpoint),
			'cache_wsdl' => WSDL_CACHE_NONE
		);

        $this->soapClient = new SoapClient( $endpoint, $soapClientOptions );       

        $this->credentials = array(
            'Username' => '',
            'Passphrase' => '');

	}

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

//// Datatype classes
//
// All datatypes need to be constructed with mandatory fields passed as parameters
// an optional fields can be added later if needed.
//
// Customer
// --------
// To be used with ManageCustomerINSERT request.
// Required info:
//	login, password, storeID, companyName, enabled
class Customer {
	// Mandatory fields
	private $login;
	private $password;
	private $storeID;
	private $enabled;

	// Optional fields
	public $samID = 0;
	public $departmentID = 0;
	public $companyName = '';
	public $customerName = '';
	public $VATNumber = '';
	public $address = '';
	public $ZIPCode = '';
	public $city = '';
	public $state = '';
	public $country = '';
	public $phone = '';
	public $fax = '';
	public $mobile = '';
	public $email = '';

	public $permissions = null;

	public function __construct(
		$login,
		$password,
		$storeID,
		$enabled
	) {
		$this->login = $login;
		$this->password = $password;
		$this->storeID = $storeID;
		$this->enabled = $enabled;
	}

	public function getParams() {
		$params =
			array(
				'Login' => $this->login,
				'Password' => $this->password,
				'StoreID' => $this->storeID,
				'Enabled' => $this->enabled);

		if ($this->permissions != null) {
			$params['Permissions'] = $this->permissions->getParams();
		}

		if ($this->samID != 0) $params['SamID'] = $this->samID;
		if ($this->departmentID != 0) $params['DepartmentID'] = $this->departmentID;
		if ($this->customerName != '') $params['CustomerName'] = $this->customerName;
		if ($this->companyName != '') $params['CompanyName'] = $this->companyName;
		if ($this->VATNumber != '') $params['VATNumber'] = $this->VATNumber;
		if ($this->address != '') $params['Address'] = $this->address;
		if ($this->ZIPCode != '') $params['ZIPCode'] = $this->ZIPCode;
		if ($this->city != '') $params['City'] = $this->city;
		if ($this->state != '') $params['State'] = $this->state;
		if ($this->country != '') $params['Country'] = $this->country;
		if ($this->phone != '') $params['Phone'] = $this->phone;
		if ($this->fax != '') $params['Fax'] = $this->fax;
		if ($this->mobile != '') $params['Mobile'] = $this->mobile;
		if ($this->email != '') $params['Email'] = $this->email;

		return $params;
	}
}

// Permissions
// --------
// To be used with ManageCustomerINSERT request.
class Permissions {
	// Optional fields
	public $canSeeTracking = '';
	public $canSpecifyCOD = false;
	public $maxCODvalue = 0;
	public $canSpecifyInsurance = false;
	public $maxInsuranceValue = false;
	public $canCreateCourierWaybill = false;
	public $canSpecifySaturdayDeliver = false;
	public $canChooseMBEService = false;
	public $canChooseCourier = false;
	public $canChooseCourierService = false;
	public $canViewInvoices = false;
	public $canViewLoyalty = false;
	public $canUploadFiles = false;
	public $canDeleteShipments = false;
	public $enabledCouriers = '';
	public $enabledCouriersServices = '';
	public $canViewPriceList = false;
	public $maxShipmentWeight = 0;
	public $maxParcelWeight = 0;
	public $enabledServices = '';
	public $enabledServicesDesc = '';

	public function getParams() {
		$params = array();
			array(
				'canSeeTracking' => $this->canSeeTracking,
				'canSpecifyCOD' => $this->canSpecifyCOD,
				'maxCODvalue' => $this->maxCODvalue,
				'canSpecifyInsurance' => $this->canSpecifyInsurance,
				'maxInsuranceValue' => $this->maxInsuranceValue,
				'canCreateCourierWaybill' => $this->canCreateCourierWaybill,
				'canSpecifySaturdayDeliver' => $this->canSpecifySaturdayDeliver,
				'canChooseMBEService' => $this->canChooseMBEService,
				'canChooseCourier' => $this->canChooseCourier,
				'canChooseCourierService' => $this->canChooseCourierService,
				'canViewInvoices' => $this->canViewInvoices,
				'canViewLoyalty' => $this->canViewLoyalty,
				'canUploadFiles' => $this->canUploadFiles,
				'canDeleteShipments' => $this->canDeleteShipments,
				'enabledCouriers' => $this->enabledCouriers,
				'enabledCouriersServices' => $this->enabledCouriersServices,
				'canViewPriceList' => $this->canViewPriceList,
				'maxShipmentWeight' => $this->maxShipmentWeight,
				'maxParcelWeight' => $this->maxParcelWeight,
				'enabledServices' => $this->enabledServices,
				'enabledServicesDesc' => $this->enabledServicesDesc);

		return $params;
	}
}

// Recipient
// --------
// To be used with Shipment request.
// Mandatory fields:
//	name, companyname, address, phone, zipcode, city, country, email
class Recipient {
	// Mandatory fields
	private $name;
	private $companyName;
	private $address;
	private $phone;
	private $zipCode;
	private $city;
	private $country;
	private $email;

	// Optional fields
	public $state = '';
	public $subzoneID = 0;
	public $subzoneDesc = '';

	public function __construct(
		$name,
		$companyName,
		$address,
		$phone,
		$zipCode,
		$city,
		$country,
		$email
	) {
		$this->name = $name;
		$this->companyName = $companyName;
		$this->address = $address;
		$this->phone = $phone;
		$this->zipCode = $zipCode;
		$this->city = $city;
		$this->country = $country;
		$this->email = $email;
	}

	public function getParams() {
		$params =
			array(
				'Name' => $this->name,
				'CompanyName' => $this->companyName,
				'Address' => $this->address,
				'Phone' => $this->phone,
				'ZipCode' => $this->zipCode,
				'City' => $this->city,
				'Country' => $this->country,
				'Email' => $this->email);
		
		if ($this->state != '') $params['State'] = $this->state;
		if ($this->subzoneID != 0) $params['SubzoneId'] = $this->subZoneID;
		if ($this->subzoneDesc != 0) $params['SubzoneDesc'] = $this->subZoneDesc;

		return $params;
	}
}

// Shipment
// --------
// To be used with Shipment request.
// Mandatory fields:
//	shipperType, description, COD, insurance, packageType
class Shipment {
	// Mandatory fields
	private $shipperType;
	private $description;
	private $COD;
	private $insurance;
	private $packageType;

	// Optional fields
	public $CODValue = 0;
	public $methodPayment = '';
	public $insuranceValue = 0;
	public $service = '';
	public $courier = '';
	public $courierService = '';
	public $courierAccount = '';
	public $value = 0;
	public $referring = '';
	public $items = array();
	public $products = null;
	public $proformaInvoice = null;
	public $internalNotes = '';
	public $notes = '';
	public $saturdayDelivery = null;
	public $signatureRequired = null;
	public $shipmentOrigin = '';

	public function __construct(
		$shipperType,
		$description,
		$COD,
		$insurance,
		$packageType
	) {
		$this->shipperType = $shipperType;
		$this->description = $description;
		$this->COD = $COD;
		$this->insurance = $insurance;
		$this->packageType = $packageType;
	}

	public function addItem($weight, $length, $height, $width) {
		$this->items[] = (new Item($weight, $length, $height, $width))->getParams();
	}

	public function getParams() {
		$params =
			array(
				'ShipperType' => $this->shipperType,
				'Description' => $this->description,
				'COD' => $this->COD,
				'Insurance' => $this->insurance,
				'PackageType' => $this->packageType,
				'Items' => $this->items);

		if ($this->CODValue != 0) $params['CODValue'] = $this->CODValue;
		if ($this->methodPayment != '') $params['MethodPayment'] = $this->methodPayment;
		if ($this->insuranceValue != 0) $params['InsuranceValue'] = $this->insuranceValue;
		if ($this->service != '') $params['Service'] = $this->service;
		if ($this->courier != '') $params['Courier'] = $this->courier;
		if ($this->courierService != '') $params['CourierService'] = $this->courierService;
		if ($this->courierAccount != '') $params['CourierAccount'] = $this->courierAccount;
		if ($this->value != 0) $params['Value'] = $this->value;
		if ($this->referring != '') $params['Referring'] = $this->referring;
		if ($this->items != array()) $params['Items'] = $this->items;
		if ($this->products != null) $params['Products'] = $this->products;
		if ($this->proformaInvoice != null) $params['ProformaInvoice'] = $this->proformaInvoice;
		if ($this->internalNotes != '') $params['InternalNotes'] = $this->internalNotes;
		if ($this->notes != '') $params['Notes'] = $this->notes;
		if ($this->saturdayDelivery != null) $params['SaturdayDelivery'] = $this->saturdayDelivery;
		if ($this->signatureRequired != null) $params['SignatureRequired'] = $this->signatureRequired;
		if ($this->shipmentOrigin != '') $params['ShipmentOrigin'] = $this->shipmentOrigin;

		return $params;
	}
}

// Item
// --------
// To be used with Shipment and ShippingOptions requests.
//
// This class is not meant to be created directly but thru
// the addItem functions of Shipment and ShippintOptions.
//
// Mandatory fields:
//	weight, length, height, width
class Item {
	private $weight;
	private $length;
	private $height;
	private $width;

	public function __construct($weight, $length, $height, $width) {
		$this->weight = $weight;
		$this->length = $length;
		$this->height = $height;
		$this->width = $width;
	}

	public function getParams() {
		$params =
			array(
				'Weight' => $this->weight,
				'Dimensions' => array(
					'Lenght' => $this->length,
					'Height' => $this->height,
					'Width' => $this->width));

		return $params;
	}
}

// ShippingParameters
// ------------------
// To be used with ShippingOptions request.
// Mandatory fields:
//	destinationInfo, shipType, packageType, items
class ShippingParameters {
	// Mandatory fields
	private $destinationInfo;
	private $shipType;
	private $packageType;
	private $items = array();

	// Optional fields
	public $service = ''; 
	public $courier = '';
	public $courierService = '';
	public $COD = null;
	public $CODValue = 0;
	public $CODPaymentMethod = '';
	public $insurance = null;
	public $insuranceValue = 0;
	public $saturdayDelivery = null;
	public $signatureRequired = null;

	public function __construct(
		$destinationInfo,
		$shipType,
		$packageType
	) {
		$this->destinationInfo = $destinationInfo;
		$this->shipType = $shipType;
		$this->packageType = $packageType;
	}

	public function addItem($weight, $length, $height, $width) {
		$this->items[] = (new Item($weight, $length, $height, $width))->getParams();
	}

	public function getParams() {
		$params = array(
			'DestinationInfo' => $this->destinationInfo->getParams(),
			'ShipType' => $this->shipType,
			'PackageType' => $this->packageType,
			'Items' => $this->items);

		if ($this->service != '') $params['Service'] = $this->service;
		if ($this->courier != '') $params['Courier'] = $this->courier;
		if ($this->courierService != '') $params['CourierService'] = $this->courierService;
		if ($this->COD != null) $params['COD'] = $this->COD;
		if ($this->CODValue != 0) $params['CODValue'] = $this->CODValue;
		if ($this->CODPaymentMethod != '') $params['CODPaymentMethod'] = $this->CODPaymentMethod;
		if ($this->insurance != null) $params['Insurance'] = $this->insurance;
		if ($this->insuranceValue != null) $params['InsuranceValue'] = $this->insuranceValue;
		if ($this->saturdayDelivery != null) $params['SaturdayDelivery'] = $this->saturdayDelivery;
		if ($this->signatureRequired != null) $params['SignatureRequired'] = $this->signatureRequired;

		return $params;
	}
}

// DestinationInfo
// ------------------
// To be used with ShippingOptions request, thru ShippingParameters class.
// Mandatory fields:
//	zipCode, country
class DestinationInfo {
	// Mandatory fields
	private $zipCode;
	private $country;

	// Optional fields
	public $city = '';
	public $state = '';
	public $idSubzone = -1;

	public function __construct(
		$zipCode,
		$country
	) {
		$this->zipCode = $zipCode;
		$this->country = $country;
// $this->state = 'MI';
	}

	public function getParams() {
		$params = array(
			'ZipCode' => $this->zipCode,
			'Country' => $this->country);

		if ($this->city != '') $params['City'] = $this->city;
		if ($this->state != '') $params['State'] = $this->state;
		if ($this->idSubzone != -1) $params['idSubzone'] = $this->idSubzone;

		return $params;
	}
}
