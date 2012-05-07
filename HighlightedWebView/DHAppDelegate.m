#import "DHAppDelegate.h"

@implementation DHAppDelegate

@synthesize webView;

- (void)controlTextDidChange:(NSNotification *)obj
{
    NSTextView *field = [[obj userInfo] objectForKey:@"NSFieldEditor"];
    [webView highlightQuery:[field string] caseSensitive:NO];
}

- (IBAction)search:(id)sender
{
    NSString *query = [sender stringValue];
    [webView searchFor:query direction:YES caseSensitive:NO wrap:YES];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    [webView setMainFrameURL:@"file:///Users/bogdan/Library/Application%20Support/Dash/DocSets/Android/Android.docset/Contents/Resources/Documents/docs/reference/android/widget/AbsListView.html"];
    [webView setMainFrameURL:@"http://kapeli.com/dash"];
}

@end
