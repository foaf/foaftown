//
//  FirstViewController.m
//  Gumbovi1
//
//  Created by Dan Brickley on 11/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "FirstViewController.h"


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


- (void) updateText:(id)sender {
   
	NSLog(@" updatedText called ");

    return;
}

- (void) buttonDone:(id)sender {
	
	NSLog(@" buttonDone called: %@", sender);
    if (sender == self.plus) {
		NSLog(@"PLUS");
	} 
	else if (sender == self.left) {
		NSLog(@"LEFT");
	} 
	else if (sender == self.minu) {
		NSLog(@"MINU");
	} 
	else if (sender == self.righ) {
		NSLog(@"RIGH");
	}
	else if (sender == self.plpz) {
		NSLog(@"PLPZ");
	}
	else if (sender == self.menu) {
	    NSLog(@"MENU");	
	}
	else {
		NSLog(@"Unrecognised buttonDown UI action: %@", sender);
	}
    return;
}

@end
