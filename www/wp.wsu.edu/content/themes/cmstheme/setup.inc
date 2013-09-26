<?php 
	require_once 'lib/XML/RPC.php';
	require_once 'settings.inc';
	
	//$soapendpoint = "http://" . $CMSServer . "/edit/SoapService.asmx?wsdl";
	$soapendpoint = "http://publishing.wsu.edu/edit/SoapService.asmx?wsdl"; 	
	$client = new SoapClient($soapendpoint, array("trace" => 1, "exceptions" => 1)); 
	$arr = $client->getTemplate(array('title'=> "$CMSTitle", 'templateid'=> $CMSTemplateID, 'regionlist'=>$CMSRegions, 'currenturl'=>"$CMSUrls",'siteid'=>1,'variables'=>""));
	$result = $arr->getTemplateResult->string;
	$before = $result[0];
	$sidebar = $result[1];
	$after = $result[2];
?>
