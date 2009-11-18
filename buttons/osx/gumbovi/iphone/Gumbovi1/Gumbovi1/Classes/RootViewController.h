//
//  RootViewController.h
//  DrillDownApp
//
//  Created by iPhone SDK Articles on 3/8/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController {
	
	NSArray *tableDataSource;
	NSString *CurrentTitle;
	NSInteger CurrentLevel;
	IBOutlet UITabBarController *tbController;
}

@property (nonatomic, retain) NSArray *tableDataSource;
@property (nonatomic, retain) NSString *CurrentTitle;
@property (nonatomic, readwrite) NSInteger CurrentLevel;

@end
