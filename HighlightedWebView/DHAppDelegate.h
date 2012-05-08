#import <Cocoa/Cocoa.h>
#import "DHWebView.h"

@interface DHAppDelegate : NSObject <NSApplicationDelegate> {
}

@property (assign) IBOutlet DHWebView *webView;

- (IBAction)search:(id)sender;

@end
