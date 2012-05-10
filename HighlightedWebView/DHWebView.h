#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "DHSearchQuery.h"
#import "DHScrollbarHighlighter.h"

@interface DHWebView : WebView {
    NSTimer *workerTimer;
    DHSearchQuery *currentQuery;
    NSMutableArray *highlightedMatches;
    NSMutableArray *matchedTexts;
    NSMutableString *entirePageContent;
    DHScrollbarHighlighter *scrollHighlighter;
}

@property (retain) NSTimer *workerTimer;
@property (retain) DHSearchQuery *currentQuery;
@property (retain) NSMutableArray *highlightedMatches;
@property (retain) NSMutableArray *matchedTexts;
@property (retain) NSMutableString *entirePageContent;
@property (retain) DHScrollbarHighlighter *scrollHighlighter;

- (void)highlightQuery:(NSString *)aQuery caseSensitive:(BOOL)isCaseSensitive;
- (void)highlightQuery:(DHSearchQuery *)query;
- (void)startClearingHighlights;
- (void)clearHighlights;
- (void)traverseNodes:(NSMutableArray *)nodes;
- (void)highlightMatches;
- (void)timeredHighlightOfMatches:(NSMutableArray *)matches;
- (void)invalidateTimers;
- (NSString *)normalizeWhitespaces:(NSString *)aString;
- (void)selectRangeUsingEncodedDictionary:(NSMutableDictionary *)dictionary;
- (void)clearSelection;
- (void)tryToGuessSelection:(NSDictionary *)fromDict;
- (void)didStartProvisionalLoad;

@end