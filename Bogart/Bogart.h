//
//  Bogart.h
//  Bogart
//	

#import <Foundation/Foundation.h>
#import "Request.h"
#import "Response.h"
#import "Route.h"
#import <evhttp.h>

#define Bogart \
int main(int argc, const char * argv[]) \
{ \
	@autoreleasepool { \
		BogartServer *bogart = [BogartServer new];

#define start(port) \
		[bogart startBogart:port]; \
	} \
	} \
	return 0;

#define body(_pattern, ...) \
	[response setBodyWithPattern:_pattern, ##__VA_ARGS__]

#define param(_key) \
	[request getParamWithKey:_key]

#define postParam(_key) \
	[request getPostParamWithKey:_key]

#define status(_status) \
	response.code = _status;

@interface BogartServer : NSObject

- (void)startBogart:(uint16_t)port;
- (Route *)nextRoute:(const char *)pattern type:(enum evhttp_cmd_type)type;

@end

@interface BogartServer ()

#define get(_pattern) \
	[bogart get:_pattern].handler = ^ void (Request * request, Response * response) 
- (Route *)get:(const char *)pattern;

#define post(_pattern) \
	[bogart post:_pattern].handler = ^ void (Request * request, Response * response) 
- (Route *)post:(const char *)pattern;

@end
