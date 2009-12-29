<?php
/**
 * @package F2F
 * @author Dan Brickley
 * @version 0.5
 */
/*
Plugin Name: F2F
Plugin URI: http://wiki.foaf-project.org/w/F2FPlugin
Description: F2F generates an XHTML/RDFa page giving a list of all OpenIDs associated with approved comments on this site.
This plugin experimentally exposes a list of trusted OpenIDs. Requires the OpenID plugin. Preferably you theme will use RDFa DTD or at least XHTML.
In my blog it generates a page at http://danbri.org/words/network ... in yours it may delete everything and leak anything private it forgot to delete. Use with care.
See wiki documentation for installation instructions and more details about the project. Thanks to Morten Høybye Frederiksen for a rewrite to use wordpress shortcodes. Add a page /network and put the string [f2f] in the content to publish your openid list.

Author: Dan Brickley
Version: 0.5
Author URI: http://danbri.org/
*/

/*
  f2f_openid_list_rdfa: Generate list of OpenIDs as RDFa.
*/
function f2f_openid_list_rdfa() {
  global $wpdb; 
  $ret = "<div about='#!aCommentApprovedTrustGroup' typeof='foaf:Group' xmlns:foaf='http://xmlns.com/foaf/0.1/'>\n";
    if (class_exists('WordPress_OpenID_OptionStore')) {
    $q = "SELECT distinct url FROM wp_comments, wp_openid_identities WHERE wp_openid_identities.user_id=wp_comments.user_id AND comment_approved='1' ORDER BY url;";
    $urls = $wpdb->get_results($q);
    $blogurl = get_bloginfo('url'); // http://codex.wordpress.org/Function_Reference/get_bloginfo
    $blogname = get_bloginfo('name');
    $ret .= "<span rel='foaf:maker'>Comment accept list for <a typeof='foaf:Agent' rel='foaf:weblog foaf:account' href='".$blogurl."/'>".$blogurl."</a></span>";
    $ret .=  "<ul style='". $css . "'>\n";
    foreach($urls as $openid) {
      $o = $openid->url;
      $s = "#!ah_" . sha1($o);
      $ret .= "<span rel='foaf:member'><li typeof='foaf:Agent' about='".$s."'><a rel='foaf:openid foaf:account' href='" . $o . "'>" . $o . "</a></li></span>\n";
    }
    $ret .= "</ul>\n";
  }
  $ret .= "</div>\n\n";
  return $ret;
}

/*
  f2f_shortcode: Insert list of OpenIDs as RDFa in content (use: "[f2f]" in page or post content/text)
*/
if (function_exists('add_shortcode')) {
function f2f_shortcode($atts, $content=null) {
  return '<div xmlns:foaf="http://xmlns.com/foaf/0.1/">' . f2f_openid_list_rdfa() . '</div>';
}
add_shortcode( 'f2f', 'f2f_shortcode' );
}
 
// EOF
