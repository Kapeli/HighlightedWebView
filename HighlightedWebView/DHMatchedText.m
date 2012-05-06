#import "DHMatchedText.h"
#import "NSString+GTM.h"

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
        self.originalText = [NSString stringWithString:[text data]];
    }
    return self;
}

- (void)highlightDOMNode
{
    if(!foundRanges.count)
    {
        return;
    }
    [foundRanges sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSRange range1 = [obj1 rangeValue];
        NSRange range2 = [obj2 rangeValue];
        if(range1.location < range2.location)
        {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    NSString *spanContent = [NSString stringWithString:originalText];
    for(NSValue *foundRange in foundRanges)
    {
        NSRange range = [foundRange rangeValue];
        range = NSMakeRange(range.location - effectiveRange.location, range.length);
        spanContent = [spanContent stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"DHSpanPLACEHOLDER%@DHSpanPLACEHOLDEREND", [spanContent substringWithRange:range]]];
    }
    spanContent = [spanContent stringByEscapingForHTML];
    spanContent = [spanContent stringByReplacingOccurrencesOfString:@"DHSpanPLACEHOLDEREND" withString:@"</span>"];
    spanContent = [spanContent stringByReplacingOccurrencesOfString:@"DHSpanPLACEHOLDER" withString:@"<span style='color:red'>"];
    DOMNode *parent = [text parentNode];
    if(![parent isKindOfClass:[DOMNode class]])
    {
        return;
    }
    DOMDocument *document = [text ownerDocument];
    DOMHTMLElement *span = (DOMHTMLElement*)[document createElement:@"span"];
    self.highlightedSpan = span;
    [span setInnerHTML:spanContent];
    [parent insertBefore:span refChild:text];
    [parent removeChild:text];
    self.text = nil;
}

- (void)clearHighlight
{
    if(!highlightedSpan)
    {
        return;
    }
    DOMNode *parent = [highlightedSpan parentNode];
    DOMDocument *document = [highlightedSpan ownerDocument];
    DOMText *original = [document createTextNode:originalText];
    self.text = original;
    [parent insertBefore:text refChild:highlightedSpan];
    [parent removeChild:highlightedSpan];
    self.highlightedSpan = nil;
}

- (void)dealloc
{
    [highlightedSpan release];
    [originalText release];
    [foundRanges release];
    [super dealloc];
}
@end
