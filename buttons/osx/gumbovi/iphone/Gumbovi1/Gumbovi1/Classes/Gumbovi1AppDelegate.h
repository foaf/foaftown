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

//@class DecoderController;
@class XMPPClient;

@interface Gumbovi1AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	XMPPClient *xmppClient;
    UIWindow *window;
    UITabBarController *tabBarController;
    XMPPJID *toJid;
    XMPPJID *aJid;
	
	// qrcodes	
	DecoderController*  decoderController;
	UIWindow* decoder_window;
	NSString* qr_buddy;
	//UITextField* qr_results;
	
	// lists drilldown
	UINavigationController *navigationController;
	NSDictionary *data;
	//FirstViewController *fvc;

	UITextField* qr_results;//libby

}
//@property (nonatomic, retain) IBOutlet FirstViewController *fvc;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet XMPPClient *xmppClient; 
@property (nonatomic, retain) IBOutlet XMPPJID *toJid; 
@property (nonatomic, retain) IBOutlet XMPPJID *aJid; 

@property (nonatomic, retain) IBOutlet UITextField *qr_results; 

// lists drilldown
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSDictionary *data;


@property (nonatomic, retain) UIWindow *decoder_window;
//@property (nonatomic, retain) NSString *qr_buddy;


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


@end
