//
//  Gumbovi1AppDelegate.m
//  Gumbovi1
//
//  Created by Dan Brickley on 11/7/09.
//  This code - license: MIT, Share-and-Enjoy.
//  See embedded XMPP, KissXML and IDN libs for their distribution terms.
//  (c) Dan Brickley <danbri@danbri.org> & VU University Amsterdam
// + Libby Miller
//
//  Thanks to Chris van Aart, Jens Finkhäuser, and Daniel Salber for Xcode & Obj-C advice.
//
// Release notes:
// * before release, check executable properties and turn off EXC_BAD_ACCESS handling 
//    ie. http://www.cocoadev.com/index.pl?NSZombieEnabled
//

/* for console Debugging settings, see Gumbovi1_Prefix for definitions. 
 Also xmppstream class defines DEBUG_SEND DEBUG_RECV...
 */

#import "XMPP.h"
#import "FirstViewController.h"
#import "WebViewController.h"
#import "Gumbovi1AppDelegate.h"
#import "XMPPJID.h"
#import "AudioToolbox/AudioServices.h"
#import "ButtonDevice.h"
#import "DDXMLNode.h"
#import "DDXMLElement.h"
#import "DDXMLDocument.h"
#import "NSStringAdditions.h"
#import "DecoderController.h"
#import "RootViewController.h"								// from lists drilldown demo (not used)
#import "SLRootViewController.h" 
#import "ButtonDeviceList.h"

@implementation Gumbovi1AppDelegate
@synthesize decoder_window;
@synthesize qr_results;
@synthesize xmppLink;
@synthesize window;
@synthesize tabBarController;
@synthesize toJid;
@synthesize aJid;
@synthesize htmlInfo;
@synthesize navigationController; // from lists
@synthesize data;				  // end lists stuff
@synthesize buttonDevices;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    VerboseLog(@"TIMER: app delegate appplicationDidFinishLaunching, adding tabBar...");
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];

	ButtonDeviceList *_buddies = [[ButtonDeviceList alloc] init];
	self.buttonDevices = _buddies;
	
	// for http://developer.apple.com/iphone/library/documentation/UIKit/Reference/UIWebView_Class/Reference/Reference.html#//apple_ref/occ/instm/UIWebView/loadData:MIMEType:textEncodingName:baseURL: 
	// in WebViewController
	self.htmlInfo = @"<html><head><title>Now Playing</title></head><body><div><meta name=\"viewport\" content=\"width=320\"/><h1>Now Playing</h1><p>Please wait...</p></div></body></html>";
	VerboseLog(@"gad launched. self.htmlInfo is: %@", self.htmlInfo);
	
	// from drilldown lists code
	NSString *Path = [[NSBundle mainBundle] bundlePath];
	NSString *DataPath = [Path stringByAppendingPathComponent:@"Data.plist"];
	NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:DataPath];
	self.data = tempDict;
	[tempDict release];
	// DebugLog(@"appDidFinishLaunching ... we set up our data dict: %@", self.data);
}

- (void)initXMPP  {
    DebugLog(@"initXMPP *****");
	FirstViewController * fvc = (FirstViewController *) [tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
	VerboseLog(@"FVC is", fvc);
    xmppLink = [[XMPPClient alloc] init];
	[xmppLink addDelegate:self];
	[xmppLink setPort:5222];	
	DebugLog(@"EXPECT1 NOTNULL xmlLink: %@",xmppLink);
	DebugLog(@"Userid: %@", fvc.userid.text);
	DebugLog(@"Passwd: %@", fvc.password.text);
    //  XMPPJID aJID = [XMPPJID jidWithString:fvc.userid.text];
	
	if(( [fvc.userid.text rangeOfString:@"gmail"].location == NSNotFound) && ( [fvc.userid.text rangeOfString:@"googlemail"].location == NSNotFound)){
		DebugLog(@"gmail not found in user JID %@", fvc.userid.text);
		DebugLog(@"We should parse out the host name...?");
	} else {
		DebugLog(@"Hostname matched gmail in JID so setting domain to talk.google.com");
		[xmppLink setDomain:@"talk.google.com"]; // should do this (i) inspect domain name in JID, (ii) dns voodoo
	}
	
	DebugLog(@"EXPECT2 NOTNULL xmlLink: %@",xmppLink);
	[xmppLink setMyJID:[XMPPJID jidWithString:@"jana.notube@googlemail.com/hardcoded"]]; // should not be hardcoded
	[xmppLink setPassword:@"gargonza"];

    if (fvc.userid.text != NULL) {
		DebugLog(@"GAD: User wasn't null so setting userid to be it: %@",  fvc.userid.text);	
	//	NSString *myjs =  [NSString stringWithFormat:@"", fvc.userid.text, @"/gmb1"] ; // todo: random /resource ? 
		[xmppLink setMyJID:[XMPPJID jidWithString:fvc.userid.text]];
	}
    if (fvc.password.text != NULL) {
		DebugLog(@"GAD Pass wasn't null so setting userid to be it: %@", fvc.password.text);	
		[xmppLink setPassword:fvc.password.text];
	}
	DebugLog(@"XMPP in initXMPP DEBUG: u: %@ p: %@",xmppLink.myJID, xmppLink.password);

// TEMPORARY DEVELOPMENT CODE, with ButtonDeviceList and local prefs, should not be needed.
// Here we set an initial default target XMPP JID, where our messages are sent.
#ifdef LIBBY_CFG
	self.toJid = [XMPPJID jidWithString:@"zetland.mythbot@googlemail.com/Basicbot"]; // buddy w/ media services
#endif
#ifdef DANBRI_CFG
	self.toJid = [XMPPJID jidWithString:@"buttons@foaf.tv/gumboviListener"]; // buddy w/ media services
#endif
	
    // NSMutableArray *roster = fvc.roster_list;

    VerboseLog(@"initxmpp: roster list: %@",roster);	
	DebugLog(@"EXPECT3 NOTNULL xmlLink: %@",xmppLink);
	
	[xmppLink setAutoLogin:YES];
	[xmppLink setAllowsPlaintextAuth:NO];
	[xmppLink setAutoPresence:YES];
	[xmppLink setAutoRoster:YES];
	[xmppLink connect];
	
}

//[XMPPJID jidWithString:

- (void)connectIfOffline {
	DebugLog(@"connectIfOffline checks...");
	if (! self.xmppLink.isConnected ) {
		DebugLog(@"connectIfOffline: checked xmpp and it was disconnected ... connecting!");
		[self initXMPP];
	} else {
		DebugLog(@"We seem to be connected %@",self.xmppLink);
	}
	DebugLog(@"XMPP now: %@",self.xmppLink);  
	
}

 


- (void)setTargetJidWithString:(NSString *)someJid {
	NSLog(@"BUTTONS JID TARGET: %@",someJid);
	self.toJid = [XMPPJID jidWithString:someJid];
	// TODO: Error correction here. Strip xmpp: prefix, etc? print warnings?
}

- (void)sendIQ:(NSXMLElement *)myStanza {
	DebugLog(@"BUTTONS IQ SENDER: %@",myStanza);
	[self.xmppLink sendElement:myStanza];
	DebugLog(@"EXPECT4 NOTNULL xmlLink: %@",xmppLink);

}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
	VerboseLog(@"TIMER: app delegate didEndCustomizingViewControllers");
}


- (void)dealloc {
	[data release]; // lists /drilldown
	[xmppLink release]; // bye-bye XMPP
	[navigationController release]; // lists drilldown
    [tabBarController release];
    [window release];
    [super dealloc];
}




/*     BUTTONS PROTOCOL 
 
	BUTTONS 0.0 PROTOCOL IMPLEMENTATION
    THIS IS CURRENTLY AWFUL STOPGAP.
 BUTTONS SHOULD:
  - IQ instead of Chat messages (although they are useful for quick testing)
  - use 'set' when side-effects demanded or expected (REST-Lite)
  - use markup (buttons.foaf.tv ns)
  - be extensible
  - be documented					
 
 In the meantime, we just send out 4-letter codes in textual messages. OK for starters....
 
 */
- (void)sendPLUS:(NSObject *)button
{
	DebugLog(@"SENDING PLUS%@", button);
	NSString *msg = @"PLUS event.";
	DebugLog(@"EXPECT5 NOTNULL xmlLink: %@",xmppLink);

	[ self.xmppLink sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendLEFT:(NSObject *)button
{
	DebugLog(@"SENDING LEFT %@", button);
	NSString *msg = @"LEFT event.";
	[ self.xmppLink sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendRIGH:(NSObject *)button
{
	DebugLog(@"SENDING RIGH %@", button);
	NSString *msg = @"RIGH event.";
	[ self.xmppLink sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendMINU:(NSObject *)button
{
	DebugLog(@"SENDING MINU %@", button);
	NSString *msg = @"MINU event.";
	[ self.xmppLink sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendPLPZ:(NSObject *)button
{
	DebugLog(@"SENDING PLPZ %@ to %@", button, self.toJid);
	NSString *msg = @"PLPZ event.";
	[ self.xmppLink sendMessage:msg toJID:self.toJid ] ;
	VerboseLog(@"Sent msg %@", msg);
	VerboseLog(@"To jid %@", self.toJid);
	VerboseLog(@" XMPP CLient: %@", self.xmppLink );
	VerboseLog(@" XMPP CLient connected?: %@", self.xmppLink.isConnected );

}

- (void)sendMENU:(NSObject *)button
{
	DebugLog(@"SENDING MENU %@", button);
	NSString *msg = @"MENU event.";
	[ self.xmppLink sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendLIKE:(NSObject *)button
{
	DebugLog(@"SENDING LIKE %@", button);
	NSString *msg = @"LIKE event.";
	[ self.xmppLink sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendOKAY:(NSObject *)button
{
	NSString *msg = @"OKAY event.";
	[ self.xmppLink sendMessage:msg toJID:self.toJid ] ;

	VerboseLog(@"SENDING IQ OKAY %@", button);
	NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
	    [errorDetail setValue:@"Failed to do something" forKey:NSLocalizedDescriptionKey];
	NSError *bError = [NSError errorWithDomain:@"buttons" code:100 userInfo:errorDetail];
	// should we manually send from too? from='%@', [xmppLink.myJID full] ... dow e need id= ?
	NSString *myXML = [NSString stringWithFormat:@"<iq type='get' to='%@'><query xmlns='http://buttons.foaf.tv/'><button>OKAY</button></query></iq>", [toJid full]];
	VerboseLog(@"myXML: %@",myXML);
	NSXMLElement *myStanza = [[NSXMLElement alloc]  initWithXMLString:myXML error:&bError];
	VerboseLog(@"Sending IQ okay via %@ ", self.xmppLink);
	VerboseLog(@"Markup was: %@",myStanza);
	[self.xmppLink sendElement:myStanza];
	
/*	NSXMLElement *buttons = [NSXMLElement elementWithName:@"buttons" xmlns:@"http://buttons.foaf.tv/"];
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
	[iq addAttributeWithName:@"type" stringValue:@"get"];
	[iq addChild:buttons];
	[self.xmppLink sendElement:iq]; */
		
}

- (void)sendINFO:(NSObject *)button
{
	DebugLog(@"SENDING INFO %@", button);
	NSString *msg = @"INFO event.";
	[ self.xmppLink sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendLOUD:(NSObject *)myS;
{
	FirstViewController * fvc = (FirstViewController *) [tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
	NSString *v = [NSString stringWithFormat:@"%@ %.1f", @"LOUD", fvc.volume.value];
	DebugLog(@"SENDING LOUD %@", v  );
	[ self.xmppLink sendMessage:v toJID:self.toJid ] ;
}

- (void)sendHUSH:(NSObject *)myS;
{
	//FirstViewController * fvc = (FirstViewController *) tabBarController.selectedViewController;
    FirstViewController * fvc = (FirstViewController *) [tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
	NSString *v = [NSString stringWithFormat:@"%@ %.1f", @"HUSH", fvc.volume.value];
	DebugLog(@"SENDING HUSH %@", v  );
	[ self.xmppLink sendMessage:v toJID:self.toJid ] ;
}



// TODO: Client was removed, check what to do here... JIRA needed
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPClient Delegate Methods:
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppClientConnecting:(XMPPClient *)sender
{
	DebugLog(@"==============================================================");
	DebugLog(@"iPhoneXMPPAppDelegate: xmppClientConnecting");
	DebugLog(@"==============================================================");
}

- (void)xmppClientDidConnect:(XMPPClient *)sender
{
	DebugLog(@"==============================================================");
	DebugLog(@"iPhoneXMPPAppDelegate: xmppClientDidConnect");
	DebugLog(@"==============================================================");
}

- (void)xmppClientDidNotConnect:(XMPPClient *)sender
{
	DebugLog(@"==============================================================");
	DebugLog(@"iPhoneXMPPAppDelegate: xmppClientDidNotConnect");
	DebugLog(@"==============================================================");
}

- (void)xmppClientDidDisconnect:(XMPPClient *)sender
{
	DebugLog(@"==============================================================");
	DebugLog(@"iPhoneXMPPAppDelegate: xmppClientDidDisconnect");
	DebugLog(@"==============================================================");
}

- (void)xmppClientDidRegister:(XMPPClient *)sender
{
	DebugLog(@"==============================================================");
	DebugLog(@"iPhoneXMPPAppDelegate: xmppClientDidRegister");
	DebugLog(@"==============================================================");
}

- (void)xmppClient:(XMPPClient *)sender didNotRegister:(NSXMLElement *)error
{
	DebugLog(@"==============================================================");
	DebugLog(@"iPhoneXMPPAppDelegate: xmppClient:didNotRegister: %@", error);
	DebugLog(@"==============================================================");
}

- (void)xmppClientDidAuthenticate:(XMPPClient *)sender
{
	DebugLog(@"==============================================================");
	DebugLog(@"iPhoneXMPPAppDelegate: xmppClientDidAuthenticate");
	DebugLog(@"==============================================================");
}

- (void)xmppClient:(XMPPClient *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DebugLog(@"==============================================================");
	DebugLog(@"iPhoneXMPPAppDelegate: xmppClient:didNotAuthenticate: %@", error);
	DebugLog(@"==============================================================");
}


- (void)rebuildRosterUI
{
	DebugLog(@"REBUILDING LOCAL ROSTER UI. xmppLink is %@", self.xmppLink);
	[self.xmppLink fetchRoster]; // make sure we're up to date (necessary?)
	NSArray *buddies = [self.xmppLink sortedAvailableUsersByName];
	DebugLog(@"1. current online roster: %@", buddies);

	NSEnumerator *e = [buddies objectEnumerator];
	id object;
	while (object = [e nextObject]) {
		VerboseLog(@"resources for jid is %@ ? ", [object sortedResources] );
		NSEnumerator *e = [[object sortedResources] objectEnumerator];
		id r;
		
		FirstViewController * fvc = (FirstViewController *) [tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
		//		fvc.roster_list = [[NSMutableArray alloc] initWithObjects:nil]; // blank it down each time (losing qr codes?)
		
		while (r = [e nextObject]) {
			XMPPPresence *pres = [[XMPPPresence alloc] init];
			pres = [XMPPPresence presenceFromElement:[r presence]];
			VerboseLog(@"presence (should attach to appropriate ButtonDevice): %@", [pres status]); // todo, add to ButtonDevice
			@try { 
				[fvc.roster_list insertObject:[NSString stringWithFormat:@"%@",[r jid]] atIndex:0];
				// NSSet *tmp = [NSSet setWithArray:fvc.roster_list]; 
				VerboseLog(@"2. REBUILD ROSTER: Current uniq'd roster list is: %@", tmp);
				// fvc.roster_list = [[NSMutableArray alloc] initWithArray:[tmp allObjects]];
				VerboseLog(@"NEW BUTTONDEVICE (from XMPP): About to construct");
				ButtonDevice *newDev = [[ButtonDevice alloc] initWithURI:[NSString stringWithFormat:@"%@",[r jid]]]; //danbri
				// [newDev setName:@"jid"];
				[newDev setFromQRCode:NO];
				[[self buttonDevices] addObject:newDev]; //added to set
			}
			@catch (NSException *exception) {
				DebugLog(@"main: Caught %@: %@", [exception name],  [exception reason]); 
			} 
		}
	
	}
}

- (void)xmppClientDidUpdateRoster:(XMPPClient *)sender
{
	DebugLog(@"===========================================================");
	DebugLog(@"iPhoneXMPPAppDelegate: xmppClientDidUpdateRoster");
	DebugLog(@"UpdateRoster msg is: %@",sender);
	NSArray *buddies = [sender sortedAvailableUsersByName];

	[self rebuildRosterUI];
 	
	[self.buttonDevices removeAllNonLocalDevices]; // wipe out everything except QR Code entries
	NSEnumerator *e = [buddies objectEnumerator];
	id object;
	while (object = [e nextObject]) {
		VerboseLog(@"resources for jid is %@ ? ", [object sortedResources] );
		NSEnumerator *e = [[object sortedResources] objectEnumerator];
		id r;
		
		FirstViewController * fvc = (FirstViewController *) [tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
//		fvc.roster_list = [[NSMutableArray alloc] initWithObjects:nil]; // blank it down each time (losing qr codes?)

		while (r = [e nextObject]) {

            //get the presence
			//not sure how to display it!
			XMPPPresence *pres = [[XMPPPresence alloc] init];
			pres = [XMPPPresence presenceFromElement:[r presence]];
			VerboseLog(@"presence: %@", [pres status]);
 			VerboseLog(@"Sending discovery IQ to %@", r);
			@try { 
				[fvc.roster_list insertObject:[NSString stringWithFormat:@"%@",[r jid]] atIndex:0];
				NSSet *tmp = [NSSet setWithArray:fvc.roster_list]; 
				fvc.roster_list =     [[NSMutableArray alloc] initWithArray:[tmp allObjects]];
			}
                @catch (NSException *exception) {
				DebugLog(@"main: Caught %@: %@", [exception name],  [exception reason]); 
			} 
			NSXMLElement *disco = [NSXMLElement elementWithName:@"iq"];
			[disco addAttributeWithName:@"type" stringValue:@"get"];
			//[disco addAttributeWithName:@"from" stringValue:[[sender myJID] full]];
			// got If set, the 'from' attribute must be set to the user's full JID (400 error) when only sending foo@bar
			
			[disco addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",[r jid]  ]];
			[disco addAttributeWithName:@"id" stringValue:@"disco1"];
			[disco addChild:[NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"]];
			// DebugLog(@"About to send %@", disco);
			[sender sendElement:disco];
		}
		// here or nearby we might do discovery to find out what's available there...
		// http://xmpp.org/extensions/xep-0030.html#info
/* 
 <iq type='get'
 from='romeo@montague.net/orchard'
 to='plays.shakespeare.lit'
 id='info1'>
 <query xmlns='http://jabber.org/protocol/disco#info'/>
 </iq>    */
		
//	NSString *myXML = [NSString stringWithFormat:@"<iq type='get' id='1001' to='%@'><query xmlns='http://jabber.org/protocol/disco#info'/></iq>", [toJid full]];

//		DebugLog(@"myXML: %@",myXML);
//		NSXMLElement *myStanza = [[NSXMLElement alloc]  initWithXMLString:myXML error:&bError];
//		DebugLog(@"Sending IQ okay via %@ ", self.xmppLink);
//		DebugLog(@"Markup was: %@",myStanza);
//		[self.xmppLink sendElement:myStanza];
	
	
	}
	
	DebugLog(@"==============================================================");
}

- (void)xmppClient:(XMPPClient *)sender didReceiveBuddyRequest:(XMPPJID *)jid
{
	DebugLog(@"==============================================================");
	DebugLog(@"iPhoneXMPPAppDelegate: xmppClient:didReceiveBuddyRequest: %@", jid);
	DebugLog(@"==============================================================");
}

- (void)xmppClient:(XMPPClient *)sender didReceiveIQ:(XMPPIQ *)iq
{
	VerboseLog(@"iPhoneXMPPAppDelegate: xmppClient:didReceiveIQ: %@", iq);
	NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
	[errorDetail setValue:@"Failed to decode NOWP IQ" forKey:NSLocalizedDescriptionKey];
	//NSError    *error = [NSError errorWithDomain:@"buttons" code:100 userInfo:errorDetail];
	//	NSArray *nowpNodes = [iq nodesForXPath:@"./iq/nowp-result" error:&error];
	// ok NSArray *nowpNodes = [iq nodesForXPath:@"." error:&error];
	//NSArray *nowpNodes = [iq nodesForXPath:@"./iq/nowp-result/" error:&error];
	//DebugLog(@"nowp results: %@", nowpNodes);
	//NSEnumerator *enumerator = [nowpNodes objectEnumerator];
    //id obj;	
    //while ( obj = [enumerator nextObject] ) {
    //    printf( "%s\n", [[obj description] cString] );
    //}

	// Sleazy XML handling
	DDXMLElement *x = (DDXMLElement *)[iq childAtIndex:0];
	DDXMLElement *x2 = (DDXMLElement *) [x childAtIndex:0];
	NSString *xs = 	[NSString stringWithFormat:@"%@", x2];
	// DebugLog(@"X2: %@",xs);
	
	if([xs rangeOfString:@"<div>"].location == NSNotFound){
	//	DebugLog(@"div not found in xs %@", xs);
	} else {
		DebugLog(@"NOWP: Setting self.htmlInfo to: %@",xs);
		self.htmlInfo = xs;

		WebViewController *wvc = (WebViewController *) [self.tabBarController.viewControllers objectAtIndex:TAB_INFO];
		NSURL *baseURL = [NSURL URLWithString:@"http://buttons.notube.tv/"];		
		[wvc.webview loadHTMLString:self.htmlInfo baseURL:baseURL];		

	
	}
//		DebugLog(@"xs was null, assuming we didn't find HTML. should check xmlns/element or at least for a <div>");	
	// Nothing worked. Related attempts:
	// additions see http://code.google.com/p/kissxml/issues/detail?id=18
	// http://groups.google.com/group/xmppframework/browse_thread/thread/1ae1f1ca58abbd90
	//	DDXMLElement *info = [iq elementForName:@"nowp-result" xmlns:@"http://buttons.foaf.tv/"];
	
	DebugLog(@"==============================================================");
    

}

- (void)xmppClient:(XMPPClient *)sender didReceiveMessage:(XMPPMessage *)message
{
	DebugLog(@"==============================================================");
	DebugLog(@"iPhoneXMPPAppDelegate: xmppClient:didReceiveMessage: %@", message);
	DebugLog(@"==============================================================");
	//tabBarController.selectedViewController.output.text = @"Got message!";

	
	// FirstViewController * fvc = (FirstViewController *) tabBarController.selectedViewController;
    NSString *m = (NSString *) [  message elementForName:@"body"  ] ;	

	// fvc.output.text = m.description;  // trying to strip out <body> and <body/> below gives trouble

	NSString *log = [NSString stringWithFormat:@"%@",m.description];
	log = [[log stringByReplacingOccurrencesOfString:@"<body>" withString:@""] stringByReplacingOccurrencesOfString:@"</body>" withString:@""];
	[log retain];
	  // @"......"; m.description;  //log ;			//+ [NSString log]; //  m.description;
    
	//fvc.output.text = log; // problem?
    DebugLog(@"XMPP MSG: %@",log);
}



/// LISTS

/// copied from DrillDownApp 

	


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}



- (void) startQRScan:(id)sender {
	DebugLog(@"Starting qr scan. %@ ", sender);
	//Gumbovi1AppDelegate *gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];	
	UINavigationController *myQrController = [tabBarController.viewControllers objectAtIndex:4];
    DebugLog(@"My qr controller in 5th tab is %@ " , myQrController); // a UINavigationController
	decoderController = [[DecoderController alloc] init];
    DebugLog(@"Trying to push a DecoderController %@ ", decoderController);
	DebugLog(@"...onto my UINavigationController %@ ", myQrController);
	[myQrController pushViewController:decoderController animated:YES];
	self.decoder_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];	
		//	self.decoder_window = [[UIWindow alloc] initWithFrame:myQrController.view.bounds ];	
	[decoder_window addSubview:decoderController.view];	
}

- (void)newJID:(id)jid {
	
	DebugLog(@"Got a new Linked TV via QR code. Setting toJID to: %@",jid);	
    self.qr_results.text=jid;
	self.toJid = [XMPPJID jidWithString:jid]; // buddy w/ media services
	FirstViewController * fvc = (FirstViewController *) [tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
    NSMutableArray *roster = fvc.roster_list;
	DebugLog(@"Roster was: %@",roster);
	[fvc.roster_list addObject:jid];
	DebugLog(@"Roster now: %@",roster);
	DebugLog(@"gad.toJID is now: %@",self.toJid);
	NSString *new_uri = [NSString stringWithFormat:@"%@",jid]; // or was it a string already
		   
	VerboseLog(@"NEW BUTTONDEVICE: About to construct");
	ButtonDevice *newDev = [[[ButtonDevice alloc] initWithURI:new_uri] retain]; // MEM-TODO	
	VerboseLog(@"NEW BUTTONDEVICE: Back from constructor. About to set properties on: %@", newDev);
	[newDev setName:@"jid"];
	//	DebugLog(@"BEFORE"); 
	newDev.fromQRCode = YES; // vs. [newDev setFromQRCode:YES]
	[newDev retain];
	VerboseLog(@"DONE setting qrcode on newdev: %@",newDev);
	[[self buttonDevices] addObject:newDev]; //added to set
	
	DebugLog(@"Made a new qr device: %@", newDev);
	
	//see also http://www.freesound.org/samplesViewSingle.php?id=706 etc - can try for haptic on button presses
	NSString *path = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/pop.wav"];
		SystemSoundID soundID;
		NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
		AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
		AudioServicesPlaySystemSound(soundID);
}

@end

