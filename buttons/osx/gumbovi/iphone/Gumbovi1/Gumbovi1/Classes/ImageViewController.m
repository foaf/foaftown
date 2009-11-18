//
//  ImageViewController.m
//  DrillDownApp
//
//  Created by Jai Kirdatt on 3/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"


@implementation ImageViewController

@synthesize ImageName;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *Path = [[NSBundle mainBundle] bundlePath];
	NSString *ImagePath = [Path stringByAppendingPathComponent:ImageName];
	UIImage *tempImg = [[UIImage alloc] initWithContentsOfFile:ImagePath];
	[imgView setImage:tempImg];
	[tempImg release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[ImageName release];
	[imgView release];
    [super dealloc];
}


@end
