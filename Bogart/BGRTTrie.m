//
//  BGRTTrie.m
//  Bogart
//
//  Created by Doug Russell on 3/5/13.
//  Copyright (c) 2013 RSTL. All rights reserved.
//

#import "BGRTTrie.h"

@implementation BGRTTrie

+ (instancetype)makeMap:(void *)dummy, ...
{
	va_list ap;
	char *key;
	char *value;
	BGRTTrie *newMap = [BGRTTrie new];

	va_start(ap, dummy);
	while ((key = va_arg(ap, char *)) && (value = va_arg(ap, char *)))
	{
		[newMap addData:key length:(int)strlen(key) value:value];
	}

	return newMap;
}

- (instancetype)init
{
	return [self initWithState:'\0'];
}

- (instancetype)initWithState:(char)state
{
	self = [super init];
	if (self)
	{
		_state = state;
	}
	return self;
}

- (void)addData:(char *)data length:(int)length value:(char *)value
{
	// look for the child
	BGRTTrie *child = self.children;
	while (child)
	{
		if (child.state == *data)
		{
			break;
		}
		child = child.sibling;
	}

	// if the child doesn't exist add it
	if (!child)
	{
		child = [[BGRTTrie alloc] initWithState:*data];
		child.sibling = self.children;
		self.children = child;
	}

	if (length == 1)
	{
		child.value = value;
	}
	else
	{
		// oh, tail recursion... how I wish you existed in C.
		[child addData:data+1 length:length-1 value:value];
	}
}

- (char *)getData:(char *)data length:(int)length
{
	BGRTTrie *child = self;

	// look for the child
	while (length > 0)
	{
		child = child.children;
		while (child)
		{
			if (child.state == *data)
			{
				break;
			}
			child = child.sibling;
		}
		if (!child)
		{
			return NULL;
		}

		length--;
		data++;
	}

	return child.value;
}

@end
