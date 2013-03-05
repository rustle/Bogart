//
//  Response.m
//  Bogart
//	

#import "Response.h"
#import <event.h>

@interface Response ()
@property (nonatomic) struct evbuffer *buffer;
@end

@implementation Response

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_code = 200;
		_buffer = evbuffer_new();
	}
	return self;
}

- (void)dealloc
{
	evbuffer_free(_buffer);
}

- (void)setBodyWithPattern:(const char *)pattern, ...
{
	va_list ap;
    va_start(ap, pattern);
    evbuffer_add_vprintf(self.buffer, pattern, ap);
	va_end(ap);
}

- (const char *)codeDescription
{
	switch (self.code) {
		case 200:
			return "OK";
		case 201:
			return "Created";
		case 404:
			return "Not Found";
		default:
			return "Unknown";
	}
}

@end
