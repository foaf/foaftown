//
//  ButtonDevice.m
//  Gumbovi1
//
//  Created by Dan Brickley on 23/03/2010.
//  Copyright 2010 FOAF. All rights reserved.
//

#import "ButtonDevice.h"

// todo, keep track of whether URI is valid xmpp URI
// other things we know or don't know about it - eg. owner

@implementation ButtonDevice

@synthesize name;
@synthesize uri;
@synthesize icon;
@synthesize fromQRCode; // exact semantics to be clarified


-(ButtonDevice *) initWithURI: (NSString *) u {
	NSLog(@"NEW BUTTONDEVICE");
    self = [super init];	
    if ( self ) {
        [self setUri: u];
		NSLog(@"NEW BUTTONDEVICE setting URI, %@", u);
    }
	
    return self;
}

@end
