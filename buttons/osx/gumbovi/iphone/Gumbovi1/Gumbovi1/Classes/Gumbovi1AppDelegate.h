//
//  Gumbovi1AppDelegate.h
//  Gumbovi1
//
//  Created by Dan Brickley on 11/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"

@class XMPPClient;
@interface Gumbovi1AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	XMPPClient *xmppClient;
    UIWindow *window;
    UITabBarController *tabBarController;
//FirstViewController *fvc;

}
//@property (nonatomic, retain) IBOutlet FirstViewController *fvc;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet XMPPClient *xmppClient; // how to make accessible elsewhere?

	- (IBAction) sendMENU:(id) button;
	- (IBAction) sendPLPZ:(id) button;
	- (IBAction) sendPLUS:(id) button;
	- (IBAction) sendMINU:(id) button;
	- (IBAction) sendLEFT:(id) button;
	- (IBAction) sendRIGH:(id) button;

@end
