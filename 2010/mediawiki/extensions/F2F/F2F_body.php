<?php
class F2F extends SpecialPage

# see also http://www.mediawiki.org/wiki/Manual:$wgOut

{
    function F2F() {
        SpecialPage::SpecialPage("F2F");
        # the standard method for LoadingExtensionMessages was apparently broken in several versions of MW
        # so, to make this work with multiple versions of MediaWiki, let's load the messages nicely
        if (function_exists('wfLoadExtensionMessages'))
            wfLoadExtensionMessages( 'UserStats' );
        else
            self::loadMessages();
        return true;
    }
    # copied from original userstats addon.
    function loadMessages() {
        static $messagesLoaded = false;
        global $wgMessageCache;
        if ( !$messagesLoaded ) {
            $messagesLoaded = true;
            require( dirname( __FILE__ ) . '/F2F.i18n.php' );
            foreach ( $messages as $lang => $langMessages ) {
                $wgMessageCache->addMessages( $langMessages, $lang );
            }
        }
        return true;
    }

    function execute( $par ) {
        global $wgRequest, $wgOut, $wgUser;
        $this->setHeaders();
        $wgOut->setPagetitle('F2F');
        $user = $wgUser->getName();
        $wgOut->addWikiText("Logged in as " . $user);
        $u = array();
        $sitehome = "http://wiki.foaf-project.org/";
        $wgOut->addWikiText( "This is the [http://wiki.foaf-project.org/w/F2FMediawikiPlugin F2F Mediawiki extension]");

	$wgOut->addHTML("\n<div xmlns:foaf='http://xmlns.com/foaf/0.1/'>\n<div about='#!aActiveOpenIDTrustGroup' typeof='foaf:Group'>\n");
        $wgOut->addHTML("<span rel='foaf:maker'>OpenID accept list for ");
	$wgOut->addHTML("<a href='/' rel='foaf:weblog foaf:account'>this wiki</a></span>\n");
        $wgOut->addHTML("<ul>\n");
        $db = wfGetDB( DB_SLAVE ); 
	$sql = "SELECT user_real_name, user_email, uoi_openid, user_id, user_name,  ug_group FROM " 
       		. " user, user_groups, user_openid WHERE user.user_id = user_openid.uoi_user AND user_groups.ug_user = user.user_id ;" ;
        // $wgOut->addWikiText("SQL was: " . $sql);
        $res = $db->query($sql, __METHOD__);
        for ($j=0; $j<$db->numRows($res); $j++) {
            $row = $db->fetchRow($res);
            if (!isset($u[$row[0]]))
                $u[$row[0]] = $dates;
	        $wgOut->addHTML("<li rel='foaf:member'>\n");
                $wgOut->addHTML("<div typeof='foaf:Agent'>");
                $wgOut->addHTML(  "<span property='foaf:name'>" . $row['user_name'] . "</span>");
                $wgOut->addHTML("<a href='" . $row['uoi_openid']. "' rel='foaf:openid'>link</a>");
		$wgOut->addHTML("</div>\n");
		$wgOut->addHTML("</li>\n");
        }
        $wgOut->addHTML("</ul>\n");
        $wgOut->addHTML("</div>\n");
        $wgOut->addHTML("</div>");

        $db->freeResult($res);
    }
}
