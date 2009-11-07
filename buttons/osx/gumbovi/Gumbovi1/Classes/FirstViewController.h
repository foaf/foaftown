//
//  FirstViewController.h
//  Gumbovi1
//
//  Created by Dan Brickley on 11/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController {

	IBOutlet UITextField *userid;
	IBOutlet UITextField *password;

	IBOutlet UIButton *plus;
	IBOutlet UIButton *minu;
	IBOutlet UIButton *left;
	IBOutlet UIButton *righ;
	IBOutlet UIButton *plpz;
	IBOutlet UIButton *menu;

	IBOutlet UITextView *output;

	IBOutlet NSObject *appdel; // to get our xmpp session!
								// todo, find out how to use XMPPClient class here
								// do we import FirstViewController.h ? didnt work.
}

	@property (nonatomic, retain) IBOutlet NSObject *appdel;

	@property (nonatomic, retain) IBOutlet UITextField *userid;
	@property (nonatomic, retain) IBOutlet UITextField *password;
	
	// remote tab
	@property (nonatomic, retain) IBOutlet UIButton *plus;
	@property (nonatomic, retain) IBOutlet UIButton *minu;
	@property (nonatomic, retain) IBOutlet UIButton *left;
	@property (nonatomic, retain) IBOutlet UIButton *righ;
	@property (nonatomic, retain) IBOutlet UIButton *plpz;
	@property (nonatomic, retain) IBOutlet UIButton *menu;
	//
	@property (nonatomic, retain) IBOutlet UITextView *output;
	
	- (IBAction) updateText:(id) sender;
	- (IBAction) buttonDone:(id) sender;

@end
