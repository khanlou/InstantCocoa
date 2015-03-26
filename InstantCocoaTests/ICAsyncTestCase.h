//
//  ICAsyncTestCase.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/5/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface ICAsyncTestCase : XCTestCase

@property (nonatomic, assign, getter = isCompleted) BOOL complete;


- (void)complete;
- (void)reset;
- (void)waitForCompletion;

@end
