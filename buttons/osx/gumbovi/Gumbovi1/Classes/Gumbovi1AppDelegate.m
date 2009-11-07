//
//  Gumbovi1AppDelegate.m
//  Gumbovi1
//
//  Created by Dan Brickley on 11/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "Gumbovi1AppDelegate.h"
#import "XMPP.h"

@implementation Gumbovi1AppDelegate

@synthesize xmppclient;
@synthesize window;
@synthesize tabBarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
    xmppClient = [[XMPPClient alloc] init];
	[xmppClient addDelegate:self];
	[xmppClient setDomain:@"foaf.tv"];
	[xmppClient setPort:5222];	
	[xmppClient setMyJID:[XMPPJID jidWithString:@"buttons@foaf.tv/iPhoneTest"]];
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
}

- (void)sendLEFT:(NSObject *)button
{
	NSLog(@"SENDING LEFT %@", button);
}

- (void)sendRIGH:(NSObject *)button
{
	NSLog(@"SENDING RIGH %@", button);
}

- (void)sendMINU:(NSObject *)button
{
	NSLog(@"SENDING MINU %@", button);
}

- (void)sendPLPZ:(NSObject *)button
{
	NSLog(@"SENDING PLPZ %@", button);
//	- (void)sendMessage:(NSString *)message toJID:(XMPPJID *)jid;
    // create msg and aJid

	NSString *msg = @"Hello alice, we got a PLPZ event.";
    XMPPJID *aJid = [XMPPJID jidWithString:@"alice.notube@gmail.com"];
	[ self.xmppclient sendMessage:msg toJID:aJid ] ;
	NSLog(@"Sent msg %@", msg);
	NSLog(@"To jid %@", aJid);

}

- (void)sendMENU:(NSObject *)button
{
	NSLog(@"SENDING MENU %@", button);
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
}




@end

