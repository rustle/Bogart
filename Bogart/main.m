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
			body("<h1>Get with parameter: </h1><p>%s</p>\n", foo);
		}
		else
		{
			body("<h1>Get</h1>\n");
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
	get("/render") {
		const char * foo = param("foo");
		if (foo)
		{
			render("Testing rendering %{input}\n", map("input", foo));
		}
		else
		{
			body("No input\n");
		}
	};
	start(10000);
}

