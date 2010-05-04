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
#import "DDXML.h"
#import "XMPPStream.h"

@implementation WebViewController

@synthesize webview;
@synthesize theActivityIndicatorView;
@synthesize urlAddress;

- (void)viewDidLoad {
	if (webview == NULL) {
		VerboseLog(@"viewDidLoad called with NULL webview, returning immediately.");	
		return;
	}
    VerboseLog(@"Webview viewDidLoad %@:",webview);
	Gumbovi1AppDelegate *buttons = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	VerboseLog(@"DID LOAD: viewDidload, buttons app is: %@",buttons);
}

- (void)viewWillAppear:(BOOL)animated {
 	NSURL *baseURL = [NSURL URLWithString:@"http://buttons.notube.tv/"];		// for images etc?
	Gumbovi1AppDelegate *gad = (Gumbovi1AppDelegate *) [[UIApplication sharedApplication] delegate];
	webview.scalesPageToFit=TRUE;	
	VerboseLog(@"WILL APPEAR: viewWillAppear, gad.toJid is: %@",gad.toJid);
	FirstViewController * fvc = (FirstViewController *) [gad.tabBarController.viewControllers objectAtIndex:0];//ugh
    NSMutableArray *roster = fvc.roster_list;
    DebugLog(@"roster list: %@",roster);
	DebugLog(@"WILL APPEAR: vieWillAppear Setting gad.htmlInfo to webview, %@", gad.htmlInfo);
    DebugLog(@"appear Webview is %@:",webview);
	//[webview flashScrollIndicators];
	[webview loadHTMLString:gad.htmlInfo baseURL:baseURL];
	NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
	[errorDetail setValue:@"Failed to send NOWP IQ" forKey:NSLocalizedDescriptionKey];
	NSError    *bError = [NSError errorWithDomain:@"buttons" code:100 userInfo:errorDetail]; // TODO: define protocol errors
	// send a NOWP IQ via Buttons (TODO, move logic to a buttons class. JIRA needed).
	NSString *rs = [gad.xmppLink generateUUID]; // FIXME minor XMPP library dependency introduced here
	NSString *myXML = [NSString stringWithFormat:@"<iq type='get' to='%@' id='%d'><query xmlns='http://buttons.foaf.tv/'><button>NOWP</button></query></iq>", [gad.toJid full], rs];
	DebugLog(@"WebView Sending IQ XML: %@", myXML); 
	NSXMLElement *myStanza = [[NSXMLElement alloc] initWithXMLString:myXML error:&bError];
	[gad sendIQ:myStanza];			

}



- (void)webViewDidStartLoad:(UIWebView *)wv {
	DebugLog (@"webViewDidStartLoad");
	[theActivityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	DebugLog (@"webViewDidFinishLoad");
	[theActivityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
	DebugLog (@"webView:didFailLoadWithError");
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
