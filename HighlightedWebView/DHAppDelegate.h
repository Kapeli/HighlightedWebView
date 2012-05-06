//
//  DHAppDelegate.h
//  HighlightedWebView
//
//  Created by Bogdan Popescu on 05/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DHWebView.h"

@interface DHAppDelegate : NSObject <NSApplicationDelegate> {
}

@property (assign) IBOutlet DHWebView *webView;

- (IBAction)search:(id)sender;

@end
