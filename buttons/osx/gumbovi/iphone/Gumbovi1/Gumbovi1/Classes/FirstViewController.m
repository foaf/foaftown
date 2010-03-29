//
//  FirstViewController.m
//  Gumbovi1
//
//  Created by Dan Brickley on 11/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "FirstViewController.h"
#import "Gumbovi1AppDelegate.h"
#import "XMPP.h"
#import "XMPPClient.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation FirstViewController

@synthesize userid;
@synthesize password;
@synthesize plus;
@synthesize minu;
@synthesize left;
@synthesize righ;
@synthesize plpz;
@synthesize menu;
@synthesize like;
@synthesize okay;
@synthesize info;
@synthesize output;
//@synthesize appdel;
@synthesize volume;
@synthesize last_vol;
@synthesize roster_list;
/////@synthesize webview;


//@synthesize toggleSwitch;
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
//libby
	//self.roster_list = [NSMutableArray array];

	//@"zetland.mythbot@googlemail.com/Basicbot",
	//@"buttons@foaf.tv/Basicbot",
	//@"buttons@foaf.tv/t2",@"bob.notube@gmail.com",@"bob.notube@gmail.com/switchboard"
//    DebugLog(@"FVC viewDidLoad, set up array for roster: %@", self.roster_list);
	self.roster_list = [[NSMutableArray alloc] initWithObjects:nil]; 

}



- (BOOL)textFieldShouldReturn: (UITextField *)textField {
	DebugLog(@"textFieldShouldReturn");
	[textField resignFirstResponder];
	return YES;
}


// todo make an action: textFieldShouldReturn
// http://www.platinumball.net/blog/2009/03/03/iphone-newbie-view-coords-uitextfield/
// Finally, the keyboard won’t ever go away unless you write more code to dismiss it. You must make your view controller the 
// text control’s delegate and write a textFieldShouldReturn: method so you can do something with the Enter key and tell 
// the keyboard to go away. Six new methods later, your quest is at an end. Until the next time you need a UITextField.


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
	VerboseLog(@"FVC viewDidAppear! initiating network link if needed.");
	Gumbovi1AppDelegate *buttons = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	[buttons connectIfOffline];
	[super viewWillAppear:animated];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	// return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


- (void) connectionSetup:(id)sender {
	DebugLog(@"connection setup ... switch moved so restarting xmpp if it moved to On");
	DebugLog(@"SWITCH state: %@", sender);	
	Gumbovi1AppDelegate * gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];  
	if ([sender isOn]) {
	  DebugLog(@"SWITCHED: ON");	
  	  if (self.userid.text != NULL) {
	 	DebugLog(@"User wasn't null so setting userid to be it: %@", self.userid.text);	
		[gad.xmppLink setMyJID:[XMPPJID jidWithString:self.userid.text]];
	  }
      if (self.password.text != NULL) {
		DebugLog(@"Pass wasn't null so setting userid to be it: %@", self.password.text);	
		[gad.xmppLink setPassword:self.password.text];
	  }
	 // [gad initXMPP];	
     // causes  -[UIViewController userid]: unrecognized selector sent to instance 0x3d41dc0
		[gad.xmppLink disconnect]; // Have you tried turning it off and on again? :)
	  [gad.xmppLink connect];
	} else {
	  DebugLog(@"SWITCHED: ON");	
	  [gad.xmppLink disconnect];	
	}
}

- (void) updateText:(id)sender {
   
	DebugLog(@" updatedText called ");
	return;
}


- (void) buttonTouchVibrate:(id)sender {
	// TODO: Switch to audio clips? Disable? Wait for Apple to expose more expressive API? JIRA needed.
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


/*    BUTTONS PROTOCOL DETAILS 
		Half of this lives in the main class, half here. Move to a Buttons class!  JIRA needed.
		Code is dangerously repetitive. Also needs to use a real IQ protocol. XMPP logic should be encapsulated.
 */

- (void) buttonDone:(id)sender {
	
	Gumbovi1AppDelegate *buttons = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];

	
	DebugLog(@" buttonDone called: %@", sender);
    if (sender == self.plus) {
		DebugLog(@"PLUS");
		[buttons sendPLUS:sender];
		self.output.text = @"Plus";
	} 
	else if (sender == self.left) {
		DebugLog(@"LEFT");
		[buttons sendLEFT:sender];
		self.output.text = @"Left";

	} 
	else if (sender == self.minu) {
		DebugLog(@"MINU");
		[buttons sendMINU:sender];
		self.output.text = @"Minus";

	} 
	else if (sender == self.righ) {
		DebugLog(@"RIGH");
		[buttons sendRIGH:sender];
		self.output.text = @"Right";
	}
	else if (sender == self.plpz) {
		DebugLog(@"PLPZ");
		[buttons sendPLPZ:sender];
		self.output.text = @"Play/Pause";
	}
	else if (sender == self.menu) {
	    DebugLog(@"MENU");	
		[buttons sendMENU:sender];
		self.output.text = @"Menu";
	}
	else if (sender == self.like) {
	    DebugLog(@"LIKE");	
		[buttons sendLIKE:sender];
		self.output.text = @"Like";
	}
	else if (sender == self.okay) {
	    DebugLog(@"OKAY");	
		[buttons sendOKAY:sender];
		self.output.text = @"Okay";
	}
	else if (sender == self.info) {
	    DebugLog(@"INFO");	
		[buttons sendINFO:sender];
		self.output.text = @"Info";
	}
	else if (sender == self.volume) {
		// http://developer.apple.com/iphone/library/documentation/UIKit/Reference/UISlider_Class/Reference/Reference.html
		DebugLog(@"Volume : %f", self.volume.value);
		DebugLog(@"VOLUME Loudness change.");	
		DebugLog(@"Last volume: %f", self.last_vol);
		if (self.last_vol > self.volume.value) {
			DebugLog(@"LESSLOUD");
			[buttons sendHUSH:sender];
		} else {
			DebugLog(@"MORELOUD");
			[buttons sendLOUD:sender];
		}
		self.last_vol = self.volume.value;
		self.output.text = @"Loud: ", self.volume.value;
	}
	else {
		DebugLog(@"Unrecognised buttonDown UI action: %@", sender);
	}
    return;
}

@end
