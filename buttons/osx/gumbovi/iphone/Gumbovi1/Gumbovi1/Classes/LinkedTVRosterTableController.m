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
#import "XMPPUserMemoryStorage.h"
#import "XMPPUser.h"
#import "XMPPResource.h"

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


// TODO: move this to Utils if useful
- (NSString *)getDataBetweenFromString:(NSString *)data leftString:(NSString *)leftData rightString:(NSString *)rightData leftOffset:(NSInteger)leftPos; 
{         
    NSInteger left, right;         
    NSString *foundData;                 
	NSScanner *scanner = [NSScanner scannerWithString:data];

    [scanner scanUpToString:leftData intoString: nil];         
    left = [scanner scanLocation];         
    [scanner setScanLocation:left + leftPos];         
    [scanner scanUpToString:rightData intoString: nil];         
    right = [scanner scanLocation] + 1;         
    left += leftPos;         
    foundData = [data substringWithRange: NSMakeRange(left, (right - left) - 1)]; 
	[scanner release];
	return foundData; 
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
    
	// http://xmpp.org/registrar/disco-categories.html

	Gumbovi1AppDelegate * buttons = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	FirstViewController * fvc = (FirstViewController *) [buttons.tabBarController.viewControllers objectAtIndex:TAB_BUTTONS];
	NSMutableArray *roster = fvc.roster_list;
	DebugLog(@"CELL FOR JID LIST %@", fvc.roster_list);
    XMPPJID *jid = [XMPPJID jidWithString:[roster objectAtIndex:indexPath.row] ];
	XMPPCapabilitiesCoreDataStorage *caps = (XMPPCapabilitiesCoreDataStorage *) buttons.xmppCapabilitiesStorage;
	VerboseLog(@"UI REBUILD - consulting caps: %@", caps);
	XMPPJID *jj = (XMPPJID *)[XMPPJID jidWithString:[jid description]];

	// TODO: This will go away in future; when we replace roster_list with ButtonDeviceList and the entries are OO-modelled. 

	BOOL isPC = FALSE;
	BOOL isMythTV = FALSE;
	BOOL isVLC = FALSE;
	BOOL isBOXEE = FALSE;
	BOOL isXBMC = FALSE;
	BOOL isWWW = FALSE;
	
	if ([caps areCapabilitiesKnownForJID:jj ] ) {
		XMPPIQ *capXML = [caps capabilitiesForJID:jid];
		NSString *xs = [capXML description];
		VerboseLog(@"BUTTONS UI-REGEN XML: %@", capXML);
		
		if([xs rangeOfString:@"type=\"pc\""].location == NSNotFound){
			DebugLog(@"BUTTONS UI-REGEN CAPS: Not a pc client %@", xs);	
		} else {
			DebugLog(@"BUTTONS UI-REGEN CAPS: Desktop pc Client! %@", xs);
			isPC = TRUE;
		};
		
		// name="MythTV Buttons" /// this is crap, and " and ' could get rewritten
	  
		if([xs rangeOfString:@"name=\"MythTV Buttons\""].location != NSNotFound) { isMythTV = TRUE; }
		if([xs rangeOfString:@"name=\"VLC\""].location != NSNotFound) { isVLC = TRUE; } // TODO: send this from VLC
		if([xs rangeOfString:@"name=\"BOXEE\""].location != NSNotFound) { isBOXEE = TRUE; }	// TODO: send this from Boxee
		if([xs rangeOfString:@"name=\"XBMC\""].location != NSNotFound) { isXBMC = TRUE; }	// TODO: send this from XBMC
		if([xs rangeOfString:@"WWW"].location != NSNotFound) { isWWW = TRUE; }	// TODO: send this from Strophe.js

		DebugLog(@"XML to extract device summary is: %@", xs); // name="MythTV Buttons"
		// see http://stackoverflow.com/questions/594797/how-to-use-nsscanner
		
		//NSString *name = [self getDataBetweenFromString:xs leftString:@"name=" rightString:@"\"" leftOffset:5];
		//DebugLog(@"BNAME: %@", name);
		
		
		// we want in capXML to match iq/query/identify@name
		// http://developer.apple.com/mac/library/documentation/Cocoa/Reference/Foundation/Classes/NSXMLElement_Class/Reference/Reference.html

		// woes: http://groups.google.com/group/xmppframework/browse_thread/thread/1ae1f1ca58abbd90
		
		/* 
	       <iq to="alice.notube@gmail.com/hardcoded0C271803" type="result" id="CB7DC50D-CB21-4C57-B1F3-34EA0097DD7E" from="bob.notube@gmail.com/BasicbotA263033F"><query xmlns="http://jabber.org/protocol/disco#info"><identity name="MythTV Buttons" category="client" type="bot"></identity><feature var="dnssrv"></feature><feature var="stringprep"></feature><feature var="urn:ietf:params:xml:ns:xmpp-sasl#c2s"></feature><feature var="jabber:iq:version"></feature></query></iq>
	   */	
		
		//NSArray *nodes = [capXML nodesForXPath:@"./iq/query/identify/@name" error:nil];
		//NSArray *event = [message nodesForXPath:@"//event/items/item/data" error:&error]; 

		//NSArray *name = [capXML nodesForXPath:@"//identify/@name" error:nil];
		//DebugLog(@"IDENTIFY NAME array: %@", name);
		
		//if ([name count] > 0) {
		//	NSString *value = [[name objectAtIndex:0] stringValue];
		//	DebugLog(@"IDENTIFY NAME: %@", value);
		//} else { DebugLog(@"Array is 0"); }
			 


	
	}
	
	// Nooo, can't print BOOLs. DebugLog(@"SUMMARY: isPC:%@ isMythTV:%@ isVLC:%@ isBOXEE:%@ isWWW:%@", isPC, isMythTV, isVLC, isBOXEE, isWWW);
	
	
    // Set up the cell...
	[[cell deviceName] setText:[NSString stringWithFormat:@"%@",jid]];
	
	
	
	
	// Set up image:
	[[cell deviceIcon] setImage:[UIImage imageNamed:@"blank-tv.png"]]; 
	
	if (isPC) {
		[[cell deviceIcon] setImage:[UIImage imageNamed:@"foaf-explorer.png"]];
		[[cell deviceType] setText:[NSString stringWithFormat:@"%@", @"Buddy"  ]];
	};
	
	if (isMythTV ) { 
		[[cell deviceIcon] setImage:[UIImage imageNamed:@"mythtv-tv.png"]]; 
		[[cell deviceName] setText:[NSString stringWithFormat:@"MythTV"]];
		[[cell deviceType] setText:[NSString stringWithFormat:@"%@", @"NoTube Network"  ]];

	};

	
	if (isBOXEE ) { 
		[[cell deviceIcon] setImage:[UIImage imageNamed:@"boxee-tv.png"]]; 
		[[cell deviceName] setText:[NSString stringWithFormat:@"Boxee"]];
		[[cell deviceType] setText:[NSString stringWithFormat:@"%@", @"NoTube Network"  ]];
	};
	
	if (isWWW ) { 
		[[cell deviceIcon] setImage:[UIImage imageNamed:@"www-tv.png"]]; 
		[[cell deviceName] setText:[NSString stringWithFormat:@"Web"]];
		[[cell deviceType] setText:[NSString stringWithFormat:@"%@", @"NoTube Network"  ]];
	};
	if (isXBMC ) { 
		[[cell deviceIcon] setImage:[UIImage imageNamed:@"xbmc-tv.png"]]; 
		[[cell deviceName] setText:[NSString stringWithFormat:@"XBMC"]];
		[[cell deviceType] setText:[NSString stringWithFormat:@"%@", @"NoTube Network"  ]];
	};
	if (isVLC ) { 
		[[cell deviceIcon] setImage:[UIImage imageNamed:@"vlc-tv.png"]]; 
		[[cell deviceName] setText:[NSString stringWithFormat:@"VLC"]];
		[[cell deviceType] setText:[NSString stringWithFormat:@"%@", @"NoTube Network"  ]];
	};
	
	
	// Scan devices and stuff their last status into the UI 
	// This is JUST WRONG. we should pick up via resourceForJID instead of iterating. TODO: find out why/where that failed. lazy slow for now.
	
	NSArray *devs = [buttons.xmppRosterStorage sortedUsersByAvailabilityName];
	
	for (XMPPUserMemoryStorage *u in devs) {
		if ([u isOnline]) { 
			NSArray *a = [u sortedResources];
			for (NSObject *ro in a) {
				XMPPJID *r = (XMPPJID *) [ro jid];
				DebugLog(@"UI STATUS FOR JID: %@", r);
				NSString *fullJid = [r description];
				NSString *myStatus = [NSString stringWithFormat:@"%@", [[ro presence] status]    ];
				DebugLog(@"UI STATUS: %@", myStatus );

				
				if ( [r isEqual:jid] ) { 
							//					if(myStatus != @"(null)" ) {
				  if ([myStatus rangeOfString:@"null"].location != NSNotFound) {

					[[cell deviceType] setText:@""];
				  }  else {
				//	[[cell deviceType] setText:@"(NoTube Network device)"]; // yes this is spaghetti to get here - TODO: de-pasta
					[[cell deviceType] setText:myStatus];

				}				
				NSLog(@"UI STATUS: Matched %@ jid", r);
				} else { 
					DebugLog(@"Jid %@ != %@", r, jid);
				}
			}
		}
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
