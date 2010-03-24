//
//  ButtonDevice.h
//  Gumbovi1
//
//  Created by Dan Brickley on 23/03/2010.
//  Copyright 2010 FOAF. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ButtonDevice : NSObject 
{
	NSString *name;
	NSString *uri;
	UIImage *icon;
	BOOL fromQRCode;
}
	@property (nonatomic, retain) IBOutlet NSString *name;
	@property (nonatomic, retain) IBOutlet NSString *uri;
	@property (nonatomic, retain) IBOutlet UIImage *icon;
	@property (nonatomic) IBOutlet BOOL fromQRCode;
	
-(ButtonDevice *) initWithURI: (NSString *) u;


@end
