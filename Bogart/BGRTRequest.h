//
//  BGRTRequest.h
//  Bogart
//	

#import <Foundation/Foundation.h>

typedef const char * BGRTParameter;

@interface BGRTRequest : NSObject

@property (nonatomic, readonly) const char *uri;
@property (nonatomic, readonly) struct evhttp_request *ev_req;
@property (nonatomic, readonly) NSData *postData;

- (instancetype)initWithBGRTRequest:(struct evhttp_request *)ev_req;
- (NSString *)getParamWithKey:(NSString *)key;
- (NSString *)getPostParamWithKey:(NSString *)key;

@end
