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
//
// We use the XMPPFramework for Jabber networking, migrating to v2.0
// sample code: http://code.google.com/p/xmppframework/source/browse/trunk/iPhoneXMPP/Classes/iPhoneXMPPAppDelegate.m
// API changes: http://groups.google.com/group/xmppframework/browse_thread/thread/c65faffac3627169

/* for console Debugging settings, see Gumbovi1_Prefix for definitions. 
 Also XMPPStream class defines DEBUG_SEND DEBUG_RECV...
 */

#import <CFNetwork/CFNetwork.h>

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
#import "ButtonCell.h"
#import "XMPP.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPRoster.h"
#import "XMPPStream.h"
#import "XMPPCapabilities.h"
#import "XMPPCapsResourceCoreDataStorageObject.h"
#import "XMPPUser.h"
#import "XMPPResource.h" 

@implementation Gumbovi1AppDelegate

@synthesize decoder_window;
@synthesize qr_results;
@synthesize window;
@synthesize tabBarController;
@synthesize toJid;
@synthesize aJid;
@synthesize htmlInfo;
@synthesize navigationController; // from lists
@synthesize data;				  // end lists stuff
@synthesize buttonDevices;
@synthesize xmppLink;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize password;
@synthesize xmppReconnect;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize keepaliveTimer;


- (id)init
{
	if((self = [super init]))
	{
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		DebugLog(@"init, with a base dir of: %@", documentsDirectory);

		xmppLink = [[XMPPStream alloc] init];
		xmppReconnect = [[XMPPReconnect alloc] initWithStream:xmppLink]; // FIXME - we do this only once
		[xmppReconnect addDelegate:self];

		//qwerty
		xmppRosterStorage = [[XMPPRosterMemoryStorage alloc] init];// DANBRI MAY2010 debug - can core do this api?
		//xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
		xmppRoster = [[XMPPRoster alloc] initWithStream:xmppLink rosterStorage:xmppRosterStorage];
		xmppCapabilitiesStorage = [[XMPPCapabilitiesCoreDataStorage alloc] init];
		xmppCapabilities = [[XMPPCapabilities alloc] initWithStream:xmppLink capabilitiesStorage:xmppCapabilitiesStorage];
		xmppCapabilities.autoFetchHashedCapabilities = YES;
		xmppCapabilities.autoFetchNonHashedCapabilities = YES;
				
		[xmppLink addDelegate:self];
		[xmppRoster addDelegate:self];
		[xmppRoster setAutoRoster:YES];
		
		// turnSockets = [[NSMutableArray alloc] init];
		// XEP-0065 see sample AppDelegate 
		// perhaps similar needed for XEP-0174? TODO - investigate. Jingle-related?
		//         NSLog(@"You now have a socket that you can use to send/receive data to/from the other person.");
		// 
	}
	return self;
}



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
	
//	xmppReconnect = [[XMPPReconnect alloc] initWithStream:xmppLink]; // FIXME - we do this only once
//	[xmppReconnect addDelegate:self];
	
}

- (void)initXMPP  {
    DebugLog(@"XMPP: initXMPP starting.");
	FirstViewController * fvc = (FirstViewController *) [tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
	VerboseLog(@"FVC is", fvc);
	
	// HUGE PILE OF MESS TO GET JIDS SETUP
	
	DebugLog(@"EXPECT1 NOTNULL xmlLink: %@",xmppLink);
	DebugLog(@"Userid: %@", fvc.userid.text);
	DebugLog(@"Passwd: %@", fvc.password.text);
    // XMPPJID aJID = [XMPPJID jidWithString:fvc.userid.text];
	
	if(( [fvc.userid.text rangeOfString:@"gmail"].location == NSNotFound) && ( [fvc.userid.text rangeOfString:@"googlemail"].location == NSNotFound)){
		DebugLog(@"gmail not found in user JID %@", fvc.userid.text);
		DebugLog(@"We should parse out the host name...?");
		[xmppLink setHostName:@"foaf.tv"] ; //FIXME hardcoding is wrong and dumb
	} else {
		DebugLog(@"Hostname matched gmail in JID so setting domain to talk.google.com");
		[xmppLink setHostName:@"talk.google.com"]; // should do this (i) inspect domain name in JID, (ii) dns voodoo
	}
    if (fvc.userid.text != NULL) {
		DebugLog(@"GAD: User wasn't null so setting userid to be it: %@",  fvc.userid.text);	
		[xmppLink setMyJID:[XMPPJID jidWithString:fvc.userid.text]];
	}
    if (fvc.password.text != NULL) {
		DebugLog(@"GAD Pass wasn't null so setting userid to be it: %@", fvc.password.text);	
		self.password = fvc.password.text;// testing
	}
	// END HUGE PILE OF MESS. FIXME!
	
	DebugLog(@"GUMBOVI: %@ ",self);
	DebugLog(@"ABOUT TO CONNECT!: %@ ",xmppLink);

	//[xmppLink setMyJID:[XMPPJID jidWithString:@"buttons@foaf.tv/hardcoded"]]; // should not be hardcoded FIXME
	[xmppLink setMyJID:[XMPPJID jidWithString:@"alice.notube@gmail.com/hardcoded"]]; // should not be hardcoded FIXME

	[xmppLink setHostPort:5222];	
	//[xmppLink setHostName:@"foaf.tv"];
	//[xmppLink setHostName:@"talk.google.com"];

	self.password = @"gargonza"; // FIXME
	
	allowSelfSignedCertificates = YES;
	allowSSLHostNameMismatch = YES; 
	
	
	NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
	[errorDetail setValue:@"Failed to init xmpp" forKey:NSLocalizedDescriptionKey];
	NSError *error = [NSError errorWithDomain:@"buttons" code:100 userInfo:errorDetail];
	// NSError *error = nil;

	if (![xmppLink connect:&error]) {
		
		NSLog (@"ERROR CONNECTING: %@", error);
	}
	
	

// TEMPORARY DEVELOPMENT CODE, with ButtonDeviceList and local prefs, should not be needed.
// Here we set an initial default target XMPP JID, where our messages are sent.
#ifdef LIBBY_CFG
	self.toJid = [XMPPJID jidWithString:@"zetland.mythbot@googlemail.com/Basicbot"]; // buddy w/ media services
#endif
#ifdef DANBRI_CFG
	self.toJid = [XMPPJID jidWithString:@"bob.notube@gmail.com/hardcoded"]; // buddy w/ media services
#endif
	
	DebugLog(@"EXPECT3 NOTNULL xmlLink: %@",xmppLink);

	if (! self.xmppLink.isConnected ) {
		DebugLog(@"INIT XMPP CLient NOT connected");		
	} else {
		DebugLog(@"INIT XMPP CLient IS connected");		
	}

	NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
	[[self xmppLink] sendElement:presence];

}

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



- (void)sendMessage:(NSString *)messageStr {
    if([messageStr length] < 1) {
		DebugLog(@"sendMessage was passed empty message; ignoring quietly.");
		return;
	}

#if SEND_AS_CHAT
  
	NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
	[body setStringValue:messageStr]; // FIXME: test this escapes ok.
	NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
	[message addAttributeWithName:@"type" stringValue:@"chat"];
	[message addAttributeWithName:@"to" stringValue:[self.toJid full] ];
	[message addChild:body]; 
	DebugLog(@"BUTTONS ABOUT TO SEND MESSAGE: %@", message);
	[xmppLink sendElement:message];
	DebugLog(@"SENT!");
	
#else
	NSLog(@"SEND_AS_CHAT disabled, only IQ. Not sending this as XMPP chat message: ", messageStr);

	NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary]; // TODO move to re-usable place in code
	[errorDetail setValue:@"Failed to send NOWP IQ" forKey:NSLocalizedDescriptionKey];
	NSError *bError = [NSError errorWithDomain:@"buttons" code:100 userInfo:errorDetail]; // TODO: define protocol errors
	NSString *rs = [xmppLink generateUUID]; // FIXME minor XMPP library dependency introduced here
	NSString *myXML = [NSString stringWithFormat:@"<iq type='set' to='%@' id='%d'><query xmlns='http://buttons.foaf.tv/'><button>%@</button></query></iq>", [toJid full], rs, messageStr];
	DebugLog(@"BUTTONS IQ SENDER: %@",myXML);
	NSXMLElement *myStanza = [[NSXMLElement alloc] initWithXMLString:myXML error:&bError];
    [xmppLink sendElement:myStanza];
	
#endif
	


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
  - DONE (well, ifdef'd default) IQ instead of Chat messages (although they are useful for quick testing)
  - DONE: use 'set' when side-effects demanded or expected (REST-Lite)
  - use markup (buttons.foaf.tv ns)
  - be extensible
  - be documented					
 
 In the meantime, we just send out 4-letter codes in textual messages. OK for starters....
 
 */
- (void)sendPLUS:(NSObject *)button
{
	NSString *msg = @"PLUS";
	[self sendMessage:msg];
}

- (void)sendLEFT:(NSObject *)button
{
	NSString *msg = @"LEFT";
	[self sendMessage:msg];
}

- (void)sendRIGH:(NSObject *)button
{
	NSString *msg = @"RIGH";
	[self sendMessage:msg];
}

- (void)sendMINU:(NSObject *)button
{
	NSString *msg = @"MINU";
	[self sendMessage:msg];
}

- (void)sendPLPZ:(NSObject *)button
{
	DebugLog(@"SENDING PLPZ %@ to %@", button, self.toJid);
	NSString *msg = @"PLPZ";
	[self sendMessage:msg];
	VerboseLog(@"Sent msg %@", msg);
	VerboseLog(@"To jid %@", self.toJid);
	VerboseLog(@" XMPP CLient: %@", self.xmppLink );
	VerboseLog(@" XMPP CLient connected?: ");
/*    NSString *c;
	if (xmppLink.isConnected ) { 
		c = @"Y";
	} else { 
		c = @"N";
	}	*/
}
 

- (void)sendMENU:(NSObject *)button
{
	NSString *msg = @"MENU";
	[self sendMessage:msg];
}

- (void)sendLIKE:(NSObject *)button
{
	NSString *msg = @"LIKE";
	[self sendMessage:msg];
}

- (void)sendOKAY:(NSObject *)button
{
	NSString *msg = @"OKAY";
	[self sendMessage:msg];
		
}

- (void)sendINFO:(NSObject *)button
{
	NSString *msg = @"INFO event.";
	[self sendMessage:msg] ;
}

- (void)sendLOUD:(NSObject *)m;
{
	FirstViewController * fvc = (FirstViewController *) [tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
	NSString *v = [NSString stringWithFormat:@"%@ %.1f", @"LOUD", fvc.volume.value];
	DebugLog(@"SENDING LOUD %@", v  );
	[self sendMessage:v] ;
}

- (void)sendHUSH:(NSObject *)m;
{
	//FirstViewController * fvc = (FirstViewController *) tabBarController.selectedViewController;
    FirstViewController * fvc = (FirstViewController *) [tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
	NSString *v = [NSString stringWithFormat:@"%@ %.1f", @"HUSH", fvc.volume.value];
	DebugLog(@"SENDING HUSH %@", v  );
	[self sendMessage:v] ;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



///  OLD EVENT HANDLERS HERE, see below for new delegate methods


// FIXME: rebuildRosterUI should consult roster

// XMPPFramework 2 monitors roster/presence/capabilities and keeps these in local db
// so we won't need most of this. Need QR handling though. Hmm...

- (void)rebuildRosterUI
{
	DebugLog(@"OLD CODE FIXME: LOCAL ROSTER UI. xmppLink is %@", self.xmppLink);
	//[self.xmppLink fetchRoster]; // make sure we're up to date (necessary?)

	
	/*
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
	 
	 */
}




//FIXME
// see iphone demo classes for new roster management

- (void)xmppClientDidUpdateRoster:(XMPPStream *)sender
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
		
	}
	
}


- (void)xmppClient:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
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





/* see also  "When the capabilities are received, the xmppCapabilities:didDiscoverCapabilities: delegate method is invoked." */ 

- (void)scanRosterForDevices {
    VerboseLog(@"Scanning Core Data (caps, roster)");

	VerboseLog(@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
	VerboseLog(@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
	

	Gumbovi1AppDelegate *buttons = self;
	FirstViewController *fvc = (FirstViewController *) [buttons.tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
	/// needed?	fvc.roster_list.release; // FIXME
	fvc.roster_list = [[NSMutableArray alloc] init]; // must be a better way to empty things FIXME
	
	DebugLog(@"BUTTONS CAPABILITIES DB: %@", buttons.xmppCapabilities);
	DebugLog(@"BUTTONS ROSTER DB: %@", buttons.xmppRoster);
	
	if (buttons.xmppRoster.autoRoster==TRUE) {
		DebugLog(@"BUTTONS AUTOROSTER true");
	} else {
		DebugLog(@"BUTTONS AUTOROSTER false");			
	}
	
	
	NSArray *devs = [buttons.xmppRosterStorage sortedUsersByAvailabilityName];
	
	
	//DebugLog(@"Roster sortedUsersByAvailabilityName: %@ ", devs);
	for (XMPPUserMemoryStorage *u in devs) {
		
		
		// we think these are XMPPUserMemoryStorage
		
		DebugLog(@"User: %@ primaryResource: %@", u, [u primaryResource] ) ; // XMPPUser
		if ([u isOnline]) { 
			//DebugLog(@"ONLINE! status: %@", [u status]); 
			DebugLog(@"ONLINE"); // 
			NSArray *a = [u sortedResources];
			//XMPPResource *ro;//qwerty
			for (NSObject *ro in a) {
				XMPPJID *r = (XMPPJID *) [ro jid];
				DebugLog(@"ONLINE RESOURCE: %@  ...", r);
				NSString *fullJid = [r description];
				DebugLog(@"PREZZZZ: %@", [[ro presence] status] );
				
				
				[fvc.roster_list addObject:fullJid ]; // TODO Roster is ButtonDevice / ButtonDeviceList ?
				// NSSet *tmp = [NSSet setWithArray:fvc.roster_list]; 
				// fvc.roster_list = [[NSMutableArray alloc] initWithArray:[tmp allObjects]];
				DebugLog(@"Roster now: %@",fvc.roster_list);
				// [tmp release];
				
				/* Caps are handled with the XEP-0115 standard which defines a technique for 
				 hashing capabilities (disco info responses), and broadcasting them within a presence element. */
				XMPPCapabilitiesCoreDataStorage *caps = (XMPPCapabilitiesCoreDataStorage *) buttons.xmppCapabilitiesStorage;
				DebugLog(@"Caps available? %@", caps);
				XMPPJID *jj = (XMPPJID *)[XMPPJID jidWithString:fullJid];
				// DebugLog(@"XMPPJID for caps query: %@", jj);
				// if ([caps isMemberOfClass:[XMPPCapabilitiesCoreDataStorage class]]) { DebugLog(@"OK");}
				DebugLog(@"CHECKING FOR XML...");
				if ([caps areCapabilitiesKnownForJID:jj] ) {
					XMPPJID *j1 = [ro jid];	
					XMPPIQ *capXML = [caps capabilitiesForJID:j1];
					DebugLog(@"XML: %@", capXML);
					NSString *xs = [capXML description];
					if([xs rangeOfString:@"category=\"client\""].location == NSNotFound){
						DebugLog(@"BUTTONS CAPS: Not a client");	
					} else {
						DebugLog(@"BUTTONS CAPS: Desktop Client!");
					}
				} else { DebugLog(@"NOXML: %@ capabilities unknown.", jj); }
			} // end loop through connected resources
			
		} else { DebugLog(@"OFFLINE."); } 
	
	}
	
	[ [buttons.tabBarController.viewControllers objectAtIndex:TAB_DEVICES] reloadData] ;

	return;
	


	
	VerboseLog(@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

}	







////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Custom
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
// 
// In addition to this, the NSXMLElementAdditions class provides some very handy methods for working with XMPP.
// 
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
// 
// For more information on working with XML elements, see the Wiki article:
// http://code.google.com/p/xmppframework/wiki/WorkingWithElements

- (void)goOnline
{
	NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
	
	[[self xmppLink] sendElement:presence];

    // TODO timer danbri ping 
	keepaliveTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(keepAlive) userInfo:nil repeats:YES];
	
	
}

- (void)goOfflinesent 
{
	NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
	[presence addAttributeWithName:@"type" stringValue:@"unavailable"];
	
	[[self xmppLink] sendElement:presence];

}


- (void) keepAlive {
	NSLog(@"keepAlive: sending NOOP to %@", self.toJid);
	[self sendMessage:@"NOOP"];

	NSLog(@"heartbeat - scanning roster (local db) for devices:");
	
	[self scanRosterForDevices]; 	

	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	NSLog(@"---------- xmppStream:willSecureWithSettings: ----------");
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppLink.hostName;
		NSString *virtualDomain = [xmppLink.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	NSLog(@"---------- xmppStreamDidSecure: ----------");
}

- (void)xmppStreamDidOpen:(XMPPStream *)sender
{
	NSLog(@"---------- xmppStreamDidOpen: ----------");
	
	isOpen = YES;
	
	NSError *error = nil;
	
	if (![[self xmppLink] authenticateWithPassword:password error:&error])
	{
		NSLog(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	NSLog(@"---------- xmppStreamDidAuthenticate: ----------");
	
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	NSLog(@"---------- xmppStream:didNotAuthenticate: ----------");
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSLog(@"---------- xmppStream:didReceiveIQ: ----------");

	
	//- (void)xmppClient:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
	
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
		
	// Sleazy XML handling ---- see presence code for something maybe better? FIXME
	DDXMLElement *x = (DDXMLElement *)[iq childAtIndex:0];
	DDXMLElement *x2 = (DDXMLElement *) [x childAtIndex:0];
	NSString *xs = 	[NSString stringWithFormat:@"%@", x2];
	// DebugLog(@"X2: %@",xs);
		
	if([xs rangeOfString:@"<div"].location == NSNotFound){
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
		
	
	return NO; // FIXME --- investigate what this means
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	NSLog(@"---------- xmppStream:didReceiveMessage: ----------");
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	NSLog(@"---------- xmppStream:didReceivePresence: ----------");
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	NSLog(@"---------- xmppStream:didReceiveError: ----------");
}


/* we use a reconnect 
- (void)xmppStreamDidClose:(XMPPStream *)sender
{
	NSLog(@"---------- xmppStreamDidClose: ----------");
	
	if (!isOpen)
	{
		NSLog(@"Unable to connect to server. Check xmppStream.hostName");
	}
}
*/






////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Auto Reconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidClose:(XMPPStream *)sender
{
	// If we weren't using auto reconnect, we could take this opportunity to display the sign in sheet.
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
	NSLog(@"---------- xmppReconnect:shouldAttemptAutoReconnect: ----------");
	
	return YES;
}




@end


















/*
 /// all that follows - can we delete? coredata version seems not to have the api we need	
 
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPResourceCoreDataStorage" inManagedObjectContext:buttons.xmppRosterStorage.managedObjectContext];
 //NSEntityDescription *caps = [NSEntityDescription entityForName:@"XMPPCapsResourceCoreDataStorageObject" inManagedObjectContext:buttons.xmppCapabilitiesStorage.managedObjectContext];	
 NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
 [fetchRequest setEntity:entity];				// everything if no predicate, so commented out: [fetchRequest setPredicate:predicate];
 [fetchRequest setIncludesPendingChanges:YES];
 [fetchRequest setFetchLimit:100];
 // NSError *err = nil;
 NSArray *results = [buttons.xmppRosterStorage.managedObjectContext executeFetchRequest:fetchRequest error:nil];
 
 [fetchRequest release]; // TODO - a lot more of this needed...
 
 // DebugLog(@"array is: %@" , results);	
 for (NSEntityDescription *entity in results) {
 
 DebugLog(@"ROSTER ENTITY: %@",entity);
 //NSString *xp = [entity presenceStr];
 //DebugLog("ROSTER PRESENCE STRING: presence markup is %@",[entity presenceStr]);
 DebugLog(@"JID: %@", [entity jidStr]);
 NSString *aJid = [entity jidStr];
 XMPPPresence *xp = [entity presence];
 NSString *fullJid = [[xp attributeForName:@"from"] stringValue];
 
 
 //	XMPPJID *xJid = [XMPPJID jidWithString:fullJid];
 //	XMPPCapsResourceCoreDataStorageObject *lastRes = [caps resourceForJID:xJid];
 //	DebugLog(@"last resource for full JID %@ is : %@", xJid, lastRes);
 
 
 NSLog(@"EXTRACTED JID: %@",fullJid);		
 DebugLog(@"We got a JID in our roster: %@",aJid);	
 DebugLog(@"Roster was: %@",fvc.roster_list);
 [fvc.roster_list addObject:fullJid];
 NSSet *tmp = [NSSet setWithArray:fvc.roster_list]; 
 fvc.roster_list = [[NSMutableArray alloc] initWithArray:[tmp allObjects]];
 DebugLog(@"Roster now: %@",fvc.roster_list);
 }
 
 [ [buttons.tabBarController.viewControllers objectAtIndex:TAB_DEVICES] reloadData] ;
 
 */



/*
 // Core Data XMPPUserCoreDataStorage
 NSEntityDescription *entity1 = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorage" inManagedObjectContext:buttons.xmppRosterStorage.managedObjectContext];
 NSFetchRequest *fetchRequest1 = [[NSFetchRequest alloc] init];
 [fetchRequest1 setEntity:entity1 ];
 [fetchRequest1 setIncludesPendingChanges:YES];
 [fetchRequest1 setFetchLimit:100];
 NSArray *results1 = [buttons.xmppRosterStorage.managedObjectContext executeFetchRequest:fetchRequest1 error:nil];
 for (NSEntityDescription *entity1 in results1) {
 // DebugLog(@"jidstr: %@  ", [entity1 jidStr]);
 
 } 
 
 // Core Data XMPPCapabilitiesCoreDataStorage
 
 NSEntityDescription *cdb = [NSEntityDescription entityForName:@"XMPPCapsCoreDataStorageObject" inManagedObjectContext:buttons.xmppCapabilitiesStorage.managedObjectContext];
 // DebugLog(@"CAPS DB: %@", cdb);
 NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];
 [fetchRequest2 setEntity:cdb];
 [fetchRequest2 setIncludesPendingChanges:YES];
 [fetchRequest2 setFetchLimit:100];
 NSArray *caps = [buttons.xmppCapabilitiesStorage.managedObjectContext executeFetchRequest:fetchRequest2 error:nil];
 //DebugLog(@"Got array of caps: %@", caps);	
 
 for (NSEntityDescription *c in caps) {
 DebugLog(@"CAPS XMPPCapsCoreDataStorageObject: capabilities: \n\t%@\n\n", [c capabilities]);
 //DebugLog(@"CAPS XMPPCapsCoreDataStorageObject: capabilitiesStr: %@ ", [c capabilitiesStr]);
 NSSet *capSet = [c resources];
 for (XMPPCapsResourceCoreDataStorageObject *x in capSet) 
 {
 DebugLog(@"CAPS XMPPCapsResourceCoreDataStorageObject RESOURCE: ext: %@  failed: %@ hashAlgorithm: %@ hashStr: %@ jidStr: %@ node: %@ ver: x", 
 [x ext], [x failed], [x hashAlgorithm], [x hashStr],[x jidStr], [x node] );
 }
 }
 */