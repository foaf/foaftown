<?php
/**
 * @package F2F
 * @author Dan Brickley
 * @version 0.1
 */
/*
Plugin Name: F2F
Plugin URI: http://danbri.org/2010/f2f/
Description: F2F generates an XHTML/RDFa page giving a list of all OpenIDs associated with approved comments on this site.
This plugin experimentally exposes a list of trusted OpenIDs. Requires the OpenID plugin. Assumes RDFa and xmlns:foaf are set up in your theme. 
In my blog it generates a page at http://danbri.org/words/network ... in yours it may delete everything and leak anything private it forgot to delete. Use with care.
Announcement:  http://lists.foaf-project.org/pipermail/foaf-dev/2009-December/009963.html
Available by public SVN: svn co http://svn.foaf-project.org/foaftown/2010/wordpress/f2f/

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





 // ------------------------------------------------------------------
 // Add all your sections, fields and settings during admin_init
 // ------------------------------------------------------------------
 //
 
 function eg_settings_api_init() {
     // Add the section to reading settings so we can add our fields to it
     add_settings_section('eg_setting_section', 'Example settings section in reading', 'eg_setting_section_callback_function', 'reading');
     
     // Add the field with the names and function to use for our new settings, put it in our new section
     add_settings_field('eg_setting_name', 'Example setting Name', 'eg_setting_callback_function', 'reading', 'eg_setting_section');
     
     // Register our setting so that $_POST handling is done for us and our callback function just has to echo the <input>
     register_setting('reading','eg_setting_name');
 }// eg_settings_api_init()
 
 add_action('admin_init', 'eg_settings_api_init');
 
  
 // ------------------------------------------------------------------
 // Settings section callback function
 // ------------------------------------------------------------------
 //
 // This function is needed if we added a new section. This function 
 // will be run at the start of our section
 //
 
 function eg_setting_section_callback_function() {
     echo '<p>Intro text for our settings section</p>';
 }
 
 // ------------------------------------------------------------------
 // Callback function for our example setting
 // ------------------------------------------------------------------
 //
 // creates a checkbox true/false option. Other types are surely possible
 //
 
 function eg_setting_callback_function() {
     $checked = "\";
     
     // Mark our checkbox as checked if the setting is already true
     if (get_option('eg_setting_name')) 
         $checked = \" checked='checked' \";
 
     echo \"<input {$checked} name='eg_setting_name' id='gv_thumbnails_insert_into_excerpt' type='checkbox'
 value='eg_setting_name' class='code' /> Explanation text\";
 } // eg_setting_callback_function()


?>
