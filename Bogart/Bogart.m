//
//  Bogart.m
//  Bogart
//	

#import "Bogart.h"
#include <evhttp.h>

@interface BogartServer ()
@property (nonatomic) uint16_t port;
@property (copy, nonatomic) void (^init_func)(void);
@property (copy, nonatomic) Handler not_found;
@property (strong, nonatomic) Route *route;
- (Route *)matchRoute:(Route *)route request:(Request *)request;
@end

#define BOGART_NOT_FOUND_DEFAULT ^ void (Request * request, Response * response) { status(404); body("404 Not Found\n"); }

void request_handler(struct evhttp_request *ev_req, void *context)
{
	struct timeval t0, t1, tr;

	BogartServer *bogart = (__bridge BogartServer *)context;

	gettimeofday(&t0, NULL);

	Request *request = [[Request alloc] initWithRequest:ev_req];
	Response *response = [Response new];

	Route *matched_route = [bogart matchRoute:bogart.route request:request];

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
	printf("Request processed in: %ld secs, %d usecs\n", tr.tv_sec, tr.tv_usec);
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

- (Route *)nextRoute:(const char *)pattern type:(enum evhttp_cmd_type)type
{
	Route *new_route = [Route new];
	new_route.pattern = pattern;
	new_route.type = type;
	if (self.route)
	{
		Route *cursor = self.route;
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

- (Route *)matchRoute:(Route *)route request:(Request *)request
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

- (Route *)get:(const char *)pattern
{
	return [self nextRoute:pattern type:EVHTTP_REQ_GET];
}

- (Route *)post:(const char *)pattern
{
	return [self nextRoute:pattern type:EVHTTP_REQ_POST];
}

@end
