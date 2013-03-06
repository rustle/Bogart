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
@property (nonatomic) NSData *postData;
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
			NSMutableData *data = [[NSMutableData alloc] initWithCapacity:length + 1];
			[data setLength:length + 1];
			char * buffer = [data mutableBytes];
			evbuffer_copyout(_ev_req->input_buffer, buffer, length);
			buffer[length] = 0;
			_postData = [data copy];
		}
	}
	return self;
}

- (void)dealloc
{
	free(_params);
}

- (NSString *)getParamWithKey:(NSString *)key
{
	NSParameterAssert(self.params);
	const char * param = evhttp_find_header(self.params, [key UTF8String]);
	if (param == NULL)
	{
		return nil;
	}
	return [NSString stringWithCString:param encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)postParameters
{
	if (_postParameters)
	{
		return _postParameters;
	}
	if (self.postData == nil)
	{
		return nil;
	}
	NSString *postString = [[NSString alloc] initWithData:self.postData encoding:NSUTF8StringEncoding];
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
	return _postParameters;
}

- (NSString *)getPostParamWithKey:(NSString *)key
{
	if (key == NULL)
	{
		return NULL;
	}
	NSDictionary *postParameters = self.postParameters;
	if (postParameters == nil)
	{
		return NULL;
	}
	return postParameters[key];
}

@end
