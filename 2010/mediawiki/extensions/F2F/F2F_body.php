<?php
class F2F extends SpecialPage
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
        $wgOut->addWikiText( "Hello [http://wiki.foaf-project.org/w/DanBri/MediawikiOpenid World]!");
        $db = wfGetDB( DB_SLAVE ); 

        # Todo: How do we emit RDFa via addWikiText() ?

	$sql = "SELECT user_real_name, user_email, uoi_openid, user_id, user_name,  ug_group FROM " 
       		. " user, user_groups, user_openid WHERE user.user_id = user_openid.uoi_user AND user_groups.ug_user = user.user_id ;" ;
        $wgOut->addWikiText("SQL was: " . $sql);
        $res = $db->query($sql, __METHOD__);
        for ($j=0; $j<$db->numRows($res); $j++) {
            $row = $db->fetchRow($res);
            if (!isset($u[$row[0]]))
                $u[$row[0]] = $dates;
	        $wgOut->addWikiText("OpenID: " . $row['user_name']. " " . $row['user_email'] . " " . $row['uoi_openid']);
        }
        $db->freeResult($res);
    }
}
