//
//  RootViewController.m
//  DrillDownApp
//
//  Created by iPhone SDK Articles on 3/8/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import "FirstViewController.h"
#import "Gumbovi1AppDelegate.h"
#import "RootViewController.h"
//#import "DrillDownAppAppDelegate.h"
#import "DetailViewController.h"


@implementation RootViewController

@synthesize tableDataSource, CurrentTitle, CurrentLevel;


- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"ROOTVIEWCONTROLLER LOADED! XXXXXXXXXXX ");
    if(CurrentLevel == 0) {
		
		//Initialize our table data source
		NSArray *tempArray = [[NSArray alloc] init];
		self.tableDataSource = tempArray;
		[tempArray release];
		
//		DrillDownAppAppDelegate *AppDelegate = (DrillDownAppAppDelegate *)[[UIApplication sharedApplication] delegate];

		Gumbovi1AppDelegate *AppDelegate = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
		NSLog(@"viewDidLoad - gad: %@", AppDelegate);

		
		self.tableDataSource = [AppDelegate.data objectForKey:@"Rows"];
		NSLog(@"viewDidLoad - setting up data source: %@", self.tableDataSource);
		self.navigationItem.title = @"Root";
	}
	else 
		self.navigationItem.title = CurrentTitle;	
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


#pragma mark Table view methods


 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}





// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableDataSource count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSDictionary *dictionary = [self.tableDataSource objectAtIndex:indexPath.row];
	cell.text = [dictionary objectForKey:@"Title"];

    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSLog(@"ROOTVIEWCONTROLLER! didSelectRowAtIndexPath");

	
	//Get the dictionary of the selected data source.
	NSDictionary *dictionary = [self.tableDataSource objectAtIndex:indexPath.row];
	NSLog(@"ROOTVIEWCONTROLLER! dict:", dictionary);

	//Get the children of the present item.
	NSArray *Children = [dictionary objectForKey:@"Children"];
	
	if([Children count] == 0) {
		NSLog(@"ROOTVIEWCONTROLLER! 0 children");

		DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
		
		//		[self.navigationController pushViewController:dvController animated:YES];

		//http://www.cimgf.com/2009/06/25/uitabbarcontroller-with-uinavigationcontroller-using-interface-builder/
		// [[self navigationController] pushViewController:dvController animated:YES];
		//
		[[self navigationController] pushViewController:dvController animated:YES];

		//tabBarController
		[dvController release];
	}
	else {
		NSLog(@"ROOTVIEWCONTROLLER! 1+ children");
		/// TODO: did we fail to get dict?
		
		//Prepare to tableview.
		RootViewController *rvController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle]];
		UITabBarController *tb = self.tabBarController;
		NSLog(@"TAB BAR: %@",tb.viewControllers);
		NSLog(@"New RootViewController: %@",rvController);
		RootViewController *topListsController = [tb.viewControllers objectAtIndex:2];
		NSLog(@"top controller!: %@",topListsController);
		rvController.CurrentLevel += 1;										//Increment the Current View
		rvController.CurrentTitle = [dictionary objectForKey:@"Title"];		//Set the title;
		//Push the new table view on the stack:
//		[self.navigationController pushViewController:rvController animated:YES];
//		[topListsController pushViewController:rvController animated:YES];
		
		rvController.tableDataSource = Children;
		
		[rvController release];
	}
}



- (void)dealloc {
	[CurrentTitle release];
	[tableDataSource release];
    [super dealloc];
}

@end

