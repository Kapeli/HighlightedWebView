#import "DHMatchedText.h"

@implementation DHMatchedText

@synthesize text;
@synthesize originalText;
@synthesize effectiveRange;
@synthesize highlightedSpan;
@synthesize foundRanges;

+ (DHMatchedText *)matchedTextWithDOMText:(DOMText *)aText andRange:(NSRange)aRange
{
    return [[[DHMatchedText alloc] initWithDOMText:aText andRange:aRange] autorelease];
}

- (id)initWithDOMText:(DOMText *)aText andRange:(NSRange)aRange
{
    self = [super init];
    if(self) 
    {
        self.text = aText;
        self.effectiveRange = aRange;
        self.foundRanges = [NSMutableSet set];
    }
    return self;
}

- (void)highlightDOMNode
{
    self.originalText = [NSString stringWithString:[text data]];
    DOMNode *parent = [text parentNode];
    DOMDocument *document = [text ownerDocument];
    DOMElement *span = [document createElement:@"span"];
    self.highlightedSpan = span;
//    [span set
}

- (void)dealloc
{
    [text release];
    [originalText release];
    [highlightedSpan release];
    [foundRanges release];
    [super dealloc];
}
@end
