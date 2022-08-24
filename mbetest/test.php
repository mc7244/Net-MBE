<pre>
require('WSMBEOnline.php');
$ws = new WSMBEOnline('IT','NEGOZIOCOLTELLINAI@Italy', 'kGEJ5HzzwjkeMi8pudpLaWD7fX7dn4gZ');
$dest = new DestinationInfo('20159','IT', '', 'PN');
#$dest = new DestinationInfo('E1W','GB', 'London', 'FB');
$params=new ShippingParameters($dest,'EXPORT', 'GENERIC');
$params->addItem(4, 10, 10, 10);
$onum = rand(10000000, 99999999).'XTST';
$response = $ws->ShippingOptions($onum, $params);
echo var_dump($response);
</pre>

<span style="color:red;">
<?php
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
    require('WSMBEOnline.php');
    $ws = new WSMBEOnline('IT','NEGOZIOCOLTELLINAI@Italy', 'kGEJ5HzzwjkeMi8pudpLaWD7fX7dn4gZ');
    $dest = new DestinationInfo('33085','IT', '', 'PN');
    #$dest = new DestinationInfo('E1W','GB', 'London', 'FB');
    $params=new ShippingParameters($dest,'EXPORT', 'GENERIC');
    $params->addItem(1, 10, 10, 10);
    $onum = rand(10000000, 99999999).'XTST';
    //print "ONUM: ".$onum."<br>";
    $response = $ws->ShippingOptions($onum, $params);
    echo "<br>";
    //echo $response->MasterTrackingMBE;
    //echo "<br>";
    echo var_dump($response);
?>
</span>

