<?php
/**
 * This file contains stuff that may be different for each platform developer.
 */

/**
 * SAMPLE API keys
 * These should be generated from your trip to
 * http://developers.facebook.com/account.php
 */
$config['api_key'] = "<INSERT API KEY>";
$config['secret'] = "<INSERT SECRET KEY>";

/**
 * This assumes your registered callback URL is, say, http://www.myapplication.com/
 * The page which would serve as an after-login entrypoint into your app would 
 * be the "next" parameter passed to login (below, "login_url"), appended to
 * your callback URL.  So the full address would be http://www.myapplication.com/facebook/sample_client.php
 */
$config['next'] = urlencode('');

$config['debug'] = 0; // switch to 0 to disable debug output

$config['login_server_base_url'] = 'http://www.facebook.com';
$config['login_url'] = $config['login_server_base_url'].'/login.php?v=1.0' .
                       '&next=' . $config['next'] . '&api_key=' . $config['api_key'];

$config['api_server_base_url'] = 'http://api.facebook.com';
$config['rest_server_addr'] = $config['api_server_base_url'].'/restserver.php';

?>
