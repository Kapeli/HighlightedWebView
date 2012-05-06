#import <Foundation/Foundation.h>

@interface DHSearchQuery : NSObject {
    NSString *query;
    BOOL isCaseSensitive;
}

@property (retain) NSString *query;
@property (assign) BOOL isCaseSensitive;

+ (DHSearchQuery *)searchQueryWithQuery:(NSString *)aQuery caseSensitive:(BOOL)caseSensitive;
- (id)initWithQuery:(NSString *)aQuery caseSensitive:(BOOL)caseSensitive;
- (BOOL)isEqualTo:(DHSearchQuery *)object;

@end
