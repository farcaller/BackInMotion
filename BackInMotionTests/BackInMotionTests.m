//
//  BackInMotionTests.m
//  BackInMotionTests
//
//  Created by farcaller on 8/15/12.
//  Copyright (c) 2012 Hack&Dev. All rights reserved.
//

#import "BackInMotionTests.h"
#import "BackInMotion.h"

@implementation BackInMotionTests

+ (void)initialize
{
	void RubyMotionInit(int, char **);
	static char **argv = NULL;
	RubyMotionInit(0, argv);
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
	Class Hello = [BackInMotion const_get:@"Hello"];
	STAssertNotNil(Hello, @"Hello class is nil");
	id helloObj = [Hello new:@"test"];
	STAssertNotNil(helloObj, @"Hello obj is nil");
}

@end
