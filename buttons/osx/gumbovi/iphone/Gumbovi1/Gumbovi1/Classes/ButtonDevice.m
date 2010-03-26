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

-(NSString *) description {
    NSString* n = name;	
    NSString* u = name;	
	NSString* qr;
	if(fromQRCode){

		VerboseLog(@"VERBOSE: buttondevice is a qrcode");

		qr = @"Local QR Device.";
	} else {
		VerboseLog(@"VERBOSE: buttondevice is not qrcode");
		qr = @"Server-linked XMPP Device.";
	}
	return ([NSString stringWithFormat:@"ButtonDevice name: %@ uri: %@ fromQRCode: %@", n, u, qr ]);
}

-(ButtonDevice *) initWithURI: (NSString *) u {

VerboseLog(@"NEW BUTTONDEVICE");
	
    self = [super init];	
	//[[self retain] autorelease]; // danbri testing, object crashes us when we try set properties
    if ( self ) {
        [self setUri: u];
		VerboseLog(@"NEW BUTTONDEVICE setting URI, %@", u);
    }
	VerboseLog(@"NEW BUTTONDEVICE Constructor returning...");
    return self;
}

- (void)dealloc {
	
//    [anything_i_alloc_here release];
		
    [super dealloc];
}



@end
