#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "DHSearchQuery.h"

@interface DHMatchedText : NSObject {
    DOMText *text;
    NSString *originalText;
    NSRange effectiveRange;
    DOMNode *highlightedSpan;
    NSMutableArray *foundRanges;
    DOMNode *firstMatch;
}

@property (retain) DOMText *text;
@property (retain) NSString *originalText;
@property (assign) NSRange effectiveRange;
@property (retain) DOMNode *highlightedSpan;
@property (retain) NSMutableArray *foundRanges;
@property (retain) DOMNode *firstMatch;

+ (DHMatchedText *)matchedTextWithDOMText:(DOMText *)aText andRange:(NSRange)aRange;
- (id)initWithDOMText:(DOMText *)aText andRange:(NSRange)aRange;
- (void)highlightDOMNode;
- (void)clearHighlight;

@end

// This is the "alternate" style (the one in the screenshot), abandoned because it resizes the elements and also looks weird
// with elements that span across multiple nodes.

// static NSString *DHHighlightSpan = @"-webkit-border-radius: 7px; -webkit-box-shadow: 0px 1px 3px rgba(0, 0, 0, 0.6); background: -webkit-gradient(linear, 0% 0%, 0% 100%, from(rgba(244, 234, 38, 0.7)), to(rgba(237, 206, 0, 0.7)) ); border: 1px solid rgba(244, 234, 38, 0.8);display:inline;position:static;margin:0px 0px 0px 0px;padding:0px 0px 0px 0px;";

static NSString *DHHighlightSpan = @"background: -webkit-gradient(linear, 0% 0%, 0% 100%, from(rgba(244, 234, 38, 0.7)), to(rgba(237, 206, 0, 0.7)) ) !important;display:inline !important;position:static !important;margin:0px 0px 0px 0px !important;padding:0px 0px 0px 0px !important;opacity:1.0 !important; float:inherit !important; font:inherit !important;";
static NSString *DHSpanWrap = @"display:inline !important;position:static !important;margin:0px 0px 0px 0px !important;padding:0px 0px 0px 0px !important;opacity:1.0 !important; float:inherit !important; font:inherit !important;";