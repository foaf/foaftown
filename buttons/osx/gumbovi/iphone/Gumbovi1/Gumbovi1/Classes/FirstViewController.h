//
//  FirstViewController.h
//  Gumbovi1
//
//  Created by Dan Brickley on 11/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gumbovi1AppDelegate.h"

@interface FirstViewController : UIViewController {

	IBOutlet UITextField *userid;
	IBOutlet UITextField *password;

//IBOutlet UIWebView *webview;
	
	IBOutlet UIButton *plus;
	IBOutlet UIButton *minu;
	IBOutlet UIButton *left;
	IBOutlet UIButton *righ;
	IBOutlet UIButton *plpz;
	IBOutlet UIButton *menu;
	IBOutlet UIButton *like;
	IBOutlet UIButton *okay;
	IBOutlet UIButton *info;
	IBOutlet UITextView *output;
	IBOutlet UISlider *volume;
	NSMutableArray *roster_list;
	float last_vol;
}

	@property (nonatomic, retain) IBOutlet Gumbovi1AppDelegate *appdel;	
	@property (nonatomic, retain) IBOutlet UITextField *userid;
	@property (nonatomic, retain) IBOutlet UITextField *password;
	
	// remote tab
	@property (nonatomic, retain) IBOutlet UIButton *plus;
	@property (nonatomic, retain) IBOutlet UIButton *minu;
	@property (nonatomic, retain) IBOutlet UIButton *left;
	@property (nonatomic, retain) IBOutlet UIButton *righ;
	@property (nonatomic, retain) IBOutlet UIButton *plpz;
	@property (nonatomic, retain) IBOutlet UIButton *menu;
    @property (nonatomic, retain) IBOutlet UIButton *like;
	@property (nonatomic, retain) IBOutlet UIButton *okay;
	@property (nonatomic, retain) IBOutlet UIButton *info;
	@property (nonatomic, retain) IBOutlet UITextView *output;
	@property (nonatomic, retain) IBOutlet UISlider *volume;
	@property (nonatomic, retain) NSMutableArray *roster_list;
	@property float last_vol;

	- (IBAction) updateText:(id) sender;
	- (IBAction) buttonDone:(id) sender;
	- (IBAction) buttonTouchVibrate:(id) sender;
	- (IBAction) connectionSetup:(id)sender;
    - (IBAction) textFieldShouldReturnUITextField:(id)sender;

@end
