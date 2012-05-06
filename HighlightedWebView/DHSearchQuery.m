#import "DHSearchQuery.h"

@implementation DHSearchQuery

@synthesize query;
@synthesize isCaseSensitive;

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
    [query release];
    [super dealloc];
}

@end