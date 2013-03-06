//
//  main.m
//  Bogart
//	

#import <Foundation/Foundation.h>
#import "Bogart.h"

Bogart {
	get("/get") {
		BGRTParameter foo = param("foo");
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
		BGRTParameter foo = postParam("foo");
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
		BGRTParameter foo = param("foo");
		if (foo)
		{
			render("Testing rendering %{input}\n", map("input", foo));
		}
		else
		{
			body("No input\n");
		}
	};
	get("/create") {
		BGRTParameter name = param("name");
		BGRTParameter identifier =  param("id");
		if (name && identifier)
		{
			[bogart redisCommand:_redisContext handler:^(redisReply *reply) {
				if (reply)
				{
					body("User created.\n");
					status(201);
				}
				else
				{
					body("Error creating user: %s.\n", _redisContext->errstr);
				}
			} format:"HSET User:%s %s %s", identifier, "name", name];
		}
		else
		{
			body("Invalid input.\n");
		}
	};
	get("/show") {
		BGRTParameter identifier =  param("id");
		if (identifier)
		{
			[bogart redisCommand:_redisContext handler:^(redisReply *reply) {
				if (reply && reply->type == REDIS_REPLY_STRING)
				{
					NSCParameterAssert(reply->str);
					render("<name>%{name}</name>\n", map("name", reply->str));
				}
				else
				{
					if (reply->type == REDIS_REPLY_NIL)
					{
						body("No user exists with identifier %s.\n", identifier);
					}
					else
					{
						body("Error fetching user with identifier %s: %s.\n", identifier, _redisContext->errstr);
					}
				}
			} format:"HGET User:%s %s", identifier, "name"];
		}
	};
	start(10000);
}

