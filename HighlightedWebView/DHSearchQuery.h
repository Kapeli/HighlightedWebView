#import <Foundation/Foundation.h>

@interface DHSearchQuery : NSObject {
    NSString *query;
    BOOL isCaseSensitive;
    BOOL wrap;
    BOOL direction;
    BOOL didSearch;
}

@property (retain) NSString *query;
@property (assign) BOOL isCaseSensitive;
@property (assign) BOOL wrap;
@property (assign) BOOL direction;
@property (assign) BOOL didSearch;

+ (DHSearchQuery *)searchQueryWithQuery:(NSString *)aQuery caseSensitive:(BOOL)caseSensitive;
- (id)initWithQuery:(NSString *)aQuery caseSensitive:(BOOL)caseSensitive;
- (BOOL)isEqualTo:(DHSearchQuery *)object;

@end
