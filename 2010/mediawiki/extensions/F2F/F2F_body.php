<?php
class F2F extends SpecialPage
#
#
# This is the F2F exporter
# Author: Dan Brickley <danbri@danbri.org>
# http://wiki.foaf-project.org/w/F2FMediawikiPlugin
#
# see initial announcement:
# http://lists.foaf-project.org/pipermail/foaf-dev/2010-October/010447.html
#
# nearby useful links:
# http://inspector.sindice.com/inspect?url=http://wiki.foaf-project.org/w/Special:F2F&content=
# see also http://www.mediawiki.org/wiki/Manual:$wgOut
#
# thanks: mhausenblas, presbrey, tobyink


# Some/all of these in LocalSettings.php are needed (todo - clarify)
#$wgHTML5 = true;
#$wgAllowRdfaAttributes = true; // http://www.mediawiki.org/wiki/Manual:$wgAllowRdfaAttributes$wgAllowMicrodataAttributes = true;
#$wgWellFormedXml = true;
#$wgRawHtml = true;

# debugging: rapper -i rdfa http://wiki.foaf-project.org/w/Special:F2F

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
 //       $wgOut->setPagetitle('F2F');   // http://svn.wikimedia.org/doc/classOutputPage.html
 	$wgOut->setArticleBodyOnly(true);
        $user = $wgUser->getName();

        $wgOut->addHTML("<!DOCTYPE html>\n");
        $wgOut->addHTML("<html xmlns='http://www.w3.org/1999/xhtml'><head><title>F2F group list(s)</title></head>");
        $wgOut->addHTML("<body>");

        $wgOut->addWikiText("Logged in as " . $user);
        $u = array();
        $sitehome = "http://wiki.foaf-project.org/";

        $wgOut->addWikiText( "This is the [http://wiki.foaf-project.org/w/F2FMediawikiPlugin F2F Mediawiki extension]");

	$wgOut->addHTML("\n<div xmlns:foaf='http://xmlns.com/foaf/0.1/'>\n<div about='#!aActiveOpenIDTrustGroup' typeof='foaf:Group'>\n");
        $wgOut->addHTML("<span rel='foaf:maker'>OpenID accept list for ");
	$wgOut->addHTML("<a href='/' rel='foaf:weblog foaf:account'>this wiki</a></span>\n");
        $wgOut->addHTML("<ul>\n");
        $db = wfGetDB( DB_SLAVE ); 
	$sql = "SELECT distinct user_real_name, user_email, uoi_openid, user_id, user_name,  ug_group FROM " 
       		. " user, user_groups, user_openid WHERE user.user_id = user_openid.uoi_user AND user_groups.ug_user = user.user_id GROUP BY uoi_openid;" ;
//       		. " user, user_groups, user_openid WHERE user.user_id = user_openid.uoi_user AND user_groups.ug_user = user.user_id" ;
        $wgOut->addHTML("<!-- SQL was: " . $sql . " -->");
        $res = $db->query($sql, __METHOD__);
        for ($j=0; $j<$db->numRows($res); $j++) {
            $row = $db->fetchRow($res);
            if (!isset($u[$row[0]]))
                $u[$row[0]] = $dates;
	        $wgOut->addHTML("<li rel='foaf:member'>\n");
                $wgOut->addHTML("<div typeof='foaf:Agent'>");
                $wgOut->addHTML("<a href='" . $row['uoi_openid']. "' rel='foaf:openid foaf:account' property='foaf:name'>");
//                $wgOut->addHTML(  "<span>" . $row['user_name'] . "</span>");
                $wgOut->addHTML( $row['user_name'] );
    		$wgOut->addHTML("</a>\n");
		$wgOut->addHTML("</div>\n");
		$wgOut->addHTML("</li>\n");
        }
        $wgOut->addHTML("</ul>\n");
        $wgOut->addHTML("</div>\n");
        $wgOut->addHTML("</div>");

        $wgOut->addHTML("</body>");
        $wgOut->addHTML("</html>");

        $db->freeResult($res);
    }
}

# [12:18]  <tobyink> danbri: see http://check.rdfa.info/check?url=http%3A%2F%2Fwiki.foaf-project.org%2Fw%2FSpecial%3AF2F&version=1.0
# [12:19]  <tobyink> versus http://check.rdfa.info/check?url=http%3A%2F%2Fwiki.foaf-project.org%2Fw%2FSpecial%3AF2F&version=1.1
# [12:19]  <tobyink> If you want RDFa 1.0 compatibility either drop the redundant <span> elements, or add datatype="" to the <a> elements.
# [12:27]  <logger> See http://chatlogs.planetrdf.com/swig/2010-10-20#T10-27-47



