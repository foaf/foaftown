<?php
/**
 * @package F2F
 * @author Dan Brickley
 * @version 0.2
 */
/*
Plugin Name: F2F
Plugin URI: http://wiki.foaf-project.org/w/F2FPlugin
Description: F2F generates an XHTML/RDFa page giving a list of all OpenIDs associated with approved comments on this site.
This plugin experimentally exposes a list of trusted OpenIDs. Requires the OpenID plugin. Assumes RDFa and xmlns:foaf are set up in your theme. 
In my blog it generates a page at http://danbri.org/words/network ... in yours it may delete everything and leak anything private it forgot to delete. Use with care.

Author: Dan Brickley
Version: 0.2
Author URI: http://danbri.org/
*/

function f2f_openid_list_rdfa() {
  $req = $_SERVER['REQUEST_URI'];

  $f2f_path = '\/network'; // regex path to trigger addition of markup

				// todo, make an option. see also http://wordpress.org/extend/plugins/exclude-pages/
  $ret = "";

  // Only do anything heavy if we're in the configured pages
  if (preg_match("/$f2f_path/i", $req)) {
   global $wpdb; 
   $css = "position: absolute; top: 450px; margin: 0; padding: 0; right: 450px; font-size: 12px; background: #eeeeee; ";
   $ret = "<!-- Page is $req  -->";
   $q = "SELECT distinct url FROM wp_comments, wp_openid_identities WHERE wp_openid_identities.user_id=wp_comments.user_id AND comment_approved='1' ORDER BY url;";
   $urls = $wpdb->get_results($q);
   $ret .= "<div about='#!aCommentApprovedTrustGroup' typeof='foaf:Group' xmlns:foaf='http://xmlns.com/foaf/0.1/'>\n";
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
