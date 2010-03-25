//
//  ButtonDeviceList.m
//  Gumbovi1
//
//  Created by Dan Brickley on 25/03/2010.
//  Copyright 2010 FOAF. All rights reserved.
//

#import "ButtonDeviceList.h"
#import "ButtonDevice.h"

@implementation ButtonDeviceList

- (void)removeAllNonLocalDevices {
	NSLog(@"ButtonDeviceList removeAllNonLocalDevices - dumping everything before rebuilding");
	NSEnumerator *enumerator = [self.allObjects objectEnumerator];
    id obj;	
    while ( obj = [enumerator nextObject] ) {
        NSLog(@"DELETING: %@\n", obj  );
		if ( ((ButtonDevice *) obj).fromQRCode == NO ) {
			NSLog(@"DELETING: %@\n", obj  );
			[self removeObject:obj];
		} else {
			NSLog(@"KEEPING (QR-based): %@\n", obj  );

		}
	}
}
	
//http://developer.apple.com/mac/library/documentation/cocoa/reference/Foundation/Classes/NSCountedSet_Class/Reference/Reference.html#//apple_ref/occ/instm/NSCountedSet/objectEnumerator
- (void)buttonReport {
	NSLog(@"ButtonDeviceList buttonReport:");
	NSLog(@"______________________________\n\n");
    NSLog(@"ButtonDeviceList is now: ", self);
	
	NSEnumerator *enumerator = [self.allObjects objectEnumerator];
    id obj;	
    while ( obj = [enumerator nextObject] ) {
        NSLog(@"BUTTONDEVICE: %@\n", obj  );
		if ( ((ButtonDevice *) obj).fromQRCode == NO ) {
			NSLog(@"NON-QR: %@\n", obj  );
		//	[self removeObject:obj];
/* *** Terminating app due to uncaught exception 'NSGenericException', reason: '*** Collection <NSCFDictionary: 0x27bf30> was mutated while being enumerated.'
 */
		
		} else {
			NSLog(@"QR: %@\n", obj  );			
		}
		NSLog(@"\n");
	}
	NSLog(@"_____________________________.\n\n");	
}

- (void)dealloc {
	
	//[anything_we_use release];
	
    [super dealloc];
}


@end
