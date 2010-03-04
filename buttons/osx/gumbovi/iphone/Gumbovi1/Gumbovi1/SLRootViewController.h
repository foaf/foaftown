#import <UIKit/UIKit.h>


@interface SLRootViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	NSMutableIndexSet *deletedSections;
    NSMutableIndexSet *insertedSections;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
