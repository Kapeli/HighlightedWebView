#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface DHWebView : WebView

- (void)highlightQuery:(NSString *)aQuery caseSensitive:(BOOL)isCaseSensitive;

@end
