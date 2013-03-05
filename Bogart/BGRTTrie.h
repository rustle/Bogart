//
//  BGRTTrie.h
//  Bogart
//	

#import <Foundation/Foundation.h>

@interface BGRTTrie : NSObject

@property (nonatomic) char state;
@property (nonatomic) char *value;
@property (nonatomic) BGRTTrie *sibling;
@property (nonatomic) BGRTTrie *children;

+ (instancetype)makeMap:(void *)dummy, ...;
- (void)addData:(char *)data length:(int)length value:(char *)value;
- (char *)getData:(char *)data length:(int)length;

@end
