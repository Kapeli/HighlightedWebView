#import "DHSearchQuery.h"

@implementation DHSearchQuery

@synthesize query;
@synthesize isCaseSensitive;
@synthesize selectionAfterHighlight;
@synthesize selectionAfterClear;

+ (DHSearchQuery *)searchQueryWithQuery:(NSString *)aQuery caseSensitive:(BOOL)caseSensitive
{
    return [[[DHSearchQuery alloc] initWithQuery:aQuery caseSensitive:caseSensitive] autorelease];
}

- (id)initWithQuery:(NSString *)aQuery caseSensitive:(BOOL)caseSensitive
{
    self = [super init];
    if(self) 
    {
        self.query = [NSString stringWithString:aQuery];
        self.isCaseSensitive = caseSensitive;
        self.selectionAfterClear = [NSMutableDictionary dictionary];
        self.selectionAfterHighlight = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)isEqualTo:(DHSearchQuery *)object
{
    if(!object)
    {
        return NO;
    }
    if(isCaseSensitive != object.isCaseSensitive)
    {
        return NO;
    }
    if(isCaseSensitive)
    {
        return [query isEqualToString:object.query]; 
    }
    return [query isCaseInsensitiveLike:object.query];
}

- (void)dealloc
{
    [selectionAfterClear release];
    [selectionAfterHighlight release];
    [query release];
    [super dealloc];
}

@end