#import "DHScrollbarHighlighter.h"
#import "DHMatchedText.h"

@implementation DHScrollbarHighlighter

@synthesize parentView;
@synthesize matches;
@synthesize highlightRects;

+ (DHScrollbarHighlighter *)highlighterWithWebView:(WebView *)aWebView andMatches:(NSArray *)someMatches
{
    return [[[self alloc] initWithWebView:aWebView andMatches:someMatches] autorelease];
}

- (id)initWithWebView:(WebView *)aWebView andMatches:(NSArray *)someMatches
{
    NSScrollView *scrollView = [[[[aWebView mainFrame] frameView] documentView] enclosingScrollView];
    if(scrollView && scrollView.verticalScroller && scrollView.verticalScroller.frame.origin.x > 0)
    {
        NSRect scrollerFrame = [scrollView verticalScroller].frame;
        NSRect knobRect = [[scrollView verticalScroller] rectForPart:NSScrollerKnob];
        [self initWithFrame:NSMakeRect(scrollerFrame.origin.x+knobRect.origin.x, scrollerFrame.origin.y, knobRect.size.width, scrollerFrame.size.height)];
        if(self)
        {
            self.parentView = aWebView;
            self.matches = someMatches;
            self.highlightRects = [NSMutableArray array];
            [self setAutoresizingMask:NSViewMinXMargin | NSViewHeightSizable];
            [self calculatePositions];
            [self setWantsLayer:YES];
            [parentView addSubview:self];
        }
        return self;
    }
    return nil;
}

- (void)calculatePositions
{
    float documentHeight = [[[[parentView mainFrame] frameView] documentView] bounds].size.height;
    float ownHeight = self.frame.size.height;
    float ownWidth = self.frame.size.width;
    NSMutableArray *rects = [NSMutableArray array];
    for(DHMatchedText *matchedText in matches)
    {
        DOMHTMLElement *wrapperSpan = (DOMHTMLElement*)[matchedText highlightedSpan];
        int top = [self topPositionForElement:wrapperSpan];
        float flippedY = top / documentHeight * ownHeight;
        float actualY = ownHeight-flippedY;
        actualY = (actualY <= 3) ? 3 : (actualY > ownHeight - 4) ? ownHeight-4 : actualY;
        [rects addObject:[NSValue valueWithRect:NSMakeRect(0, actualY-1.5, ownWidth, 3)]];
    }
    for(NSValue *rectValue in rects)
    {
        NSRect rect = [rectValue rectValue];
        BOOL didIntersect = NO;
        for(NSValue *otherRectValue in highlightRects)
        {
            NSRect otherRect = [otherRectValue rectValue];
            if(NSIntersectsRect(rect, otherRect))
            {
                didIntersect = YES;
                break;
            }
        }
        if(!didIntersect)
        {
            [highlightRects addObject:rectValue];
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSColor *inner = [NSColor colorWithCalibratedRed:0.984f green:0.956f blue:0.788f alpha:0.5f];
    NSColor *outer = [NSColor colorWithCalibratedRed:0.941f green:0.8f blue:0.203f alpha:0.8f];
    for(NSValue *highlightRect in highlightRects)
    {
        NSRect rect = [highlightRect rectValue];
        [inner set];
        NSRectFill(rect);
        [outer set];
        [NSBezierPath strokeRect:rect];
    }
}

- (int)topPositionForElement:(DOMHTMLElement *)element
{
    int top = 0;
    DOMHTMLElement *o = element;
    DOMElement *offsetParent = o.offsetParent;
    DOMElement *el = o;
    while(el.parentNode)
    {
        el = (DOMElement*)el.parentNode;
        if([el respondsToSelector:@selector(offsetParent)] && el.offsetParent)
        {
            top -= el.scrollTop;
        }
        if(el == offsetParent)
        {
            top += o.offsetTop;
            if(el.clientTop && ![el.nodeName isCaseInsensitiveLike:@"TABLE"])
            {
                top += el.clientTop;
            }
            o = (DOMHTMLElement*)el;
            if([o respondsToSelector:@selector(offsetParent)])
            {
                if(!o.offsetParent)
                {
                    if(o.offsetTop)
                    {
                        top += o.offsetTop;
                    }
                }
                offsetParent = o.offsetParent;
            }
            else
            {
                offsetParent = nil;
            }
        }
    }
    return top;
}

- (void)dealloc
{
    [parentView release];
    [matches release];
    [highlightRects release];
    [super dealloc];
}

@end
