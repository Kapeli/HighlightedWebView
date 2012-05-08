#import "DHWebView.h"
#import "DHMatchedText.h"

@implementation DHWebView

@synthesize currentQuery;
@synthesize workerTimer;
@synthesize highlightedMatches;
@synthesize matchedTexts;
@synthesize entirePageContent;

- (BOOL)searchFor:(NSString *)string direction:(BOOL)forward caseSensitive:(BOOL)caseFlag wrap:(BOOL)wrapFlag
{
    if(!string.length)
    {
        self.currentQuery = nil;
        [self startClearingHighlights];
        return NO;
    }
    BOOL result = [super searchFor:string direction:forward caseSensitive:caseFlag wrap:wrapFlag];
    if(result)
    {
        DHSearchQuery *query = [DHSearchQuery searchQueryWithQuery:string caseSensitive:caseFlag];
        [query setWrap:wrapFlag];
        [query setDirection:forward];
        [query setDidSearch:YES];
        [self highlightQuery:query];
    }
    else
    {
        self.currentQuery = nil;
        [self startClearingHighlights];
    }
    return result;
}

- (void)highlightQuery:(NSString *)aQuery caseSensitive:(BOOL)isCaseSensitive
{
    DHSearchQuery *query = [DHSearchQuery searchQueryWithQuery:aQuery caseSensitive:isCaseSensitive];
    [self highlightQuery:query];
}

- (void)highlightQuery:(DHSearchQuery *)query
{
    if([currentQuery isEqualTo:query])
    {
        return;
    }
    self.currentQuery = query;
    [self startClearingHighlights];
}

- (void)startClearingHighlights
{
    [self invalidateTimers];
    [self clearHighlights];
}

- (void)clearHighlights
{
    for(int i = 0; i < 1000; i++)
    {
        if(!highlightedMatches.count)
        {
            self.highlightedMatches = [NSMutableArray array];
            self.matchedTexts = [NSMutableArray array];
            self.entirePageContent = [NSMutableString string];
            if(!currentQuery.query.length)
            {
                return;
            }
            DOMDocument *document = [self mainFrameDocument];
            DOMHTMLElement *body = [document body];
            if(!body)
            {
                return;
            }
            [self traverseNodes:[NSMutableArray arrayWithObject:body]];
            return;
        }
        DHMatchedText *match = [highlightedMatches objectAtIndex:0];
        [match retain];
        [highlightedMatches removeObjectAtIndex:0];
        [match clearHighlight];
        [match release];
    }
    self.workerTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(clearHighlights) userInfo:nil repeats:NO];
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
        [node retain];
        [nodes removeObjectAtIndex:0];
        if(node.nodeType == DOM_TEXT_NODE || node.nodeType == DOM_CDATA_SECTION_NODE)
        {
            DOMText *textNode = (DOMText *)node;
  
            NSString *content = [self normalizeWhitespaces:[textNode nodeValue]];
            if(content.length)
            {
                DHMatchedText *matchedText = [DHMatchedText matchedTextWithDOMText:textNode andRange:NSMakeRange(entirePageContent.length, content.length)];
                [entirePageContent appendString:content];
                [matchedTexts addObject:matchedText];
            }
        }
        if(node.nodeType == DOM_ELEMENT_NODE)
        {
            NSString *tagName = [(DOMElement*)node tagName];
            if(![tagName isCaseInsensitiveLike:@"style"] && ![tagName isCaseInsensitiveLike:@"script"])
            {
                DOMNodeList *childNodes = [node childNodes];
                for(int i = 0; i < childNodes.length; i++)
                {
                    [nodes insertObject:[childNodes item:i] atIndex:i];
                }
            }
        }
        [node release];
    }
    self.workerTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(traverseWithTimer:) userInfo:nodes repeats:NO];
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
                else
                {
                    currentMatch = [matchesEnumerator nextObject];
                }
            }
            else
            {
                currentMatch = [matchesEnumerator nextObject];
            }
        } while (currentMatch);
    }
    if(foundMatches.count)
    {
        [self timeredHighlightOfMatches:[NSMutableArray arrayWithArray:[foundMatches allObjects]]];
    }
}

- (void)timeredHighlightOfMatches:(NSMutableArray *)matches
{
    if([matches isKindOfClass:[NSTimer class]])
    {
        matches = [(NSTimer*)matches userInfo];
    }
    for(int i = 0; i < 100; i++)
    {
        if(!matches.count)
        {
            if(![self selectedDOMRange] && currentQuery.didSearch)
            {
                [self searchFor:currentQuery.query direction:currentQuery.direction caseSensitive:currentQuery.isCaseSensitive wrap:currentQuery.wrap];
            }
            return;
        }
        DHMatchedText *last = [matches lastObject];
        [highlightedMatches addObject:last];
        [matches removeLastObject];
        [last highlightDOMNode];
    }
    self.workerTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(timeredHighlightOfMatches:) userInfo:matches repeats:NO];
}

- (void)invalidateTimers
{
    if([self.workerTimer isValid])
    {
        [workerTimer invalidate];
    }
    self.workerTimer = nil;
}

- (NSString *)normalizeWhitespaces:(NSString *)aString
{
    // Normalize the whitespaces so we can avoid characters like "thin whitespace" (U+2009).
    // Yes, I tried using NSWidthInsensitiveSearch, but it only works for comparisons, not searching, hence the name (GG Apple!)
    NSRange foundRange;
    NSInteger scanLocation = 0;
    NSMutableString *string = [NSMutableString stringWithString:aString];
    do
    {
        foundRange = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:NSLiteralSearch range:NSMakeRange(scanLocation, string.length-scanLocation)];
        if(foundRange.location != NSNotFound)
        {
            scanLocation = foundRange.location+foundRange.length;
            [string replaceCharactersInRange:foundRange withString:@" "];
        }
    } while (foundRange.location != NSNotFound);
    return string;
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