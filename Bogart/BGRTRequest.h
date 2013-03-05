//
//  BGRTRequest.h
//  Bogart
//	

#import <Foundation/Foundation.h>

typedef const char * BGRTParameter;

@interface BGRTRequest : NSObject

@property (nonatomic, readonly) const char *uri;
@property (nonatomic, readonly) struct evhttp_request *ev_req;

- (instancetype)initWithBGRTRequest:(struct evhttp_request *)ev_req;
- (BGRTParameter)getParamWithKey:(const char *)key;
- (BGRTParameter)getPostParamWithKey:(const char *)key;

@end
