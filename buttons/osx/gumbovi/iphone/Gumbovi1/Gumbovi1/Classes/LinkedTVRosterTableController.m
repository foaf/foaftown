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
	FirstViewController * fvc = (FirstViewController *) [buttons.tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
	fvc.roster_list.release; // FIXME
	fvc.roster_list = [[NSMutableArray alloc] init]; // must be a better way to empty things FIXME 
	//NSMutableArray *roster = fvc.roster_list;
    
	DebugLog(@"EMPTY ROSTER! nothing should be here: %@", fvc.roster_list);
	
	// Core Data XMPPResourceCoreDataStorage
	//	VerboseLog(@"GUMBOVI ROSTER CHECK. Do we have our roster? %@ and storage %@", buttons.xmppRoster, buttons.xmppRosterStora);
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPResourceCoreDataStorage" inManagedObjectContext:buttons.xmppRosterStorage.managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];				// everything if no predicate, so commented out: [fetchRequest setPredicate:predicate];
	[fetchRequest setIncludesPendingChanges:YES];
	[fetchRequest setFetchLimit:100];
	// NSError *err = nil;
	NSArray *results = [buttons.xmppRosterStorage.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    // DebugLog(@"array is: %@" , results);	
	for (NSEntityDescription *entity in results) {
		DebugLog(@"ROSTER ENTITY: %@",entity);
		//NSString *xp = [entity presenceStr];
		//DebugLog("ROSTER PRESENCE STRING: presence markup is %@",[entity presenceStr]);
		DebugLog(@"JID: %@", [entity jidStr]);
		NSString *aJid = [entity jidStr];
		XMPPPresence *xp = [entity presence];
		NSString *fullJid = [[xp attributeForName:@"from"] stringValue];
		NSLog(@"EXTRACTED JID: %@",fullJid);		
		DebugLog(@"We got a JID in our roster: %@",aJid);	
		DebugLog(@"Roster was: %@",fvc.roster_list);
		[fvc.roster_list addObject:fullJid];
		NSSet *tmp = [NSSet setWithArray:fvc.roster_list]; 
		fvc.roster_list = [[NSMutableArray alloc] initWithArray:[tmp allObjects]];
		DebugLog(@"Roster now: %@",fvc.roster_list);
		[roster_view reloadData]; /// try to get ui to refresh while we watch fixme
	} 
	
	// Core Data XMPPUserCoreDataStorage
	NSEntityDescription *entity1 = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorage" inManagedObjectContext:buttons.xmppRosterStorage.managedObjectContext];
	NSFetchRequest *fetchRequest1 = [[NSFetchRequest alloc] init];
	[fetchRequest1 setEntity:entity1 ];
	[fetchRequest1 setIncludesPendingChanges:YES];
	[fetchRequest1 setFetchLimit:100];
	NSArray *results1 = [buttons.xmppRosterStorage.managedObjectContext executeFetchRequest:fetchRequest1 error:nil];
	for (NSEntityDescription *entity1 in results1) {
		// DebugLog(@"jidstr: %@  ", [entity1 jidStr]);
	
	} 
	
	// Core Data XMPPCapabilitiesCoreDataStorage

	NSEntityDescription *cdb = [NSEntityDescription entityForName:@"XMPPCapsCoreDataStorageObject" inManagedObjectContext:buttons.xmppCapabilitiesStorage.managedObjectContext];
	// DebugLog(@"CAPS DB: %@", cdb);
	NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];
	[fetchRequest2 setEntity:cdb];
	[fetchRequest2 setIncludesPendingChanges:YES];
	[fetchRequest2 setFetchLimit:100];
	NSArray *caps = [buttons.xmppCapabilitiesStorage.managedObjectContext executeFetchRequest:fetchRequest2 error:nil];
    //DebugLog(@"Got array of caps: %@", caps);	

	for (NSEntityDescription *c in caps) {
		DebugLog(@"CAPS XMPPCapsCoreDataStorageObject: capabilities: \n\t%@\n\n", [c capabilities]);
		//DebugLog(@"CAPS XMPPCapsCoreDataStorageObject: capabilitiesStr: %@ ", [c capabilitiesStr]);
		NSSet *capSet = [c resources];
		for (XMPPCapsResourceCoreDataStorageObject *x in capSet) 
		{
			DebugLog(@"CAPS XMPPCapsResourceCoreDataStorageObject RESOURCE: ext: %@  failed: %@ hashAlgorithm: %@ hashStr: %@ jidStr: %@ node: %@ ver: x", 
							[x ext], [x failed], [x hashAlgorithm], [x hashStr],[x jidStr], [x node] );
		}
	}
	
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
	FirstViewController * fvc = (FirstViewController *) [gad.tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
	NSMutableArray *roster = fvc.roster_list;
	DebugLog(@"CELL FOR JID LIST %@", fvc.roster_list);
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
