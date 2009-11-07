//
//  Gumbovi1AppDelegate.h
//  Gumbovi1
//
//  Created by Dan Brickley on 11/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>


@class XMPPClient;


@interface Gumbovi1AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	XMPPClient *xmppClient;
    UIWindow *window;
    UITabBarController *tabBarController;

}


//@property (nonatomic, retain) IBOutlet UITextField *userid;
//@property (nonatomic, retain) IBOutlet UITextField *password;

// remote tab
//@property (nonatomic, retain) IBOutlet UIButton *plus;
//@property (nonatomic, retain) IBOutlet UIButton *minu;
//@property (nonatomic, retain) IBOutlet UIButton *left;
//@property (nonatomic, retain) IBOutlet UIButton *righ;
//@property (nonatomic, retain) IBOutlet UIButton *plpz;
//@property (nonatomic, retain) IBOutlet UIButton *menu;
//
//@property (nonatomic, retain) IBOutlet UITextView *output;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;


@end
