//
//  main.m
//  Bogart
//	

#import <Foundation/Foundation.h>
#import "Bogart.h"

Bogart {
	get("/get") {
		const char * foo = param("foo");
		if (foo)
		{
			body("<h1>Get with parameter: </h1><p>%s</p>", foo);
		}
		else
		{
			body("<h1>Get</h1>");
		}
	};
	post("/post") {
		const char * foo = postParam("foo");
		if (foo)
		{
			body("Post with parameter: %s\n", foo);
			status(201);
		}
		else
		{
			body("Post\n");
		}
	};
	start(10000);
}

