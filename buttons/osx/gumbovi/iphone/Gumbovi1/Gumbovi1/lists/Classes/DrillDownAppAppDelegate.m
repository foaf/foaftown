//
//  DrillDownAppAppDelegate.m
//  DrillDownApp
//
//  Created by iPhone SDK Articles on 3/8/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import "DrillDownAppAppDelegate.h"
#import "RootViewController.h"


@implementation DrillDownAppAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize data;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	NSString *Path = [[NSBundle mainBundle] bundlePath];
	NSString *DataPath = [Path stringByAppendingPathComponent:@"data.plist"];
	
	NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:DataPath];
	self.data = tempDict;
	[tempDict release];
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[data release];
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
