//
//  Gumbovi1AppDelegate.m
//  Gumbovi1
//
//  Created by Dan Brickley on 11/7/09.
//  This code - license: MIT, Share-and-Enjoy.
//  See embedded XMPP, KissXML and IDN libs for their distribution terms.
//  (c) Dan Brickley <danbri@danbri.org> & VU University Amsterdam
//
//  Thanks to Chris van Aart, Jens Finkhäuser, and Daniel Salber for Xcode & Obj-C advice.
//
// xcode 101 notes:
// jens: well, the idea is that firstviewcontroller controls the tab contents, app delegate controls tabs.
// I suspect I'd hook most of what you've talked about up in firstviewcontroller
//
// daniel: the easy way to get hold of the app delegate is: [[UIApplication sharedApplication] delegate]


// Status: we can connect to XMPP and route events between iphone UI and remote JIDs
// we don't load our username and password from the UI fields yet
// - when keyboard is used on phone, it won't go away
// - there is no protocol design
// - for now, simply sending physical-style messages (ie. which key pressed)
// - should impl some services, eg. list videos


#import "XMPP.h"
#import "FirstViewController.h"
#import "WebViewController.h"
#import "Gumbovi1AppDelegate.h"
#import "XMPPJID.h"
#import "AudioToolbox/AudioServices.h"
/// from lists drilldown demo
#import "RootViewController.h"

#import "SLRootViewController.h"

// xml stuff
#import "DDXMLNode.h"
#import "DDXMLElement.h"
#import "DDXMLDocument.h"
#import "NSStringAdditions.h"

// for qr
#import "DecoderController.h"
//#import "WebViewController.h"

@implementation Gumbovi1AppDelegate

// from lists
@synthesize navigationController;
@synthesize data;
// end lists stuff

//@synthesize webController;


@synthesize decoder_window;
@synthesize qr_results;

//#import <Foundation/NSString.h>

//@synthesize listswindow;


@synthesize xmppClient;
@synthesize window;
@synthesize tabBarController;
@synthesize toJid;
@synthesize aJid;
@synthesize htmlInfo;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    NSLog(@"TIMER: app delegate appplicationDidFinishLaunching, adding tabBar...");
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];

	//
	// for http://developer.apple.com/iphone/library/documentation/UIKit/Reference/UIWebView_Class/Reference/Reference.html#//apple_ref/occ/instm/UIWebView/loadData:MIMEType:textEncodingName:baseURL: 
	// in WebViewController
	self.htmlInfo = @"<html><head><title>Now Playing</title></head><body><h1>Now Playing</h1><p>...not known.</p></body></html>";
	NSLog(@"gad launched. self.htmlInfo is: %@", self.htmlInfo);
	
	// from drilldown lists code
	NSString *Path = [[NSBundle mainBundle] bundlePath];
	NSString *DataPath = [Path stringByAppendingPathComponent:@"Data.plist"];
	NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:DataPath];
	self.data = tempDict;
	[tempDict release];
	NSLog(@"appDidFinishLaunching ... we set up our data dict: %@", self.data);
	// Configure and show the window	


}

//- (void)initXMPP: (NSObject *)config  {
- (void)initXMPP  {
    NSLog(@"initXMPP *****");
	FirstViewController * fvc = (FirstViewController *) tabBarController.selectedViewController;
    NSLog(@"TIMER: (?re-)Initialising XMPP");
	NSLog(@"FVC is", fvc);
    xmppClient = [[XMPPClient alloc] init];
	[xmppClient addDelegate:self];
	[xmppClient setPort:5222];	
	NSLog(@"Userid: %@", fvc.userid.text);
	NSLog(@"Passwd: %@", fvc.password.text);
  //  XMPPJID aJID = [XMPPJID jidWithString:fvc.userid.text];
	//NSLog("aJiD: ",aJID);
	
	if(( [fvc.userid.text rangeOfString:@"gmail"].location == NSNotFound)){
		NSLog(@"gmail not found in user JID %@", fvc.userid.text);
		NSLog(@"We should parse out the host name...?");
	} else {
		NSLog(@"Hostname matched gmail in JID so setting domain to talk.google.com");
		[xmppClient setDomain:@"talk.google.com"]; // should do this (i) inspect domain name in JID, (ii) dns voodoo
	}
	
	[xmppClient setMyJID:[XMPPJID jidWithString:@"alice.notube@gmail.com/gmb1"]]; // should not be hardcoded
	[xmppClient setPassword:@"gargonza"];

    if (fvc.userid.text != NULL) {
		NSLog(@"GAD: User wasn't null so setting userid to be it: %@",  fvc.userid.text);	
	//	NSString *myjs =  [NSString stringWithFormat:@"", fvc.userid.text, @"/gmb1"] ; // todo: random /resource ? 
		[xmppClient setMyJID:[XMPPJID jidWithString:fvc.userid.text]];
	    //XMPPJID aJID = [xmppClient myJID];
	/////	NSLog("MY JID IS NOW: ",xmppClient.myJID);
	}
    if (fvc.password.text != NULL) {
		NSLog(@"GAD Pass wasn't null so setting userid to be it: %@", fvc.password.text);	
		[xmppClient setPassword:fvc.password.text];
	}
	NSLog(@"XMPP in initXMPP DEBUG: u: %@ p: %@",xmppClient.myJID, xmppClient.password);

//	self.toJid = [XMPPJID jidWithString:@"buttons@foaf.tv/gumboviListener"]; // buddy w/ media services

	self.toJid = [XMPPJID jidWithString:@"zetland.mythbot@googlemail.com/Basicbot"]; // buddy w/ media services
    //libby
    NSMutableArray *roster = fvc.roster_list;
//	for (NSString *s in roster) {
//		NSLog(@"hello %@",s);
//	}
    NSLog(@"roster list2: %@",roster);	
	
//       if(it rangeOfString:@self.toJid !=NSNotFound)

	

	
//	self.toJid = [XMPPJID jidWithString:@"bob.notube@gmail.com/gumboviListener"]; // buddy w/ media services

	
	[xmppClient setAutoLogin:YES];
	[xmppClient setAllowsPlaintextAuth:NO];
	[xmppClient setAutoPresence:YES];
	[xmppClient setAutoRoster:YES];
	[xmppClient connect];
	
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
	NSLog(@"TIMER: app delegate didEndCustomizingViewControllers");
}



- (void)dealloc {
	[data release]; // lists /drilldown
	[navigationController release]; // lists drilldown
    [tabBarController release];
    [window release];
    [super dealloc];
}





- (void)sendPLUS:(NSObject *)button
{
	NSLog(@"SENDING PLUS%@", button);
	NSString *msg = @"PLUS event.";
	[ self.xmppClient sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendLEFT:(NSObject *)button
{
	NSLog(@"SENDING LEFT %@", button);
	NSString *msg = @"LEFT event.";
	[ self.xmppClient sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendRIGH:(NSObject *)button
{
	NSLog(@"SENDING RIGH %@", button);
	NSString *msg = @"RIGH event.";
	[ self.xmppClient sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendMINU:(NSObject *)button
{
	NSLog(@"SENDING MINU %@", button);
	NSString *msg = @"MINU event.";
	[ self.xmppClient sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendPLPZ:(NSObject *)button
{
	NSLog(@"SENDING PLPZ %@", button);
    //	- (void)sendMessage:(NSString *)message toJID:(XMPPJID *)jid;
	NSString *msg = @"PLPZ event.";
	[ self.xmppClient sendMessage:msg toJID:self.toJid ] ;
	NSLog(@"Sent msg %@", msg);
	NSLog(@"To jid %@", self.toJid);
	NSLog(@" XMPP CLient: %@", self.xmppClient );
	//NSLog(@" XMPP CLient connected?: %@", self.xmppClient.isConnected );

}

- (void)sendMENU:(NSObject *)button
{
	NSLog(@"SENDING MENU %@", button);
	NSString *msg = @"MENU event.";
	[ self.xmppClient sendMessage:msg toJID:self.toJid ] ;

//    XMPPJID *aJid = [XMPPJID jidWithString:@"alice.notube@gmail.com"];
//	[ self.xmppClient sendMessage:msg toJID:aJid ] ;
}

- (void)sendLIKE:(NSObject *)button
{
	NSLog(@"SENDING LIKE %@", button);
	NSString *msg = @"LIKE event.";
	[ self.xmppClient sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendOKAY:(NSObject *)button
{
	//NSString *msg = @"OKAY event.";
	//[ self.xmppClient sendMessage:msg toJID:self.toJid ] ;

	NSLog(@"SENDING IQ OKAY %@", button);
	NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
	    [errorDetail setValue:@"Failed to do something" forKey:NSLocalizedDescriptionKey];
	NSError    *bError = [NSError errorWithDomain:@"buttons" code:100 userInfo:errorDetail];

	// should we manually send from too? from='%@', [xmppClient.myJID full] ... dow e need id= ?
	NSString *myXML = [NSString stringWithFormat:@"<iq type='get' to='%@'><query xmlns='http://buttons.foaf.tv/'><button>OKAY</button></query></iq>", [toJid full]];
	NSLog(@"myXML: %@",myXML);
	NSXMLElement *myStanza = [[NSXMLElement alloc]  initWithXMLString:myXML error:&bError];
	NSLog(@"Sending IQ okay via %@ ", self.xmppClient);
	NSLog(@"Markup was: %@",myStanza);
	[self.xmppClient sendElement:myStanza];

	// not working. try this?
	
/*	NSXMLElement *buttons = [NSXMLElement elementWithName:@"buttons" xmlns:@"http://buttons.foaf.tv/"];
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
	[iq addAttributeWithName:@"type" stringValue:@"get"];
	[iq addChild:buttons];
	[self.xmppClient sendElement:iq]; */
	
	
}

- (void)sendINFO:(NSObject *)button
{
	NSLog(@"SENDING INFO %@", button);
	NSString *msg = @"INFO event.";
	[ self.xmppClient sendMessage:msg toJID:self.toJid ] ;
}

- (void)sendLOUD:(NSObject *)myS;
{
	FirstViewController * fvc = (FirstViewController *) tabBarController.selectedViewController;
	NSString *v = [NSString stringWithFormat:@"%@ %.1f", @"LOUD", fvc.volume.value];
	NSLog(@"SENDING LOUD %@", v  );
	[ self.xmppClient sendMessage:v toJID:self.toJid ] ;
}

- (void)sendHUSH:(NSObject *)myS;
{
	FirstViewController * fvc = (FirstViewController *) tabBarController.selectedViewController;
	NSString *v = [NSString stringWithFormat:@"%@ %.1f", @"HUSH", fvc.volume.value];
	NSLog(@"SENDING HUSH %@", v  );
	[ self.xmppClient sendMessage:v toJID:self.toJid ] ;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPClient Delegate Methods:
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppClientConnecting:(XMPPClient *)sender
{
	NSLog(@"==============================================================");
	NSLog(@"iPhoneXMPPAppDelegate: xmppClientConnecting");
	NSLog(@"==============================================================");
}

- (void)xmppClientDidConnect:(XMPPClient *)sende
{
	NSLog(@"==============================================================");
	NSLog(@"iPhoneXMPPAppDelegate: xmppClientDidConnect");
	NSLog(@"==============================================================");
}

- (void)xmppClientDidNotConnect:(XMPPClient *)sender
{
	NSLog(@"==============================================================");
	NSLog(@"iPhoneXMPPAppDelegate: xmppClientDidNotConnect");
	NSLog(@"==============================================================");
}

- (void)xmppClientDidDisconnect:(XMPPClient *)sender
{
	NSLog(@"==============================================================");
	NSLog(@"iPhoneXMPPAppDelegate: xmppClientDidDisconnect");
	NSLog(@"==============================================================");
}

- (void)xmppClientDidRegister:(XMPPClient *)sender
{
	NSLog(@"==============================================================");
	NSLog(@"iPhoneXMPPAppDelegate: xmppClientDidRegister");
	NSLog(@"==============================================================");
}

- (void)xmppClient:(XMPPClient *)sender didNotRegister:(NSXMLElement *)error
{
	NSLog(@"==============================================================");
	NSLog(@"iPhoneXMPPAppDelegate: xmppClient:didNotRegister: %@", error);
	NSLog(@"==============================================================");
}

- (void)xmppClientDidAuthenticate:(XMPPClient *)sender
{
	NSLog(@"==============================================================");
	NSLog(@"iPhoneXMPPAppDelegate: xmppClientDidAuthenticate");
	NSLog(@"==============================================================");
}

- (void)xmppClient:(XMPPClient *)sender didNotAuthenticate:(NSXMLElement *)error
{
	NSLog(@"==============================================================");
	NSLog(@"iPhoneXMPPAppDelegate: xmppClient:didNotAuthenticate: %@", error);
	NSLog(@"==============================================================");
}

- (void)xmppClientDidUpdateRoster:(XMPPClient *)sender
{
	NSLog(@"==============================================================");
	NSLog(@"iPhoneXMPPAppDelegate: xmppClientDidUpdateRoster");
	NSLog(@"Update msg is: %@",sender);
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Updated roster!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
//	[alert show]; [alert release]; 
	[sender fetchRoster]; // make sure we're up to date (necessary?)
	NSArray *buddies = [sender sortedAvailableUsersByName];
    NSLog(@"XMPP Roster has been updated. Reviewing its membership. Each JID has potentially multiple active connections (resources). We should add these to our local buddylist UI.");
    NSLog(@"The XMPP Roster is (accounts not full JIDs with resources): %@", buddies);
	NSEnumerator *e = [buddies objectEnumerator];
	id object;
	while (object = [e nextObject]) {
		NSLog(@"Do we add %@ ? ", object);
		NSLog(@"resources for jid is %@ ? ", [object sortedResources] );
		NSEnumerator *e = [[object sortedResources] objectEnumerator];
		id r;

		while (r = [e nextObject]) {

            //get the presence
			//not sure how to display it!
			XMPPPresence *pres = [[XMPPPresence alloc] init];
			pres = [XMPPPresence presenceFromElement:[r presence]];
			NSLog(@"pres is %@", pres);
			NSLog(@"presence is %@", [pres status]);

			NSLog(@"Sending discovery IQ to %@", r);
			

			// add to UI rosterx xxxxxxxxxxx
			FirstViewController * fvc = (FirstViewController *) tabBarController.selectedViewController;

			//[fvc.roster_list addObject:[NSString stringWithFormat:@"%@",[r jid]]];
            //adding to the end not the start. it crashes a lot either way so wrapping in try catch
			@try { 
				[fvc.roster_list insertObject:[NSString stringWithFormat:@"%@",[r jid]] atIndex:0];
			}
                @catch (NSException *exception) {
				NSLog(@"main: Caught %@: %@", [exception name],  [exception reason]); 
			} 

            NSLog(@"adding to roster %@", r);
			NSLog(@"TOJID %@", self.toJid);
			
			NSXMLElement *disco = [NSXMLElement elementWithName:@"iq"];
			[disco addAttributeWithName:@"type" stringValue:@"get"];
			//[disco addAttributeWithName:@"from" stringValue:[[sender myJID] full]];
			// got If set, the 'from' attribute must be set to the user's full JID (400 error) when only sending foo@bar
			
			[disco addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",[r jid]  ]];
			[disco addAttributeWithName:@"id" stringValue:@"disco1"];
			[disco addChild:[NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"]];
			NSLog(@"About to send %@", disco);
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

//		NSLog(@"myXML: %@",myXML);
//		NSXMLElement *myStanza = [[NSXMLElement alloc]  initWithXMLString:myXML error:&bError];
//		NSLog(@"Sending IQ okay via %@ ", self.xmppClient);
//		NSLog(@"Markup was: %@",myStanza);
//		[self.xmppClient sendElement:myStanza];
	
	
	}
	
	NSLog(@"==============================================================");
}

- (void)xmppClient:(XMPPClient *)sender didReceiveBuddyRequest:(XMPPJID *)jid
{
	NSLog(@"==============================================================");
	NSLog(@"iPhoneXMPPAppDelegate: xmppClient:didReceiveBuddyRequest: %@", jid);
	NSLog(@"==============================================================");
}

- (void)xmppClient:(XMPPClient *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSLog(@"==============================================================");
	NSLog(@"iPhoneXMPPAppDelegate: xmppClient:didReceiveIQ: %@", iq);
	
	NSLog(@"XXXNOWPTESTER Is this IQ a buttons response?");
	NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
	[errorDetail setValue:@"Failed to decode NOWP IQ" forKey:NSLocalizedDescriptionKey];
	NSError    *error = [NSError errorWithDomain:@"buttons" code:100 userInfo:errorDetail];
//	NSArray *nowpNodes = [iq nodesForXPath:@"./iq/nowp-result" error:&error];
//ok	NSArray *nowpNodes = [iq nodesForXPath:@"." error:&error];
	//NSArray *nowpNodes = [iq nodesForXPath:@"./iq/nowp-result/" error:&error];
	//NSLog(@"nowp results: %@", nowpNodes);
	//NSEnumerator *enumerator = [nowpNodes objectEnumerator];
    //id obj;	
    //while ( obj = [enumerator nextObject] ) {
    //    printf( "%s\n", [[obj description] cString] );
    //}
	
	// Sleazy XML handling
	DDXMLElement *x = (DDXMLElement *)[iq childAtIndex:0];
	DDXMLElement *x2 = (DDXMLElement *) [x childAtIndex:0];
	NSString *xs = 	[NSString stringWithFormat:@"%@", x2];
	NSLog(@"X2: %@",xs);
	
	if([xs rangeOfString:@"<div>"].location == NSNotFound){
		NSLog(@"div not found in xs %@", xs);
	} else {
		NSLog(@"Setting self.htmlInfo to: %@",xs);
		self.htmlInfo = xs;

		WebViewController *wvc = (WebViewController *) [self.tabBarController.viewControllers objectAtIndex:1];//ugh
		NSURL *baseURL = [NSURL URLWithString:@"http://buttons.notube.tv/"];		
		[wvc.webview loadHTMLString:self.htmlInfo baseURL:baseURL];		

	
	}
//		NSLog(@"xs was null, assuming we didn't find HTML. should check xmlns/element or at least for a <div>");	
	
	// Nothing works. Related attempts:
	// additions see http://code.google.com/p/kissxml/issues/detail?id=18
	// http://groups.google.com/group/xmppframework/browse_thread/thread/1ae1f1ca58abbd90
	//	DDXMLElement *info = [iq elementForName:@"nowp-result" xmlns:@"http://buttons.foaf.tv/"];
	//	NSLog(@"BUTTONS NOWP markup: %@",info);
	//	NSLog(@"XMLHELP: 1st child is: %@",x);

	
	NSLog(@"==============================================================");
    

}

- (void)xmppClient:(XMPPClient *)sender didReceiveMessage:(XMPPMessage *)message
{
	NSLog(@"==============================================================");
	NSLog(@"iPhoneXMPPAppDelegate: xmppClient:didReceiveMessage: %@", message);
	NSLog(@"==============================================================");
	//tabBarController.selectedViewController.output.text = @"Got message!";

	
	// FirstViewController * fvc = (FirstViewController *) tabBarController.selectedViewController;
    NSString *m = (NSString *) [  message elementForName:@"body"  ] ;	

	// fvc.output.text = m.description;  // trying to strip out <body> and <body/> below gives trouble

	NSString *log = m.description;
	log = [[log stringByReplacingOccurrencesOfString:@"<body>" withString:@""] stringByReplacingOccurrencesOfString:@"</body>" withString:@""];
	[log retain];
	  // @"......"; m.description;  //log ;			//+ [NSString log]; //  m.description;
    
	//fvc.output.text = log; // problem?
    NSLog(log);
}



/// LISTS

/// copied from DrillDownApp 

	


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}



- (void) startQRScan:(id)sender {
	NSLog(@"Starting qr scan. %@ ", sender);
	//Gumbovi1AppDelegate *gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];	
	UINavigationController *myQrController = [tabBarController.viewControllers objectAtIndex:4];
    NSLog(@"My qr controller in 5th tab is %@ " , myQrController); // a UINavigationController
	decoderController = [[DecoderController alloc] init];
    NSLog(@"Trying to push a DecoderController %@ ", decoderController);
	NSLog(@"...onto my UINavigationController %@ ", myQrController);
	[myQrController pushViewController:decoderController animated:YES];
	self.decoder_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];	
		//	self.decoder_window = [[UIWindow alloc] initWithFrame:myQrController.view.bounds ];	
	[decoder_window addSubview:decoderController.view];	
}

- (void)newJID:(id)jid {
	NSLog(@"Got a new Linked TV via QR code. Setting toJID to: %@",jid);	
    self.qr_results.text=jid;
	self.toJid = [XMPPJID jidWithString:jid]; // buddy w/ media services
	FirstViewController * fvc = (FirstViewController *) [tabBarController.viewControllers objectAtIndex:0];//ugh
    NSMutableArray *roster = fvc.roster_list;
	NSLog(@"Roster was: %@",roster);
	[fvc.roster_list addObject:jid];
	NSLog(@"Roster now: %@",roster);
	NSLog(@"gad.toJID is now: %@",self.toJid);
	
	//see also http://www.freesound.org/samplesViewSingle.php?id=706 etc - can try for haptic on button presses
	NSString *path = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/pop.wav"];
		SystemSoundID soundID;
		NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
		AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
		AudioServicesPlaySystemSound(soundID);
}

@end

