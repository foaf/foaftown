//
//  DrillDownAppAppDelegate.h
//  DrillDownApp
//
//  Created by iPhone SDK Articles on 3/8/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import <UIKit/UIKit.h>

@interface DrillDownAppAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
	NSDictionary *data;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) NSDictionary *data;

@end

