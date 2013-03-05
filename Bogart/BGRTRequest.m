//
//  BGRTRequest.m
//  Bogart
//	

#import "BGRTRequest.h"
#include <evhttp.h>

@interface BGRTRequest ()
@property (nonatomic) const char *uri;
@property (nonatomic) struct evkeyvalq *params;
@property (nonatomic) struct evhttp_request *ev_req;
@property (nonatomic) NSDictionary *postParameters;
@end

@implementation BGRTRequest

- (instancetype)initWithBGRTRequest:(struct evhttp_request *)ev_req
{
	self = [super init];
	if (self)
	{
		if (ev_req == NULL)
		{
			self = nil;
			return nil;
		}
		_ev_req = ev_req;
		_uri = evhttp_request_uri(ev_req);
		_params = (struct evkeyvalq *)malloc(sizeof(struct evkeyvalq));
		evhttp_parse_query(_uri, _params);
		if (_ev_req->input_buffer)
		{
			size_t length = evbuffer_get_length(_ev_req->input_buffer);
			char * buffer = malloc(length + 1);
			evbuffer_copyout(_ev_req->input_buffer, buffer, length);
			buffer[length] = 0;
			NSString *postString = [[NSString alloc] initWithBytesNoCopy:buffer length:length encoding:NSUTF8StringEncoding freeWhenDone:YES];
			NSArray *parameters = [postString componentsSeparatedByString:@"&"];
			NSMutableDictionary *parametersDictionary = [NSMutableDictionary new];
			for (NSString *parameter in parameters)
			{
				NSArray *splitParameter = [parameter componentsSeparatedByString:@"="];
				if ([splitParameter count] == 2)
				{
					parametersDictionary[[splitParameter[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] = [splitParameter[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				}
			}
			_postParameters = [parametersDictionary copy];
		}
	}
	return self;
}

- (void)dealloc
{
	free(_params);
}

- (BGRTParameter)getParamWithKey:(const char *)key
{
	NSParameterAssert(self.params);
	return evhttp_find_header(self.params, key);
}

- (BGRTParameter)getPostParamWithKey:(const char *)key
{
	NSString *keyString = [NSString stringWithCString:key encoding:NSUTF8StringEncoding];
	if (keyString)
	{
		return [self.postParameters[keyString] UTF8String];
	}
	return NULL;
}

@end
