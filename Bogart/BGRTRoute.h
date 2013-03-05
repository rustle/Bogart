//
//  BGRTRoute.h
//  Bogart
//	

#import <Foundation/Foundation.h>
#import "BGRTRequest.h"
#import "BGRTResponse.h"
#include <evhttp.h>

typedef void (^Handler)(BGRTRequest *, BGRTResponse *);

@interface BGRTRoute : NSObject

@property (nonatomic) enum evhttp_cmd_type type;
@property (nonatomic) const char *pattern;
@property (copy, nonatomic) Handler handler;
@property (strong, nonatomic) BGRTRoute *next;

@end
