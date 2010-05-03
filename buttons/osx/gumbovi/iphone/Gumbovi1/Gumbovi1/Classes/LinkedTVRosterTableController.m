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
#import "XMPPCapabilities.h"
#import "XMPPCapsResourceCoreDataStorageObject.h"

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




//DebugLog(@"LinkedTVRosterTableController viewWillAppear: %@", buttons.buttonDevices);
//FIXME [buttons.buttonDevices buttonReport];
/*
 entity: XMPPResourceCoreDataStorage; id: 0x3c80ec0 <x-coredata://2DA156B3-F83C-4FCD-9B3E-F52197807ADB/XMPPResourceCoreDataStorage/p5> ; data: {
 jidStr = "libby.miller@gmail.com";
 presence = "(...not nil..)";
 presenceDate = nil;
 presenceStr = "<presence to=\"alice.notube@gmail.com/hardcodedE4EF";
 primaryResourceInverse = nil;
 priorityNum = 0;
 show = nil;
 showNum = 3;
 status = "Now playing Bertie and Elizabeth on ITV3";
 type = available;
 user = 0x3c78dc0 <x-coredata://2DA156B3-F83C-4FCD-9B3E-F52197807ADB/XMPPUserCoreDataStorage/p5>;
 */
/* <presence from="bob.notube@gmail.com/gmail.B14765EE" to="alice.notube@gmail.com/hardcodedE1D3D2F3"><show>away</show><priority>0</priority><caps:c xmlns:caps="http://jabber.org/protocol/caps" node="http://mail.google.com/xmpp/client/caps" ver="1.1" ext="pmuc-v1 sms-v1 vavinvite-v1"></caps:c><status>watching tv and loving it</status><x xmlns="vcard-temp:x:update"><photo></photo></x></presence> */
/* "A predicate (an instance of NSPredicate) that specifies which properties to select by and the constraints on selection, for example “last name begins with a ‘J’”. If you don’t specify a predicate, then all instances of the specified entity are selected (subject to other constraints, see executeFetchRequest:error: for full details)." http://developer.apple.com/mac/library/documentation/Cocoa/Reference/CoreDataFramework/Classes/NSFetchRequest_Class/NSFetchRequest.html  */
//NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidStr == %@", fullJIDStr];



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DebugLog(@"LinkedTVRosterTableController viewWillAppear:");

	Gumbovi1AppDelegate *buttons = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	[buttons scanRosterForDevices]; 	
	[roster_view reloadData];				// refresh roster when anyone will look
	[roster_view flashScrollIndicators];	//to show that it's scrollable
}


- (void)reloadData {
	[roster_view reloadData];
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
    
	Gumbovi1AppDelegate * buttons = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	FirstViewController * fvc = (FirstViewController *) [buttons.tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
	NSMutableArray *roster = fvc.roster_list;
	DebugLog(@"CELL FOR JID LIST %@", fvc.roster_list);
    XMPPJID *jid = [XMPPJID jidWithString:[roster objectAtIndex:indexPath.row] ];
	
	
	// http://xmpp.org/registrar/disco-categories.html
	//
	XMPPCapabilitiesCoreDataStorage *caps = (XMPPCapabilitiesCoreDataStorage *) buttons.xmppCapabilitiesStorage;
	DebugLog(@"UI REBUILD - consulting caps: %@", caps);
	XMPPJID *jj = (XMPPJID *)[XMPPJID jidWithString:[jid description]];
	BOOL isDesktop = FALSE;
	BOOL isMythTV = FALSE;
	BOOL isVLC = FALSE;
	
	if ([caps areCapabilitiesKnownForJID:jj ] ) {
		XMPPIQ *capXML = [caps capabilitiesForJID:jid];
		NSString *xs = [capXML description];
		DebugLog(@"BUTTONS UI-REGEN XML: %@", capXML);
		
		if([xs rangeOfString:@"type=\"pc\""].location == NSNotFound){
			DebugLog(@"BUTTONS UI-REGEN CAPS: Not a pc client");	
		} else {
			DebugLog(@"BUTTONS UI-REGEN CAPS: Desktop pc Client!");
			isDesktop=TRUE;
		}
		
		// name="MythTV Buttons"
		if([xs rangeOfString:@"name=\"MythTV Buttons\""].location != NSNotFound) { isMythTV=TRUE; }
			
	}
	
    // Set up the cell...
	[[cell deviceName] setText:[NSString stringWithFormat:@"%@",jid]];
	
	// use a case switch?
	
	if (isDesktop) {
		[[cell deviceIcon] setImage:[UIImage imageNamed:@"foaf-explorer.png"]];
		[[cell deviceType] setText:[NSString stringWithFormat:@"%@", @"Buddy"  ]];
	}
	
	if (isMythTV ) { 
//		[[cell deviceIcon] setImage:[UIImage imageNamed:@"mythtv-tv.png"]]; 
		[[cell deviceIcon] setImage:[UIImage imageNamed:@"foaf-explorer.png"]]; 

		[[cell deviceType] setText:[NSString stringWithFormat:@"%@", @"NoTube Network"  ]];

	} 
	else {
		[[cell deviceIcon] setImage:[UIImage imageNamed:@"blank-tv.png"]];		
	}
	
	
	
								
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	Gumbovi1AppDelegate * buttons = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	FirstViewController * fvc = (FirstViewController *) [buttons.tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
    NSMutableArray *roster = fvc.roster_list;
	DebugLog(@"LinkedTV: toJID is now: %@",[roster objectAtIndex:indexPath.row]);
	[buttons setTargetJidWithString:[roster objectAtIndex:indexPath.row]];

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
