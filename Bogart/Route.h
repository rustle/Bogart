//
//  Route.h
//  Bogart
//	

#import <Foundation/Foundation.h>
#import "Request.h"
#import "Response.h"
#include <evhttp.h>

typedef void (^Handler)(Request *, Response *);

@interface Route : NSObject

@property (nonatomic) enum evhttp_cmd_type type;
@property (nonatomic) const char *pattern;
@property (copy, nonatomic) Handler handler;
@property (strong, nonatomic) Route *next;

@end
