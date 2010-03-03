//
//  WebViewController.m
//  Gumbovi1
//
//  Created by Dan Brickley on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"


//
//NSURL *urlURL = [NSURL URLWithString:@"http://services.notube.tv/notube/zapper/epgactionmobile2.php?username=lora"] ;
//theWebView.backgroundColor = [UIColor blackColor];
//[theWebView loadRequest:[NSURLRequest requestWithURL:urlURL]];

@implementation WebViewController

@synthesize webview;
@synthesize theActivityIndicatorView;
@synthesize urlAddress;

- (void)viewDidLoad {
	urlAddress = @"http://buttons.foaf.tv/";
	NSURL *url = [NSURL URLWithString:urlAddress];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[webview loadRequest:requestObj];
}


- (void)webViewDidStartLoad:(UIWebView *)wv {
	NSLog (@"webViewDidStartLoad");
	[theActivityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	NSLog (@"webViewDidFinishLoad");
	[theActivityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
	NSLog (@"webView:didFailLoadWithError");
	[theActivityIndicatorView stopAnimating];
	if (error != NULL) {
		UIAlertView *errorAlert = [[UIAlertView alloc]
										  initWithTitle: [error localizedDescription]
										  message: [error localizedFailureReason]
										  delegate:nil
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
	}
}

@end
