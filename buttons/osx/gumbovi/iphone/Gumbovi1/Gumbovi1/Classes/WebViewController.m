//
//  WebViewController.m
//  Gumbovi1
//
//  Created by Dan Brickley on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"
#import "FirstViewController.h"
#import "Gumbovi1AppDelegate.h"
#import "XMPP.h"

//
//NSURL *urlURL = [NSURL URLWithString:@"http://services.notube.tv/notube/zapper/epgactionmobile2.php?username=lora"] ;
//theWebView.backgroundColor = [UIColor blackColor];
//[theWebView loadRequest:[NSURLRequest requestWithURL:urlURL]];

@implementation WebViewController

@synthesize webview;
@synthesize theActivityIndicatorView;
@synthesize urlAddress;

- (void)viewDidLoad {
	if (webview == NULL) {
		NSLog(@"viewDidLoad called with NULL webview, returning immediately.");	
		return;
	}
 	NSURL *baseURL = [NSURL URLWithString:@"http://buttons.notube.tv/"];		// for images etc?
	Gumbovi1AppDelegate *gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSLog(@"load Webview is %@:",webview);
	NSLog(@"DID LOAD: viewDidload, gad is: %@",gad);
//	NSLog(@"DID LOAD: gad.htmlInfo to webview, %@", gad.htmlInfo);
//	NSString *s = @"<html><head><title>Loading...</title><body>Move along, nothing to see...</body></html>";
//	[webview loadHTMLString:s baseURL:baseURL];
}

- (void)viewWillAppear:(BOOL)animated {
 	NSURL *baseURL = [NSURL URLWithString:@"http://buttons.notube.tv/"];		// for images etc?
	Gumbovi1AppDelegate *gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	
	webview.scalesPageToFit=TRUE;

	
	NSLog(@"WILL APPEAR: viewWillAppear, gad is: %@",gad.toJid);
	//libby
	FirstViewController * fvc = (FirstViewController *) [gad.tabBarController.viewControllers objectAtIndex:0];//ugh
    NSMutableArray *roster = fvc.roster_list;
    NSLog(@"roster list: %@",roster);
    
//	for (NSString *s in roster) {
//		NSLog(@"hello %@",s);
//	}
	
	NSLog(@"WILL APPEAR: vieWillAppear Setting gad.htmlInfo to webview, %@", gad.htmlInfo);
    NSLog(@"appear Webview is %@:",webview);
	[webview loadHTMLString:gad.htmlInfo baseURL:baseURL];

		NSLog(@"SENDING NOWP (as chat and IQ).");
		//NSString *msg = @"NOWP Please send 'now playing' html fragment..";
		//[ gad.xmppClient sendMessage:msg toJID:gad.toJid ] ;
		// lets try send an IQ too
	    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
	    [errorDetail setValue:@"Failed to send NOWP IQ" forKey:NSLocalizedDescriptionKey];
		NSError    *bError = [NSError errorWithDomain:@"buttons" code:100 userInfo:errorDetail];

	// send a NOWP IQ
	NSString *myXML = [NSString stringWithFormat:@"<iq type='get' to='%@'><query xmlns='http://buttons.foaf.tv/'><button>NOWP</button></query></iq>", [gad.toJid full]];
	NSXMLElement *myStanza = [[NSXMLElement alloc] initWithXMLString:myXML error:&bError];
	[ gad.xmppClient sendElement:myStanza];			
	
	
//	NSString *s = @"<html><head><title>Loading...</title><body>viewWillAppear...</body></html>";
//	[webview loadHTMLString:s baseURL:baseURL];

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
