#import <Foundation/Foundation.h>

@interface DHSearchQuery : NSObject {
    NSString *query;
    BOOL isCaseSensitive;
    NSMutableDictionary *selectionAfterHighlight;
    NSMutableDictionary *selectionAfterClear;
}

@property (retain) NSString *query;
@property (assign) BOOL isCaseSensitive;
@property (retain) NSMutableDictionary *selectionAfterHighlight;
@property (retain) NSMutableDictionary *selectionAfterClear;

+ (DHSearchQuery *)searchQueryWithQuery:(NSString *)aQuery caseSensitive:(BOOL)caseSensitive;
- (id)initWithQuery:(NSString *)aQuery caseSensitive:(BOOL)caseSensitive;
- (BOOL)isEqualTo:(DHSearchQuery *)object;

@end
