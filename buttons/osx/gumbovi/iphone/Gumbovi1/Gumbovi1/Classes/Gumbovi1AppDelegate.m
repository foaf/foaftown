//
//  Gumbovi1AppDelegate.m
//  Gumbovi1
//
//  Created by Dan Brickley on 11/7/09.

//
// thanks to Jens Finkhäuser and Daniel Salber for Obj-C advice
// XMPP smarts live in this zone...

// jens: well, the idea is that firstviewcontroller controls the tab contents, app delegate controls tabs.
// I suspect I'd hook most of what you've talked about up in firstviewcontroller


#import "XMPP.h"
#import "FirstViewController.h"
#import "Gumbovi1AppDelegate.h"

#import <Foundation/NSString.h>

@implementation Gumbovi1AppDelegate

@synthesize xmppClient;
@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
    xmppClient = [[XMPPClient alloc] init];
	[xmppClient addDelegate:self];
	
	// connect as buttons 
//	[xmppClient setDomain:@"foaf.tv"];
//	[xmppClient setPort:5222];	
//	[xmppClient setMyJID:[XMPPJID jidWithString:@"buttons@foaf.tv/iPhoneTest"]];
//	[xmppClient setPassword:@"gargonza"];	
	
	
	// or connect as bob?
	[xmppClient setDomain:@"talk.google.com"];
	[xmppClient setPort:5222];	
	[xmppClient setMyJID:[XMPPJID jidWithString:@"bob.notube@gmail.com/iPhoneTest"]];
	[xmppClient setPassword:@"gargonza"];	
	
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

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}


- (void)sendPLUS:(NSObject *)button
{
	NSLog(@"SENDING PLUS%@", button);
	NSString *msg = @"PLUS event.";
    XMPPJID *aJid = [XMPPJID jidWithString:@"buttons@foaf.tv"];
	[ self.xmppClient sendMessage:msg toJID:aJid ] ;
}

- (void)sendLEFT:(NSObject *)button
{
	NSLog(@"SENDING LEFT %@", button);
	NSString *msg = @"LEFT event.";
    XMPPJID *aJid = [XMPPJID jidWithString:@"buttons@foaf.tv"];
	[ self.xmppClient sendMessage:msg toJID:aJid ] ;
}

- (void)sendRIGH:(NSObject *)button
{
	NSLog(@"SENDING RIGH %@", button);
	NSString *msg = @"RIGH event.";
    XMPPJID *aJid = [XMPPJID jidWithString:@"buttons@foaf.tv"];
	[ self.xmppClient sendMessage:msg toJID:aJid ] ;
}

- (void)sendMINU:(NSObject *)button
{
	NSLog(@"SENDING MINU %@", button);
	NSString *msg = @"MINU event.";
    XMPPJID *aJid = [XMPPJID jidWithString:@"buttons@foaf.tv"];
	[ self.xmppClient sendMessage:msg toJID:aJid ] ;
}

- (void)sendPLPZ:(NSObject *)button
{
	NSLog(@"SENDING PLPZ %@", button);
    //	- (void)sendMessage:(NSString *)message toJID:(XMPPJID *)jid;
	NSString *msg = @"PLPZ event.";
    XMPPJID *aJid = [XMPPJID jidWithString:@"buttons@foaf.tv"];
	[ self.xmppClient sendMessage:msg toJID:aJid ] ;
	NSLog(@"Sent msg %@", msg);
	NSLog(@"To jid %@", aJid);
	NSLog(@" XMPP CLient: %@", self.xmppClient );

}

- (void)sendMENU:(NSObject *)button
{
	NSLog(@"SENDING MENU %@", button);
	NSString *msg = @"MENU event.";
    XMPPJID *aJid = [XMPPJID jidWithString:@"buttons@foaf.tv"];
	[ self.xmppClient sendMessage:msg toJID:aJid ] ;
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

- (void)xmppClientDidConnect:(XMPPClient *)sender
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
	/// tabBarDelegate window.output.text = @"Got message!" ;
	//tabBarController.selectedViewController.output.text = @"Got message!";
	FirstViewController * fvc = (FirstViewController *) tabBarController.selectedViewController;
    NSString *m = [ message elementForName:@"body"  ] ;
	fvc.output.text =  m.description;

}




@end

