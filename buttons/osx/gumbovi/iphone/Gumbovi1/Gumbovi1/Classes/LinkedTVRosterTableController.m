//
//  LinkedTVRosterTableController.m
//  Gumbovi1
//
//  Created by Dan Brickley on 3/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LinkedTVRosterTableController.h"
#import "FirstViewController.h"
#import "Gumbovi1AppDelegate.h"
#import "ButtonCell.h"

// For now, lots of state is in FVC

@implementation LinkedTVRosterTableController

@synthesize roster_view;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	Gumbovi1AppDelegate * buttons = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	FirstViewController * fvc = (FirstViewController *) [buttons.tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
    NSMutableArray *roster = fvc.roster_list;
	VerboseLog(@"LinkedTVRosterTableController view loaded. roster is: %@",roster);
	
//	[fvc.roster_list addObject:jid];
//	DebugLog(@"gad.toJID is now: %@",self.toJid);

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DebugLog(@"LinkedTVRosterTableController viewWillAppear:");
	Gumbovi1AppDelegate *buttons = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];

    DebugLog(@"LinkedTVRosterTableController viewWillAppear: about to (not!) call buttonReport. If we have a list: %@", buttons.buttonDevices);

	//FIXME [gad.buttonDevices buttonReport];

//	DebugLog(@"LinkedTVRosterTableController viewWillAppear: after calling buttonReport");
	DebugLog(@"GUMBOVI ROSTER CHECK. Do we have our roster? %@", buttons.xmppRoster);
	DebugLog(@"GUMBOVI ROSTER CHECK. Do we have our roster storage? %@", buttons.xmppRosterStorage);
	
	NSArray *who = buttons.xmppRosterStorage.managedObjectModel.entities;
	for (NSObject *entity in who) {
		// entity is each instance of NSEntityDescription in aModel in turn
		DebugLog(@"ROSTER ENTITY: %@",entity);
	}
	
	FirstViewController * fvc = (FirstViewController *) [buttons.tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
    NSMutableArray *roster = fvc.roster_list;
	DebugLog(@"viewWillAppear: roster is %@",roster);
	DebugLog(@"viewWillAppear linked tv roster_view is: %@",roster_view);
    [roster_view reloadData];				// refresh roster when anyone will look
	[roster_view flashScrollIndicators];	//to show that it's scrollable
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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


#pragma mark Table view methods


//http://developer.apple.com/iphone/library/documentation/UIKit/Reference/UITableViewDatasource_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40006941-CH3-SW9
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    VerboseLog(@"numberOfSectionsInTableView called");
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    VerboseLog(@"numberOfRowsInSection called");
	Gumbovi1AppDelegate * gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	FirstViewController * fvc = (FirstViewController *) [gad.tabBarController.viewControllers objectAtIndex:0];//ugh
    NSMutableArray *roster = fvc.roster_list;
    //[roster retain];
	VerboseLog(@"Data TABLE: numberOfRowsInSection called");
	//int i = [roster count];
	//DebugLog(@"DATA TABLE CHECKING NUMROWS: %@", i);
//	return i;
    return [roster count];
} 


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VerboseLog(@"FRESH CELL: %@",indexPath);
    static NSString *CellIdentifier = @"myButtonCell";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
		DebugLog(@"ButtonCell created");
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"ButtonCell" owner:nil options:nil];
		for (id currentObject in nibObjects) 
		{
			if ( [currentObject isKindOfClass:[ButtonCell class]]) 
			{
				cell = (ButtonCell *) currentObject;
			}
		
		}
    }
    
	Gumbovi1AppDelegate * gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	FirstViewController * fvc = (FirstViewController *) [gad.tabBarController.viewControllers objectAtIndex:0];//ugh
	NSMutableArray *roster = fvc.roster_list;
	///[roster retain];// hmm help, memory stuff. todo!	
	//	NSString *jid = (NSString *)[roster objectAtIndex:indexPath.row];
    NSObject *jid = [roster objectAtIndex:indexPath.row];
    // Set up the cell...
	[[cell deviceName] setText:[NSString stringWithFormat:@"%@",jid]];
	[[cell deviceIcon] setImage:[UIImage imageNamed:@"mythtv.png"]];
	[[cell deviceType] setText:[NSString stringWithFormat:@"%@", @"Unknown type, scanning..."  ]];
								
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	Gumbovi1AppDelegate * gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	FirstViewController * fvc = (FirstViewController *) [gad.tabBarController.viewControllers objectAtIndex:0];//ugh
    NSMutableArray *roster = fvc.roster_list;
	DebugLog(@"LinkedTV: toJID is now: %@",[roster objectAtIndex:indexPath.row]);
	[gad setTargetJidWithString:[roster objectAtIndex:indexPath.row]];

}



- (void)dealloc {
    [super dealloc];
}


@end





/*
 // Navigation logic may go here. Create and push another view controller.
 // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
 // [self.navigationController pushViewController:anotherViewController];
 // [anotherViewController release];// http://icodeblog.com/2008/08/08/iphone-programming-tutorial-populating-uitableview-with-an-nsarray/ */
