<?php
if (!defined('MEDIAWIKI')) die();
/**
 * A Special Page extension to export lists of trusted OpenIDs using RDFa/FOAF
 *
 * @package MediaWiki
 * @subpackage Extensions
 *
 * @author Dan Brickley <danbri@danbri.org>
 * @copyright Copyright © 2009, 2010 Dan Brickley
 * @license http://www.gnu.org/copyleft/gpl.html GNU General Public License 2.0 or later
 */

$wgExtensionCredits['specialpage'][] = array(
	'name'           => 'F2F',
	'version'        => 'v0.1',
	'author'         => 'Dan Brickley',
	'email'          => 'danbri@danbri.org',
	'url'            => 'http://wiki.foaf-project.org/w/F2FPluginMediaWiki', # todo: make MediaWiki and Wordpress pages
	'description'    => 'Show a list of OpenID accounts that are used with this wiki.',
	'descriptionmsg' => 'f2f-desc',
);


# define the permissions to view systemwide statistics
$wgGroupPermissions['*'][$wgUserStatsGlobalRight] = false;
$wgGroupPermissions['manager'][$wgUserStatsGlobalRight] = true;
$wgGroupPermissions['sysop'][$wgUserStatsGlobalRight] = true;

$dir = dirname(__FILE__) . '/';
$wgExtensionMessagesFiles['F2F'] = $dir . '/F2F.i18n.php';
$wgExtensionAliasesFiles['F2F'] = $dir . 'F2F.alias.php';
$wgAutoloadClasses['F2F'] = $dir . '/F2F_body.php';
$wgSpecialPages['F2F'] = 'F2F';
$wgSpecialPageGroups['SpecialUserStats'] = 'wiki';
