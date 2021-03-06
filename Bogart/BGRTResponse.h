//
//  BGRTResponse.h
//  Bogart
//	

#import <Foundation/Foundation.h>

@interface BGRTResponse : NSObject

@property (nonatomic) int code;
@property (nonatomic, readonly) struct evbuffer *buffer;

- (void)setBodyWithPattern:(const char *)pattern, ...;

- (const char *)codeDescription;

@end
