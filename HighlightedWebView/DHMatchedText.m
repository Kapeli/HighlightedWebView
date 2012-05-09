#import "DHMatchedText.h"

@implementation DHMatchedText

@synthesize text;
@synthesize originalText;
@synthesize effectiveRange;
@synthesize highlightedSpan;
@synthesize foundRanges;
@synthesize firstMatch;

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
        self.originalText = [NSString stringWithString:[text nodeValue]];
    }
    return self;
}

- (void)highlightDOMNode
{
    self.firstMatch = nil;
    if(!foundRanges.count)
    {
        return;
    }
    [foundRanges sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSRange range1 = [obj1 rangeValue];
        NSRange range2 = [obj2 rangeValue];
        if(range1.location < range2.location)
        {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    DOMNode *parent = [text parentNode];
    DOMDocument *document = [text ownerDocument];
    DOMHTMLElement *spanWrap = (DOMHTMLElement*)[document createElement:@"span"];
    [spanWrap setAttribute:@"style" value:DHSpanWrap];
    [parent replaceChild:spanWrap oldChild:text];
    
    NSRange previousRange = NSMakeRange(0, 0);
    for(NSValue *foundRange in foundRanges)
    {
        NSRange range = [foundRange rangeValue];
        range = NSMakeRange(range.location - effectiveRange.location, range.length);
        if(previousRange.location + previousRange.length < range.location)
        {
            DOMText *aText = [document createTextNode:[originalText substringWithRange:NSMakeRange(previousRange.location+previousRange.length, range.location-previousRange.location-previousRange.length)]];
            [spanWrap appendChild:aText];
        }
        DOMElement *aSpan = [document createElement:@"span"];
        [aSpan setAttribute:@"style" value:DHHighlightSpan];
        if(text)
        {
            [text setNodeValue:[originalText substringWithRange:range]];
            [aSpan appendChild:text];
            self.firstMatch = text;
            self.text = nil;
        }
        else 
        {
            DOMText *aText = [document createTextNode:[originalText substringWithRange:range]];
            [aSpan appendChild:aText];
        }
        [spanWrap appendChild:aSpan];
        previousRange = range;
    }
    if(previousRange.location + previousRange.length < originalText.length)
    {
        DOMText *aText = [document createTextNode:[originalText substringWithRange:NSMakeRange(previousRange.location+previousRange.length, originalText.length-previousRange.location-previousRange.length)]];
        [spanWrap appendChild:aText];
    }
    self.highlightedSpan = spanWrap;
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
    [parent replaceChild:text oldChild:highlightedSpan];
    self.highlightedSpan = nil;
}

- (void)dealloc
{
    [text release];
    [firstMatch release];
    [highlightedSpan release];
    [originalText release];
    [foundRanges release];
    [super dealloc];
}
@end
