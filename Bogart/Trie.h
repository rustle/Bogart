//
//  Trie.h
//  Bogart
//
//  Created by Doug Russell on 3/5/13.
//  Copyright (c) 2013 RSTL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trie : NSObject

@property (nonatomic) char state;
@property (nonatomic) char *value;
@property (nonatomic) Trie *sibling;
@property (nonatomic) Trie *children;

+ (instancetype)makeMap:(void *)dummy, ...;
- (void)addData:(char *)data length:(int)length value:(char *)value;
- (char *)getData:(char *)data length:(int)length;

@end
