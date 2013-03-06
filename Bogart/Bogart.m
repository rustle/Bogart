//
//  Bogart.m
//  Bogart
//	

#import "Bogart.h"
#include <evhttp.h>
#import "GRMustache.h"

@interface BogartServer ()
@property (nonatomic) uint16_t port;
@property (copy, nonatomic) void (^init_func)(void);
@property (copy, nonatomic) RouteHandler not_found;
@property (strong, nonatomic) BGRTRoute *route;
- (BGRTRoute *)matchRoute:(BGRTRoute *)route request:(BGRTRequest *)request;
@end

#define BOGART_NOT_FOUND_DEFAULT ^ void (BGRTRequest * request, BGRTResponse * response) { status(404); body("404 Not Found\n"); }

void request_handler(struct evhttp_request *ev_req, void *context)
{
	struct timeval t0, t1, tr;

	BogartServer *bogart = (__bridge BogartServer *)context;

	gettimeofday(&t0, NULL);

	BGRTRequest *request = [[BGRTRequest alloc] initWithBGRTRequest:ev_req];
	BGRTResponse *response = [BGRTResponse new];

	BGRTRoute *matched_route = [bogart matchRoute:bogart.route request:request];

	if (matched_route)
	{
		matched_route.handler(request, response);
	}
	else
	{
		bogart.not_found(request, response);
	}
	
	evhttp_send_reply(ev_req, response.code, [response codeDescription], response.buffer);

	gettimeofday(&t1, NULL);
	timersub(&t1, &t0, &tr);
	printf("BGRTRequest processed in: %ld secs, %d usecs\n", tr.tv_sec, tr.tv_usec);
}

@implementation BogartServer

- (void)setupBogart
{
	self.not_found = BOGART_NOT_FOUND_DEFAULT;
}

- (void)startBogart:(uint16_t)port
{
	self.port = port;
	
	[self setupBogart];
	
	struct event_base * base = event_init();
	struct evhttp * http = evhttp_new(base);
	evhttp_bind_socket(http, "0.0.0.0", self.port);
	void * voidSelf = (__bridge void *)self;
	evhttp_set_gencb(http, request_handler, voidSelf);
	
	NSLog(@"Bogart's ready on port %u...", self.port);
	
	event_base_loop(base, 0);
	
	evhttp_free(http);
}

- (BGRTRoute *)nextRoute:(const char *)pattern type:(enum evhttp_cmd_type)type
{
	BGRTRoute *new_route = [BGRTRoute new];
	new_route.pattern = pattern;
	new_route.type = type;
	if (self.route)
	{
		BGRTRoute *cursor = self.route;
		while (cursor.next)
		{
			cursor = cursor.next;
		}
		cursor.next = new_route;
	}
	else
	{
		self.route = new_route;
	}
	return new_route;
}

- (bool)matchURI:(const char *)pattern uri:(const char *)uri
{
	while (*pattern && *uri)
	{
		if (*pattern == *uri)
		{
			pattern++;
			uri++;
		}
		else if (*pattern == '*')
		{
			if (*uri == '/' || !*(uri + 1))
			{
				pattern++;
			}
			else
			{
				uri++;
			}
		}
		else
		{
			return false;
		}
	}
	return (!*pattern && !*uri) || (!*pattern && *uri);
}

- (BGRTRoute *)matchRoute:(BGRTRoute *)route request:(BGRTRequest *)request
{
	while(route) 
	{
		if (request.ev_req->type == route.type && [self matchURI:route.pattern uri:request.ev_req->uri])
		{
			return route;
		}
		route = route.next;
	} 
	return NULL;
}

- (BGRTRoute *)get:(const char *)pattern
{
	return [self nextRoute:pattern type:EVHTTP_REQ_GET];
}

- (BGRTRoute *)post:(const char *)pattern
{
	return [self nextRoute:pattern type:EVHTTP_REQ_POST];
}

- (void)renderText:(BGRTResponse *)response renderTemplate:(NSString *)renderTemplate args:(NSDictionary *)args
{
	NSString *templatedString = [GRMustacheTemplate renderObject:args fromString:renderTemplate error:nil];
	const char *string = [templatedString UTF8String];
	evbuffer_add(response.buffer, string, strlen(string));
}

- (void)redisCommand:(redisContext *)context handler:(RedisHandler)handler format:(const char *)format, ...
{
	NSParameterAssert(context);
	NSParameterAssert(handler);
	va_list ap;
    va_start(ap, format);
	redisReply *reply = redisvCommand(context, format, ap);
	va_end(ap);
	handler(reply);
	freeReplyObject(reply);
}

@end

@implementation NSDictionary (BGRT)

+ (NSDictionary *)bgrtDictionaryWithCStrings:(char *)strings, ...
{
	va_list ap;
	NSUInteger count;
	
	va_start(ap, strings);
	count = 1;
	while(va_arg(ap, char *) != nil)
	{
		count++;
	}
	va_end(ap);
	
	if ((count % 2) != 0)
	{
		@throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
		return nil;
	}
	
	if (count < 2)
	{
		@throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
		return nil;
	}
	
	va_start(ap, strings);
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:count/2];
	dictionary[[NSString stringWithCString:strings encoding:NSUTF8StringEncoding]] = [NSString stringWithCString:va_arg(ap, char *) encoding:NSUTF8StringEncoding];
	
	for (NSUInteger i = 1; i < count/2; i++)
	{
		dictionary[[NSString stringWithCString:va_arg(ap, char *) encoding:NSUTF8StringEncoding]] = [NSString stringWithCString:va_arg(ap, char *) encoding:NSUTF8StringEncoding];
	}
	va_end(ap);
	
	return [dictionary copy];
}

@end
