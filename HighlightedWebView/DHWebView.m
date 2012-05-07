#import "DHWebView.h"
#import "DHMatchedText.h"

@implementation DHWebView

@synthesize usesTimer;
@synthesize timerInterval;
@synthesize currentQuery;
@synthesize workerTimer;
@synthesize highlightedMatches;
@synthesize matchedTexts;
@synthesize entirePageContent;

- (void)awakeFromNib
{
    timerInterval = 0.01f;
    usesTimer = YES;
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
            DOMDocument *document = [[self mainFrame] DOMDocument];
            [self traverseNodes:[NSMutableArray arrayWithObject:[document body]]];
            return;
        }
        DHMatchedText *match = [highlightedMatches objectAtIndex:0];
        [match retain];
        [highlightedMatches removeObjectAtIndex:0];
        [match clearHighlight];
        [match release];
    }
    self.workerTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(clearHighlights) userInfo:nil repeats:NO];
}

- (void)traverseNodes:(NSMutableArray *)nodes
{
    for(int i = 0; i < 1000; i++)
    {
        if(!nodes.count)
        {
            NSLog(@"end");
            [self highlightMatches];
            return;
        }
        DOMNode *node = [nodes objectAtIndex:0];
        [node retain];
        [nodes removeObjectAtIndex:0];
        if(node.nodeType == DOM_TEXT_NODE || node.nodeType == DOM_CDATA_SECTION_NODE)
        {
            DOMText *textNode = (DOMText *)node;
            NSString *content = [textNode nodeValue];
            // Normalize the whitespaces so we avoid getting screwed by characters like "thin whitespace" (U+2009).
            // Yes, I tried using NSWidthInsensitiveSearch, but it only works for comparisons, not searching, hence the name (GG Apple!)
            NSRange foundRange;
            NSInteger scanLocation = 0;
            do 
            {
                foundRange = [content rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSLiteralSearch range:NSMakeRange(scanLocation, content.length-scanLocation)];
                if(foundRange.location != NSNotFound)
                {
                    scanLocation = foundRange.location+foundRange.length;
                    content = [content stringByReplacingCharactersInRange:foundRange withString:@" "];
                }
            } 
            while (foundRange.location != NSNotFound);
            DHMatchedText *matchedText = [DHMatchedText matchedTextWithDOMText:textNode andRange:NSMakeRange(entirePageContent.length, content.length)];
            [entirePageContent appendString:content];
            [matchedTexts addObject:matchedText];
        }
        if(node.nodeType == DOM_ELEMENT_NODE)
        {
            DOMNodeList *childNodes = [node childNodes];
            for(int i = 0; i < childNodes.length; i++)
            {
                [nodes insertObject:[childNodes item:i] atIndex:i];
            }
        }
        [node release];
    }
    if(usesTimer)
    {
        self.workerTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(traverseWithTimer:) userInfo:nodes repeats:NO];
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
    [self timeredHighlightOfMatches:[NSMutableArray arrayWithArray:[foundMatches allObjects]]];
}

- (void)timeredHighlightOfMatches:(NSMutableArray *)matches
{
    if([matches isKindOfClass:[NSTimer class]])
    {
        matches = [(NSTimer*)matches userInfo];
    }
    for(int i = 0; i < 1000; i++)
    {
        if(!matches.count)
        {
            return;
        }
        DHMatchedText *last = [matches lastObject];
        [highlightedMatches addObject:last];
        [matches removeLastObject];
        [last highlightDOMNode];
    }
    if(usesTimer)
    {
        self.workerTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(timeredHighlightOfMatches:) userInfo:matches repeats:NO];
    }
    else
    {
        [self timeredHighlightOfMatches:matches];
    }
}

- (void)invalidateTimers
{
    if([self.workerTimer isValid])
    {
        [workerTimer invalidate];
    }
    self.workerTimer = nil;
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