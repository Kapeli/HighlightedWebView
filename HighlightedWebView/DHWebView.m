#import "DHWebView.h"
#import "DHMatchedText.h"

@implementation DHWebView

@synthesize usesTimer;
@synthesize timerInterval;
@synthesize currentQuery;
@synthesize traverseTimer;
@synthesize highlightedMatches;
@synthesize matchedTexts;
@synthesize entirePageContent;

- (void)awakeFromNib
{
    timerInterval = 0.005f;
    usesTimer = NO;
}

- (BOOL)searchFor:(NSString *)string direction:(BOOL)forward caseSensitive:(BOOL)caseFlag wrap:(BOOL)wrapFlag
{
    BOOL result = [super searchFor:string direction:forward caseSensitive:caseFlag wrap:wrapFlag];
    if(result)
    {
        DHSearchQuery *query = [DHSearchQuery searchQueryWithQuery:string caseSensitive:caseFlag];
        [self highlightQuery:query];
    }
    return result;
}

- (void)highlightQuery:(DHSearchQuery *)query
{
    if([currentQuery isEqualTo:query])
    {
        return;
    }
    self.currentQuery = query;
    DOMDocument *document = [[self mainFrame] DOMDocument];
    [self clearHighlights];
    self.matchedTexts = [NSMutableArray array];
    self.entirePageContent = [NSMutableString string];
    [self traverseNodes:[NSMutableArray arrayWithObject:[document body]]];
}

- (void)clearHighlights
{
//    [self invalidateTimers];
//    for(DOMNode *node in highlightedNodes)
//    {
//        DOMNode *parent = [node parentNode];
//        DOMText *previous = (DOMText *)[node previousSibling];
//        NSString *data = [node textContent];
//        [parent removeChild:node];
//        [previous appendData:data];
//    }
//    self.highlightedNodes = [NSMutableArray array];
}

- (void)traverseNodes:(NSMutableArray *)nodes
{
    for(int i = 0; i < 1000; i++)
    {
        if(!nodes.count)
        {
            [self highlightMatches];
            return;
        }
        DOMNode *node = [nodes objectAtIndex:0];
        [nodes removeObjectAtIndex:0];
        if(node.nodeType == DOM_TEXT_NODE)
        {
            DOMText *textNode = (DOMText *)node;
            NSString *content = [textNode data];
            DHMatchedText *matchedText = [DHMatchedText matchedTextWithDOMText:textNode andRange:NSMakeRange(entirePageContent.length, content.length)];
            [entirePageContent appendString:content];
            [matchedTexts addObject:matchedText];
        }
        if([node hasChildNodes])
        {
            DOMNodeList *childNodes = [node childNodes];
            for(int i = 0; i < childNodes.length; i++)
            {
                [nodes insertObject:[childNodes item:i] atIndex:i];
            }
        }
    }
    if(usesTimer)
    {
        [self invalidateTimers];
        self.traverseTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(traverseWithTimer:) userInfo:nodes repeats:NO];
    }
    else
    {
        [self traverseNodes:nodes];
    }
}

- (void)traverseWithTimer:(NSTimer *)timer
{
    NSMutableArray *userInfo = [timer userInfo];
    [self traverseNodes:userInfo];
}

- (void)highlightMatches
{
    NSMutableArray *foundRanges = [NSMutableArray array];
    NSRange foundRange;
    NSInteger scanLocation = 0;
    do 
    {
        NSStringCompareOptions options = ([currentQuery isCaseSensitive]) ? NSLiteralSearch : NSCaseInsensitiveSearch;
        foundRange = [entirePageContent rangeOfString:[currentQuery query] options:options range:NSMakeRange(scanLocation, entirePageContent.length-scanLocation)];
        if(foundRange.location != NSNotFound)
        {
            scanLocation = foundRange.location+foundRange.length;
            [foundRanges addObject:[NSValue valueWithRange:foundRange]];
        }
    } 
    while (foundRange.location != NSNotFound);
    NSLog(@"found ranges %d", foundRanges.count);

    NSEnumerator *matchesEnumerator = [matchedTexts objectEnumerator];
    DHMatchedText *currentMatch = [matchesEnumerator nextObject];
    NSMutableSet *foundMatches = [NSMutableSet set];
    for(NSValue *foundRange in foundRanges)
    {
        NSRange actualRange = [foundRange rangeValue];
        do 
        {
            NSRange intersectionRange = NSIntersectionRange([currentMatch effectiveRange], actualRange);
            if(intersectionRange.length > 0)
            {
                [foundMatches addObject:currentMatch];
                [[currentMatch foundRanges] addObject:[NSValue valueWithRange:intersectionRange]];
                if(intersectionRange.location+intersectionRange.length >= actualRange.location+actualRange.length)
                {
                    break;
                }
            }
            else
            {
                currentMatch = [matchesEnumerator nextObject];
            }
        } while (currentMatch);
    }
    NSLog(@"found matches %d", foundMatches.count);
    
}

- (void)invalidateTimers
{
    if([self.traverseTimer isValid])
    {
        [traverseTimer invalidate];
    }
    self.traverseTimer = nil;
}

- (void)dealloc
{
    [self invalidateTimers];
    [currentQuery release];
    [highlightedMatches release];
    [matchedTexts release];
    [entirePageContent release];
    [super dealloc];
}

@end