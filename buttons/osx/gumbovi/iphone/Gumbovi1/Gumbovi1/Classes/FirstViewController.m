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


@implementation FirstViewController

@synthesize userid;
@synthesize password;
@synthesize plus;
@synthesize minu;
@synthesize left;
@synthesize righ;
@synthesize plpz;
@synthesize menu;
@synthesize output;
@synthesize appdel;


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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)textFieldShouldReturn: (UITextField *)textField {
	NSLog(@"textFieldShouldReturn");
	[textField resignFirstResponder];
	return YES;
}


// todo make an action: textFieldShouldReturn
// http://www.platinumball.net/blog/2009/03/03/iphone-newbie-view-coords-uitextfield/
// Finally, the keyboard won’t ever go away unless you write more code to dismiss it. You must make your view controller the 
// text control’s delegate and write a textFieldShouldReturn: method so you can do something with the Enter key and tell 
// the keyboard to go away. Six new methods later, your quest is at an end. Until the next time you need a UITextField.


// or did it? why nothing in logs?
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
	NSLog(@"TIMER viewDidAppear!");
	Gumbovi1AppDelegate * gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (! gad.xmppClient.isConnected ) {
	  	NSLog(@"View appeared, checked xmpp and it was disconnected ... connecting!");
        [gad initXMPP];
	} else {
		NSLog(@"We seem to be connected %@",gad.xmppClient);
	}
		
	NSLog(@"XMPP now: %@",gad.xmppClient);

//	NSLog(@"Got app delgate %@", gad.xmppClient  );
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	NSLog(@"connection setup ... switch moved so restarting xmpp");

    NSLog(@"SWITCH state: %@", sender);	
	Gumbovi1AppDelegate * gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];


    
	if (self.userid.text != NULL) {
		NSLog(@"User wasn't null so setting userid to be it: %@", self.userid.text);	
		[gad.xmppClient setMyJID:[XMPPJID jidWithString:self.userid.text]];
	}
    if (self.password.text != NULL) {
		NSLog(@"Pass wasn't null so setting userid to be it: %@", self.password.text);	
		[gad.xmppClient setPassword:self.password.text];
	}
	[gad.xmppClient disconnect];
	[gad.xmppClient connect];

}

- (void) updateText:(id)sender {
   
	NSLog(@" updatedText called ");

    return;
}

- (void) buttonDone:(id)sender {
	
	NSLog(@" buttonDone called: %@", sender);
    if (sender == self.plus) {
		NSLog(@"PLUS");
		[self.appdel sendPLUS:sender];
		self.output.text = @"Plus";
	} 
	else if (sender == self.left) {
		NSLog(@"LEFT");
		[self.appdel sendLEFT:sender];
		self.output.text = @"Left";

	} 
	else if (sender == self.minu) {
		NSLog(@"MINU");
		[self.appdel sendMINU:sender];
		self.output.text = @"Minus";

	} 
	else if (sender == self.righ) {
		NSLog(@"RIGH");
		[self.appdel sendRIGH:sender];
		self.output.text = @"Right";
	}
	else if (sender == self.plpz) {
		NSLog(@"PLPZ");
		[self.appdel sendPLPZ:sender];
		self.output.text = @"Play/Pause";
	}
	else if (sender == self.menu) {
	    NSLog(@"MENU");	
		[self.appdel sendMENU:sender];
		self.output.text = @"Menu";
	}
	else {
		NSLog(@"Unrecognised buttonDown UI action: %@", sender);
	}
    return;
}

@end
