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
#import "Gumbovi1AppDelegate.h"
#import "XMPPJID.h"

//#import <Foundation/NSString.h>

@implementation Gumbovi1AppDelegate

@synthesize xmppClient;
@synthesize window;
@synthesize tabBarController;
@synthesize toJid;
@synthesize aJid;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	
	NSLog(@"TIMER: app delegate appplicationDidFinishLaunching, adding tabBar...");

    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
	NSLog(@"TIMER: connecting to XMPP");

}

//- (void)initXMPP: (NSObject *)config  {
- (void)initXMPP  {
    NSLog(@"initXMPP *****");
	FirstViewController * fvc = (FirstViewController *) tabBarController.selectedViewController;
    NSLog(@"TIMER: (?re-)Initialising XMPP");
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
	
	// [xmppClient setMyJID:[XMPPJID jidWithString:@"alice@gmail.com"]];
    if (fvc.userid.text != NULL) {
		NSLog(@"GAD: User wasn't null so setting userid to be it: %@",  fvc.userid.text);	
		[xmppClient setMyJID:[XMPPJID jidWithString:fvc.userid.text]];
	    //XMPPJID aJID = [xmppClient myJID];
	/////	NSLog("MY JID IS NOW: ",xmppClient.myJID);
	}
    if (fvc.password.text != NULL) {
		NSLog(@"GAD Pass wasn't null so setting userid to be it: %@", fvc.password.text);	
		[xmppClient setPassword:fvc.password.text];
	}
	NSLog(@"XMPP in initXMPP DEBUG: u: %@ p: %@", xmppClient.myJID, xmppClient.password);

//	self.toJid = [XMPPJID jidWithString:@"buttons@foaf.tv/gumboviListener"]; // buddy w/ media services

	self.toJid = [XMPPJID jidWithString:@"zetland.mythbot@googlemail.com/gumboviListener"]; // buddy w/ media services
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
	NSLog(@"SENDING OKAY %@", button);
	NSString *msg = @"OKAY event.";
	[ self.xmppClient sendMessage:msg toJID:self.toJid ] ;
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
	NSString *msg =  [NSString stringWithFormat:@"%.1f", fvc.volume.value];
//	NSString *msg = @"LOUDness event %@", ;
	NSLog(@"SENDING LOUD %@", msg  );
	[ self.xmppClient sendMessage:msg toJID:self.toJid ] ;
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




@end

