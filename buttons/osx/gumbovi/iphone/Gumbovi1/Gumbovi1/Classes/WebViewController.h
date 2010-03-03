//
//  WebViewController.h
//  Gumbovi1
//
//  Created by Dan Brickley on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebViewController : UIViewController {
	
	IBOutlet UIActivityIndicatorView *theActivityIndicatorView;
	IBOutlet UIWebView *webview;
	NSString *urlAddress;
}

@property (nonatomic, retain) UIWebView *webview;
@property(nonatomic,retain)	IBOutlet UIActivityIndicatorView *theActivityIndicatorView;
@property (nonatomic, retain) NSString *urlAddress;

@end