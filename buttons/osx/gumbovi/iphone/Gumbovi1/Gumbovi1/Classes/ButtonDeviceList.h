//
//  ButtonDeviceList.h
//  Gumbovi1
//
//  Created by Dan Brickley on 25/03/2010.
//  Copyright 2010 FOAF. All rights reserved.
//

#import <Foundation/Foundation.h>

// OK idea is that we are a list (set actually) of ButtonDevice instances
// those that are on our server-based XMPP rosters, plus others discovered
// locally via QRCode and Bonjour techniques.
// 
// This list is the model side of things, displaced by the LinkedTVRosterTableController
//

@interface ButtonDeviceList : NSSet {

}

// -serverRosterDevices


// -localQRCodeDevices


// -localMDNSDevices

@end
