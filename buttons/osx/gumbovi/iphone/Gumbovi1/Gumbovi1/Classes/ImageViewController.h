//
//  ImageViewController.h
//  DrillDownApp
//
//  Created by Jai Kirdatt on 3/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageViewController : UIViewController {

	IBOutlet UIImageView *imgView;
	NSString *ImageName;
}

@property (nonatomic, retain) NSString *ImageName;

@end
