//
//  BGRTRoute.h
//  Bogart
//	

#import <Foundation/Foundation.h>
#import "BGRTRequest.h"
#import "BGRTResponse.h"
#include <evhttp.h>

typedef void (^RouteHandler)(BGRTRequest *, BGRTResponse *);

@interface BGRTRoute : NSObject

@property (nonatomic) enum evhttp_cmd_type type;
@property (nonatomic) const char *pattern;
@property (copy, nonatomic) RouteHandler handler;
@property (strong, nonatomic) BGRTRoute *next;

@end
