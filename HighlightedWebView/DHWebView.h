#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "DHSearchQuery.h"

@interface DHWebView : WebView {
    BOOL usesTimer;
    NSTimer *workerTimer;
    NSTimeInterval timerInterval;
    DHSearchQuery *currentQuery;
    NSMutableArray *highlightedMatches;
    NSMutableArray *matchedTexts;
    NSMutableString *entirePageContent;
}

@property (assign) BOOL usesTimer;
@property (retain) NSTimer *workerTimer;
@property (assign) NSTimeInterval timerInterval;
@property (retain) DHSearchQuery *currentQuery;
@property (retain) NSMutableArray *highlightedMatches;
@property (retain) NSMutableArray *matchedTexts;
@property (retain) NSMutableString *entirePageContent;

- (void)highlightQuery:(NSString *)aQuery caseSensitive:(BOOL)isCaseSensitive;
- (void)highlightQuery:(DHSearchQuery *)query;
- (void)traverseNodes:(NSMutableArray *)nodes;
- (void)highlightMatches;
- (void)invalidateTimers;
- (NSString *)normalizeWhitespaces:(NSString *)aString;

@end