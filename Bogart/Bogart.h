//
//  Bogart.h
//  Bogart
//	

#import <Foundation/Foundation.h>

#import "BGRTRequest.h"
#import "BGRTResponse.h"
#import "BGRTRoute.h"
#import "BGRTTrie.h"

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
		cleanupRedis; \
	} \
	} \
	return 0;

#define body(_pattern, ...) \
	[response setBodyWithPattern:_pattern, ##__VA_ARGS__]

#define param(_key) \
	[[request getParamWithKey:@_key] UTF8String]

// Assumes a query string style post data that is url encoded
// ie foo=bar or foo=b%20ar
#define postParam(_key) \
	[[request getPostParamWithKey:@_key] UTF8String]

#define postData \
	[request postData]

#define status(_status) \
	response.code = _status

#define useRedis \
	redisContext *_redisContext; \
	_redisContext = redisConnect("127.0.0.1", 6379); \
	if (_redisContext && _redisContext->err != REDIS_OK) { NSLog(@"Redis Error: %s", _redisContext->errstr); }

#define cleanupRedis \
	redisFree(_redisContext)

#define map(...) \
	[BGRTTrie makeMap:NULL, __VA_ARGS__, NULL]

#define render(_template, _map) \
	[bogart renderText:response renderTemplate:_template args:_map]

typedef void (^RedisHandler)(redisReply *);

#define bgrtRedisHandler \
	[bogart redisCommand:_redisContext handler:^(redisReply *reply)

#define bgrtRedisFormat(args, ...) \
	format:args, __VA_ARGS__];

#define bgrtRedisReply reply
#define bgrtRedisReplyType reply->type
#define bgrtRedisReplyString reply->str
#define bgrtRedisContextError _redisContext->err
#define bgrtRedisContextErrorString _redisContext->errstr

@interface BogartServer : NSObject

- (void)startBogart:(uint16_t)port;
- (BGRTRoute *)nextRoute:(const char *)pattern type:(enum evhttp_cmd_type)type;
- (void)renderText:(BGRTResponse *)response renderTemplate:(char *)renderTemplate args:(BGRTTrie *)args;
- (void)redisCommand:(redisContext *)context handler:(RedisHandler)handler format:(const char *)format, ...;

@end

@interface BogartServer ()

#define get(_pattern) \
	[bogart get:_pattern].handler = ^ void (BGRTRequest * request, BGRTResponse * response) 
- (BGRTRoute *)get:(const char *)pattern;

#define post(_pattern) \
	[bogart post:_pattern].handler = ^ void (BGRTRequest * request, BGRTResponse * response) 
- (BGRTRoute *)post:(const char *)pattern;

@end
