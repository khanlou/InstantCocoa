//
//  ICAsyncTestCase.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/5/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//


#import "ICAsyncTestCase.h"

@implementation ICAsyncTestCase

- (void)setUp
{
    [super setUp];
    self.complete = NO;
}

- (void)complete {
    self.complete = YES;
}

- (void)reset {
    self.complete = NO;
}

- (void)waitForCompletion {
    [self reset];
	while (!_complete && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
		[NSThread sleepForTimeInterval:0.05];
	}
}

@end
