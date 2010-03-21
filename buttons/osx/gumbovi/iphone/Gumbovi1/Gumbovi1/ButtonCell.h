//
//  ButtonCell.h
//  Gumbovi1
//
//  Created by Dan Brickley on 20/03/2010.
//  Copyright 2010 FOAF. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ButtonCell : UITableViewCell {
	IBOutlet UIView *backgroundView;
	IBOutlet UILabel *deviceName;
	IBOutlet UILabel *deviceType;
	IBOutlet UIImageView *deviceIcon;

}

@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) IBOutlet UILabel *deviceName;
@property (nonatomic, retain) IBOutlet UILabel *deviceType;
@property (nonatomic, retain) IBOutlet UIImageView *deviceIcon;

@end
