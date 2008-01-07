<!--
Name: Matthew Rowe
Description: Creates a FOAF description of an individual and their friends using information extracted from the social networking site Facebook.

Copyright (C) 2007  Matthew Rowe

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
-->

<head>
<link href="css/style1.css" rel="stylesheet" type="text/css" />
</head>
<body>
<center>
<div id="container">
	<table>
		<tr>
			<td><h1>Facebook Foaf Generator</h1></td>
			<td><span class="name">alpha</span></td>
		</tr>
	</table>
	
	<p><a href="http://www.facebook.com">Facebook</a> holds a lot of information about both you and your friends. This tool aims to generate a foaf file containing semantic information about you and your friends according to the latest <a href="http://xmlns.com/foaf/spec/">Foaf</a> specification.</p>
	
	<p>Unlike other Foaf ontologies, the ontology used by the Foaf generator does not use an <a href="http://xmlns.com/foaf/spec/#term_mbox">mbox</a> as a unique identifier of the Person. Instead an snid is used to resolve the unique identification. This is due to the distributed nature of social networks and Facebook restricting their API's ability to retrieve an email address for a particular user. You can download the social networks ontology created to model the distributed nature of social networks <a href="http://www.dcs.shef.ac.uk/~mrowe/ontologies/social-networks.owl">here</a>.</p>
	
	
	<p>Please be patient while the system generates your foaf file.</p>
	
	<input type="button" onClick="javascript: loadFoaf();" value="Get Foaf" class="btn">
	
	<br/>
	<br/>
	
	<div id="output" style="margin-bottom:100px;"></div>
	
	<br/>
	<form method="post" action="http://www.facebook.com/logout.php">
		<input type="hidden" name="confirm" value="1"/>
		<a href=# onClick="this.parentNode.submit(); return false;">Log out of Facebook</a>
	</form>
	
	<span class="footer">Developed by <a href="http://www.dcs.shef.ac.uk/~mrowe/">Matthew Rowe</a> PhD Student, Web Intelligence Group, Department of Computer Science, University of Sheffield.</span>
	</div>
</center>

<script src="http://maps.google.com/maps?file=api&amp;v=2.x&amp;key=ABQIAAAAN7OArsOkoFzmYsyy2pHVKxSwh7JP4PWwHF0FEuVDATHwWvWBhhQ6-t9007jp4j_06LbT3lRYQBcWQA" 
type="text/javascript"></script>
<?php
include_once 'facebook_conf.php';
include_once 'facebookapi_php5_restlib.php';


if ($config['api_key'] == 'YOUR_API_KEY' || $config['secret'] == 'YOUR_SECRET') {
?>
If you have not already, please go to
<a href="http://developers.facebook.com/account.php">http://developers.facebook.com/account.php</a>
and create an api_key, then fill out your api_key and secret in facebook_conf.php.
<?php
  exit;
}

$auth_token = $_REQUEST['auth_token'];
if (!$auth_token) {
  header('Location: '.$config['login_url']);
  exit;
}

try {
  // Create our client object.  
  // This is a container for all of our static information.
  $client = new FacebookRestClient($config['rest_server_addr'], $config['api_key'], $config['secret'], null, false);

  // The required call: Establish session 
  // The session key is saved in the client lib for the whole PHP instance.
  $session_info = $client->auth_getSession($auth_token);
  $uid = $session_info['uid'];


  // Get the entire user profile.
  $user_profile = $client->users_getInfo($uid, $profile_field_array);
  $user_name = $user_profile[0]['name'];

  // Get five of the user's friends.
  $friends_array = array_slice($client->friends_get(),0,1);
  $friends_array = $client->friends_get();
  
  
  // Get the profiles of users' five friends.
  $friend_profiles = $client->users_getInfo($friends_array, $profile_field_array);

} catch (FacebookRestClientException $ex) {
  if (!isset($uid) && $ex->getCode() == FacebookAPIErrorCodes::API_EC_PARAM) {
    // This will happen if auth_getSession fails, which generally means you
    // just hit "reload" on the page with an already-used up auth_token
    // parameter.  Bounce back to facebook to get a fresh auth_token.
    header('Location: '.$config['login_url']);
    exit;
  } else {
    // Developers should probably handle other exceptions in a better way than this.
    throw $ex;
  }
}
?>

<script type="text/javascript">
function loadFoaf() {
if (GBrowserIsCompatible()) {
		//map = new GMap2(document.getElementById("map"));
		//map.setCenter(new GLatLng(37.4419, -122.1419), 13);
		geocoder = new GClientGeocoder();
		
		geocoder.getLatLng("<?php 
			if ($user_profile[0]['current_location']['country'] != "") {
				print $user_profile[0]['current_location']['city'] . ", " . $user_profile[0]['current_location']['country'];
			} else {
				print $user_profile[0]['hometown_location']['city'] . ", " . $user_profile[0]['hometown_location']['country'];
			}
	?>",
	  function(point) {
		if (!point) {
		
		} else {
			// write the lat cookie
			var nextyear = new Date();
			nextyear.setFullYear(nextyear.getFullYear() + 1);
			document.cookie ='lat=' + point.lat() + '; expires=' + nextyear.toGMTString() + '; path=/'
			
			// write the lng cookie
			var nextyear = new Date();
			nextyear.setFullYear(nextyear.getFullYear() + 1);
			document.cookie ='lng=' + point.lng() + '; expires=' + nextyear.toGMTString() + '; path=/'

<?php

$myFile = "files/foaf-" . $user_profile[0]['uid'] . ".rdf";
$fh = fopen($myFile, 'w');

fwrite($fh, "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n");

fwrite($fh, "<!DOCTYPE rdf:RDF [\n");
	fwrite($fh, "\t<!ENTITY rdf \"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">\n");
	fwrite($fh, "\t<!ENTITY rdfs \"http://www.w3.org/2000/01/rdf-schema#\">\n");
	fwrite($fh, "\t<!ENTITY foaf \"http://xmlns.com/foaf/0.1/\">\n");
	fwrite($fh, "\t<!ENTITY base \"http://www.dcs.shef.ac.uk/~mrowe/foaf.rdf#\">\n");
	fwrite($fh, "\t<!ENTITY contact \"http://www.w3.org/2000/10/swap/pim/contact#\">\n");
	fwrite($fh, "\t<!ENTITY ical \"http://www.w3.org/2000/10/swap/pim/ical#\">\n");
	fwrite($fh, "\t<!ENTITY airport \"http://www.daml.org/2001/10/html/airport-ont#\">\n");
	fwrite($fh, "\t<!ENTITY wil \"http://whatilike.org/ontology#\">\n");
fwrite($fh, "]>\n\n");
		

fwrite($fh, "<rdf:RDF\n");
	fwrite($fh, "\txmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n");
    fwrite($fh, "\txmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"\n");
    fwrite($fh, "\txmlns:foaf=\"http://xmlns.com/foaf/0.1/\"\n");
	fwrite($fh, "\txmlns:geo=\"http://www.w3.org/2003/01/geo/wgs84_pos#\"\n");
	fwrite($fh, "\txmlns:sn=\"http://www.dcs.shef.ac.uk/~mrowe/ontologies/social-networks.owl#\"\n");
    fwrite($fh, "\txmlns:admin=\"http://webns.net/mvcb/\">\n\n");
	  
	fwrite($fh, "\t<foaf:PersonalProfileDocument rdf:about=\"\">\n");
		fwrite($fh, "\t\t<foaf:maker rdf:resource=\"#me\"/>\n");
		fwrite($fh, "\t\t<foaf:primaryTopic rdf:resource=\"#me\"/>\n");
		fwrite($fh, "\t\t<admin:generatorAgent rdf:resource=\"http://www.dcs.shef.ac.uk/~mrowe/foafgenerator.html\"/>\n");
		fwrite($fh, "\t\t<admin:errorReportsTo rdf:resource=\"mailto:m.rowe@dcs.shef.ac.uk\"/>\n");
	fwrite($fh, "\t</foaf:PersonalProfileDocument>\n\n");
	
	fwrite($fh, "\t<foaf:Person rdf:ID=\"me\">\n");

		// foaf:name 
		fwrite($fh, "\t\t<foaf:name>" . $user_profile[0]['name'] . "</foaf:name>\n");
		// foaf:givenname
		fwrite($fh, "\t\t<foaf:givenname>" . $user_profile[0]['first_name'] ."</foaf:givenname>\n");
		// foaf:family_name
		fwrite($fh, "\t\t<foaf:family_name>" . $user_profile[0]['last_name'] . "</foaf:family_name>\n");
		// foaf:gender
		fwrite($fh, "\t\t<foaf:gender>" . $user_profile[0]['sex']  . "</foaf:gender>\n");
		// foaf:depiction
		fwrite($fh, "\t\t<foaf:img rdf:resource=\"" . $user_profile[0]['pic'] . "\"/>\n");

		// get the lat and lng
		$lat = $_COOKIE["lat"];
		$lng = $_COOKIE["lng"];

		// use current location
		// only show the the based_near thing is $lat and $lng are not blank
		if (($lat != "") && ($lng != "")) {
			fwrite($fh, "\t\t<foaf:based_near>\n");		
			fwrite($fh, "\t\t\t<geo:Point geo:lat=\"" . $lat . "\" geo:long=\"" . $lng . "\"/>\n");
			fwrite($fh, "\t\t</foaf:based_near>\n");
		}


		// foaf:OnlineAccount
		fwrite($fh, "\t\t<foaf:holdsAccount>\n");
    		fwrite($fh, "\t\t\t<foaf:OnlineAccount>\n");
      			fwrite($fh, "\t\t\t\t<foaf:accountServiceHomepage rdf:resource=\"http://www.facebook.com/\" />\n");
      			fwrite($fh, "\t\t\t\t<foaf:accountName>" . $user_profile[0]['uid'] . "</foaf:accountName>\n");
    		fwrite($fh, "\t\t\t</foaf:OnlineAccount>\n");
  		fwrite($fh, "\t\t</foaf:holdsAccount>\n");
  
  
  		// sn:SocialNetwork
  		/*
		fwrite($fh, "\t\t<sn:SocialNetwork>\n");
			fwrite($fh, "\t\t\t<sn:Facebook>\n");
				fwrite($fh, "\t\t\t\t<sn:userId_sha1>" . sha1($user_profile[0]['uid']) . "</sn:userId_sha1>\n");
			fwrite($fh, "\t\t\t</sn:Facebook>\n");
		fwrite($fh, "\t\t</sn:SocialNetwork>\n");
		*/

		// foaf:interest
		$interest = strtok($user_profile[0]['interests'],",");
		while ($interest != false) {
			fwrite($fh, "\t\t<foaf:interest>" . trim($interest) . "</foaf:interest>\n");
			$interest = strtok(",");
		}
		
		fwrite($fh, "\n");
		
		// foaf:knows
		foreach ($friend_profiles as $id => $profile) {
			fwrite($fh, "\t\t<foaf:knows>\n");
				fwrite($fh, "\t\t\t<foaf:Person>\n");
					//foaf:name
					fwrite($fh, "\t\t\t\t<foaf:name>" . $profile['name'] . "</foaf:name>\n");
					
					// foaf:givenname
					fwrite($fh, "\t\t\t\t<foaf:givenname>" . $profile['first_name'] . "</foaf:givenname>\n");
					
					// foaf:family_name
					fwrite($fh, "\t\t\t\t<foaf:family_name>" . $profile['last_name'] . "</foaf:family_name>\n");
					
					// foaf:depiction
					fwrite($fh, "\t\t\t\t<foaf:img rdf:resource=\"" . $profile['pic'] . "\"/>\n");
					
					// foaf:OnlineAccount
					fwrite($fh, "\t\t\t\t<foaf:holdsAccount>\n");
						fwrite($fh, "\t\t\t\t\t<foaf:OnlineAccount>\n");
							fwrite($fh, "\t\t\t\t\t\t<foaf:accountServiceHomepage rdf:resource=\"http://www.facebook.com/\" />\n");
							fwrite($fh, "\t\t\t\t\t\t<foaf:accountName>" . $profile['uid'] . "</foaf:accountName>\n");
						fwrite($fh, "\t\t\t\t\t</foaf:OnlineAccount>\n");
					fwrite($fh, "\t\t\t\t</foaf:holdsAccount>\n");
					
					// sn:socialNetwork
					/*
					fwrite($fh, "\t\t\t\t<sn:SocialNetwork>\n");
						fwrite($fh, "\t\t\t\t\t<sn:Facebook>\n");
							fwrite($fh, "\t\t\t\t\t\t<sn:userId_sha1>" . sha1($profile['uid']) . "</sn:userId_sha1>\n");
						fwrite($fh, "\t\t\t\t\t</sn:Facebook>\n");
					fwrite($fh, "\t\t\t\t</sn:SocialNetwork>\n");
					*/
					
				fwrite($fh, "\t\t\t</foaf:Person>\n");
			fwrite($fh, "\t\t</foaf:knows>\n");
		}
	
	fwrite($fh, "\n\t</foaf:Person>\n");
fwrite($fh, "</rdf:RDF>\n");

fclose($fh);

?>
		halt();
		
		}
	  }
	);
	}
}

function halt() {
	if (navigator.appName == "Netscape") {
		window.stop();	
	} else {
		document.execCommand('Stop');
	}
		//alert("<?php print $myFile; ?>");
		document.getElementById('output').innerHTML = "Download your foaf file <a href=\"<?php print $myFile; ?>\">here</a>.";
}
</script>

</body>
</html>