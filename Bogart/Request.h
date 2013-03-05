//
//  Request.h
//  Bogart
//	

#import <Foundation/Foundation.h>

@interface Request : NSObject

@property (nonatomic, readonly) const char *uri;
@property (nonatomic, readonly) struct evhttp_request *ev_req;

- (instancetype)initWithRequest:(struct evhttp_request *)ev_req;
- (const char *)getParamWithKey:(const char *)key;
- (const char *)getPostParamWithKey:(const char *)key;

@end
