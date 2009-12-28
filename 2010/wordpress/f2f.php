<?php
/**
 * @package F2F
 * @author Dan Brickley
 * @version 0.1
 */
/*
Plugin Name: F2F
Plugin URI: http://danbri.org/2010/f2f/
Description: This plugin experimentally exposes a list of trusted OpenIDs. Requires the OpenID plugin. Assumes RDFa and xmlns:foaf are set up in your theme. In my blog it generates a page at http://danbri.org/words/network ... in yours it may delete everything and leak anything private it forgot to delete. Use with care.
See announcement  http://lists.foaf-project.org/pipermail/foaf-dev/2009-December/009963.html
Author: Dan Brickley
Version: 0.1
Author URI: http://danbri.org/
*/

// Reading ...
// http://ditio.net/2007/08/09/how-to-create-wordpress-plugin-from-a-scratch/
// http://phpxref.ftwr.co.uk/wordpress/nav.html?_functions/index.html
// http://codex.wordpress.org/Adding_Administration_Menus
// http://planetozh.com/blog/2008/04/how-to-load-javascript-with-your-wordpress-plugin/
// http://codex.wordpress.org/Function_Reference/get_currentuserinfo
// Goals: http://lists.foaf-project.org/pipermail/foaf-dev/2009-December/009962.html

function f2f_openid_list_rdfa() {
  $req = $_SERVER['REQUEST_URI'];
  $f2f_path = '\/network'; // regex path to trigger addition of markup
				// todo, make an option. see also http://wordpress.org/extend/plugins/exclude-pages/
  $ret = "";

  // Only do anything heavy if we're in the configured pages
  if (preg_match("/$f2f_path/i", $req)) {
   global $wpdb; 
   $css = "position: absolute;
		top: 450px;
		margin: 0;
		padding: 0;
		right: 450px;
		font-size: 12px;
		background: #eeeeee; ";

   $ret = "<!-- Page is $req  -->";
   $q = "SELECT distinct url FROM wp_comments, wp_openid_identities WHERE wp_openid_identities.user_id=wp_comments.user_id AND comment_approved='1' ORDER BY url;";
   $urls = $wpdb->get_results($q);

   $ret .= "<div about='#!aCommentApprovedTrustGroup' typeof='foaf:Group'>\n";
   $blogurl = get_bloginfo('url'); // http://codex.wordpress.org/Function_Reference/get_bloginfo
   $blogname = get_bloginfo('name');
   $ret .= "<span rel='foaf:maker'>Comment acccept list for <a typeof='foaf:Agent' rel='foaf:weblog foaf:account' href='".$blogurl."/'>".$blogurl."</a></span>";

   $ret .=  "<ul style='". $css . "'>\n";
   foreach($urls as $openid)   
    {
      $o = $openid->url;
      $s = "#!ah_" . sha1($o);
      $ret .= "<span rel='foaf:member'><li typeof='foaf:Agent' about='".$s."'><a rel='foaf:openid foaf:account' href='" . $o . "'>" . $o . "</a></li></span>\n";
    }
    $ret .= "</ul>\n";
    $ret .= "</div>\n\n";
  } else {
    $ret = "...";
  }
  return $ret;
}

// This just echoes the chosen line, we'll position it later
function f2f_main() {
	$rdfa = f2f_openid_list_rdfa();
	echo "<div id='f2f'>$rdfa</div>";
}

add_action('wp_footer', 'f2f_main');
?>