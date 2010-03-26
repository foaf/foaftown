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
	DebugLog(@"ButtonDeviceList removeAllNonLocalDevices - dumping everything before rebuilding");
	NSEnumerator *enumerator = [self.allObjects objectEnumerator];
    id obj;	
    while ( obj = [enumerator nextObject] ) {
#ifdef BUTTONS_DEBUG
        DebugLog(@"EXAMINING: %@\n", obj  );
#endif
		if ( ((ButtonDevice *) obj).fromQRCode == NO ) {
#ifdef BUTTONS_DEBUG
			DebugLog(@"DELETING: %@\n", obj  );
#endif
			[self removeObject:obj];
		} else {
#ifdef BUTTONS_DEBUG 
			DebugLog(@"KEEPING (QR-based): %@\n", obj  );
#endif
		}
	}
}
	
//http://developer.apple.com/mac/library/documentation/cocoa/reference/Foundation/Classes/NSCountedSet_Class/Reference/Reference.html#//apple_ref/occ/instm/NSCountedSet/objectEnumerator
- (void)buttonReport {
	DebugLog(@"__________________________________________________________________________________\n\n");
	DebugLog(@"					ButtonDeviceList buttonReport :");
	DebugLog(@"__________________________________________________________________________________\n\n");
    DebugLog(@"ButtonDeviceList is now: ", self);
	
	NSEnumerator *enumerator = [self.allObjects objectEnumerator];
    id obj;	
    while ( obj = [enumerator nextObject] ) {
        DebugLog(@"BUTTONDEVICE: %@\n", obj  );
		if ( ((ButtonDevice *) obj).fromQRCode == NO ) {
			DebugLog(@"NON-QR: %@\n", obj  );
		} else {
			DebugLog(@"QR: %@\n", obj  );			
		}
		DebugLog(@"\n");
	}
	DebugLog(@"__________________________________________________________________________________\n\n");
}

- (void)dealloc {
	
	//[anything_we_use release];
	
    [super dealloc];
}


@end
