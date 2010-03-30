//
//  Gumbovi1AppDelegate.h
//  Gumbovi1
//
//  Created by Dan Brickley on 11/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "XMPPJID.h"
#import "DecoderController.h"
#import "ButtonDeviceList.h"
#import "XMPPRoster.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilities.h"
#import "XMPPCapabilitiesCoreDataStorage.h"

//@class DecoderController;
@class XMPPStream;
@interface Gumbovi1AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UITableViewDelegate, UITableViewDataSource>
{
	XMPPStream *xmppLink;
    UIWindow *window;
    UITabBarController *tabBarController;
    XMPPJID *toJid;
    XMPPJID *aJid;
	ButtonDeviceList *buttonDevices;
	DecoderController *decoderController;
	UIWindow *decoder_window;
	NSString *qr_buddy;
	UINavigationController *navigationController;
	NSDictionary *data;
	UITextField *qr_results;//libby
	NSString *password;
	NSString *htmlInfo;
	XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
	XMPPReconnect *xmppReconnect;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	BOOL isOpen;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet XMPPStream *xmppLink; 
@property (nonatomic, retain) IBOutlet XMPPJID *toJid; 
@property (nonatomic, retain) IBOutlet XMPPJID *aJid; 
@property (nonatomic, retain) IBOutlet UITextField *qr_results; 
@property (nonatomic, retain) IBOutlet ButtonDeviceList *buttonDevices;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) UIWindow *decoder_window;
@property (nonatomic, retain) NSString *htmlInfo;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, readonly) XMPPRoster *xmppRoster;								// XMPP
@property (nonatomic, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

- (IBAction) sendMENU:(id) button;
- (IBAction) sendLIKE:(id) button;
- (IBAction) sendPLPZ:(id) button;
- (IBAction) sendPLUS:(id) button;
- (IBAction) sendMINU:(id) button;
- (IBAction) sendLEFT:(id) button;
- (IBAction) sendRIGH:(id) button;
- (IBAction) sendOKAY:(id) button;
- (IBAction) sendLOUD:(id) button;
- (IBAction) sendHUSH:(id) button;
- (IBAction) sendINFO:(id) button;
- (void) initXMPP: (id) config;
- (void) initXMPP;//hmmtodo fix

//	- (IBAction) setTargetJID:(XMPPJID) jid;

- (IBAction) startQRScan:(id) sender;
- (void) newJID:(NSString *) jid;
- (void)connectIfOffline;
- (void)setTargetJidWithString:(NSString *)someJid;
- (void)sendIQ:(NSXMLElement *)myStanza;

@end
