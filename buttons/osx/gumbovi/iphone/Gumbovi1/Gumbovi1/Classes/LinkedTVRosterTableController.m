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
#import "XMPP.h"
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

	Gumbovi1AppDelegate * gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	FirstViewController * fvc = (FirstViewController *) [gad.tabBarController.viewControllers objectAtIndex:0];//ugh
    NSMutableArray *roster = fvc.roster_list;
	DebugLog(@"LinkedTVRosterTableController view loaded. roster is: %@",roster);
//	[fvc.roster_list addObject:jid];
//	DebugLog(@"gad.toJID is now: %@",self.toJid);

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DebugLog(@"LinkedTVRosterTableController viewWillAppear:");
	Gumbovi1AppDelegate *gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];

    DebugLog(@"LinkedTVRosterTableController viewWillAppear: about to call buttonReport. If we have a list: %@", gad.buttonDevices);

	[gad.buttonDevices buttonReport];

	DebugLog(@"LinkedTVRosterTableController viewWillAppear: after calling buttonReport");

	FirstViewController * fvc = (FirstViewController *) [gad.tabBarController.viewControllers objectAtIndex:0];//ugh
    NSMutableArray *roster = fvc.roster_list;
	DebugLog(@"viewWillAppear: roster is %@",roster);
	DebugLog(@"viewWillAppear linked tv roster_view is: %@",roster_view);
    [roster_view reloadData]; // refresh roster when anyone will look
	[roster_view flashScrollIndicators]; //to show that it's scrollable
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
    DebugLog(@"numberOfSectionsInTableView called");
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DebugLog(@"numberOfRowsInSection called");
	Gumbovi1AppDelegate * gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	FirstViewController * fvc = (FirstViewController *) [gad.tabBarController.viewControllers objectAtIndex:0];//ugh
    NSMutableArray *roster = fvc.roster_list;
    //[roster retain];
	DebugLog(@"Data TABLE: numberOfRowsInSection called");
	//int i = [roster count];
	//DebugLog(@"DATA TABLE CHECKING NUMROWS: %@", i);
//	return i;
    return [roster count];
} 


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DebugLog(@"FRESH CELL: %@",indexPath);
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
	DebugLog(@"LinkedTV: toJID is now xmpp: %@",[roster objectAtIndex:indexPath.row]);
	gad.toJid = [XMPPJID jidWithString:[roster objectAtIndex:indexPath.row]];
	// Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}// http://icodeblog.com/2008/08/08/iphone-programming-tutorial-populating-uitableview-with-an-nsarray/


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/









- (void)dealloc {
    [super dealloc];
}


@end

