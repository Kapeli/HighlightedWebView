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
    if(scrollView && scrollView.verticalScroller && !NSEqualRects(scrollView.verticalScroller.frame, NSZeroRect))
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
            [parentView addSubview:self];
        }
    }
    return self;
}

- (void)calculatePositions
{
    NSInteger scrollHeight = [[[parentView mainFrameDocument] body] scrollHeight];
    float ownHeight = self.frame.size.height;
    float ownWidth = self.frame.size.width;
    NSMutableArray *rects = [NSMutableArray array];
    for(DHMatchedText *matchedText in matches)
    {
        DOMHTMLElement *wrapperSpan = (DOMHTMLElement*)[matchedText highlightedSpan];
        for(int i = 0; i < wrapperSpan.children.length; i++)
        {
            DOMHTMLElement *highlightedSpan = (DOMHTMLElement*)[[wrapperSpan children] item:i];
            if(highlightedSpan.nodeType == DOM_ELEMENT_NODE)
            {
                float flippedY = [highlightedSpan offsetTop] / (float)scrollHeight * ownHeight;
                float actualY = ownHeight-flippedY;
                int roundY = (int)actualY;
                [rects addObject:[NSValue valueWithRect:NSMakeRect(0, roundY, ownWidth, 3)]];
            }
        }
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
    NSColor *inner = [NSColor colorWithCalibratedRed:0.984f green:0.956f blue:0.788f alpha:1.0f];
    NSColor *outer = [NSColor colorWithCalibratedRed:0.941f green:0.8f blue:0.203f alpha:1.0f];
    for(NSValue *highlightRect in highlightRects)
    {
        NSRect rect = [highlightRect rectValue];
        [inner set];
        NSRectFill(rect);
        [outer set];
        [NSBezierPath strokeRect:rect];
    }
}

- (void)dealloc
{
    [parentView release];
    [matches release];
    [highlightRects release];
    [super dealloc];
}

@end
