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
        self.foundRanges = [NSMutableArray array];
    }
    return self;
}

- (void)highlightDOMNode
{
    if(!foundRanges.count)
    {
        return;
    }
    self.originalText = [NSString stringWithString:[text data]];
    NSString *spanContent = [text data];
    for(int i=foundRanges.count-1; i>= 0; i--)
    {
        NSRange range = [[foundRanges objectAtIndex:i] rangeValue];
        range = NSMakeRange(range.location - effectiveRange.location, range.length);
        spanContent = [spanContent stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"<span style='color:red'>%@</span>", [spanContent substringWithRange:range]]];
    }
    DOMNode *parent = [text parentNode];
    DOMDocument *document = [text ownerDocument];
    DOMHTMLElement *span = (DOMHTMLElement*)[document createElement:@"span"];
    self.highlightedSpan = span;
    [span setInnerHTML:spanContent];
    [parent insertBefore:span refChild:text];
    [parent removeChild:text];
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
