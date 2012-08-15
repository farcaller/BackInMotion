//
//  BackInMotionTests.m
//  BackInMotionTests
//
//  Created by farcaller on 8/15/12.
//  Copyright (c) 2012 Hack&Dev. All rights reserved.
//

#import "Kiwi.h"
#import "BackInMotion.h"

#define RBPTR(V) theValue((int)V)
#define RBSTR2NSSTR(S) ([NSString stringWithString:[S __rubyObject]])

@interface NSObject ()
+new:arg0;
-to_s;
-__rubyObject;
-name;
@end


SPEC_BEGIN(BackInMotionSpec)

describe(@"RubyMotion", ^{
	describe(@"BackInMotion", ^{
		it(@"fetches a constant from Object namespace", ^{
			Class Hello = [BackInMotion const_get:@"Hello"];
			[[RBPTR(Hello) shouldNot] equal: @0];
		});
	});
	
	describe(@"RubyObjectProxy", ^{
		Class Hello = [BackInMotion const_get:@"Hello"];
		
		it(@"calls ruby methods", ^{
			id obj = [Hello new:@"test"];
			[[RBPTR(obj) shouldNot] equal: @0];
		});
		
		it(@"calls ruby methods and returns values", ^{
			id obj = [[Hello new:@"test"] string];
			[[RBSTR2NSSTR(obj) should] equal:@"test"];
		});
		
		it(@"traverses through modules", ^{
			Class m1Same = [[BackInMotion const_get:@"M1"] const_get:@"Same"];
			[[RBPTR(m1Same) shouldNot] equal:@0];
			[[RBSTR2NSSTR([m1Same name]) should] equal:@"M1 Same"];
			
			Class m2Same = [[BackInMotion const_get:@"M2"] const_get:@"Same"];
			[[RBPTR(m2Same) shouldNot] equal:@0];
			[[RBSTR2NSSTR([m2Same name]) should] equal:@"M2 Same"];
			
			Class m3Same = [[BackInMotion const_get:@"M3"] const_get:@"Same"];
			[[RBPTR(m3Same) shouldNot] equal:@0];
			[[RBSTR2NSSTR([m3Same name]) should] equal:@"M3 Same"];
		});
	});
});

SPEC_END