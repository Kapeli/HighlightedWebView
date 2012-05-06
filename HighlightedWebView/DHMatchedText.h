#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "DHSearchQuery.h"

@interface DHMatchedText : NSObject {
    DOMText *text;
    NSString *originalText;
    NSRange effectiveRange;
    DOMNode *highlightedSpan;
    NSMutableSet *foundRanges;
}

@property (retain) DOMText *text;
@property (retain) NSString *originalText;
@property (assign) NSRange effectiveRange;
@property (retain) DOMNode *highlightedSpan;
@property (retain) NSMutableSet *foundRanges;

+ (DHMatchedText *)matchedTextWithDOMText:(DOMText *)aText andRange:(NSRange)aRange;
- (id)initWithDOMText:(DOMText *)aText andRange:(NSRange)aRange;
- (void)highlightDOMNode;

@end
