//
//  Bogart.h
//  Bogart
//	

#import <Foundation/Foundation.h>
#import "Request.h"
#import "Response.h"
#import "Route.h"
#import <evhttp.h>
#import <hiredis/hiredis.h>

#define Bogart \
int main(int argc, const char * argv[]) \
{ \
	@autoreleasepool { \
		useRedis; \
		BogartServer *bogart = [BogartServer new];

#define start(port) \
		[bogart startBogart:port]; \
		cleanupRedis \
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

#define useRedis \
	redisContext *_redisContext; \
	_redisContext = redisConnect("127.0.0.1", 6379);

#define cleanupRedis \
	redisFree(_redisContext);

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
