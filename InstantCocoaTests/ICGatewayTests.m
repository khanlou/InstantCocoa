//
//  ICGatewayTests.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 9/6/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ICAsyncTestCase.h"
#import "ICRemoteLink.h"
#import "ICResourceGateway.h"
#import <OHHTTPStubs.h>
#import "ICTestServiceConfiguration.h"

@interface ICGatewayTests : ICAsyncTestCase

@end

@implementation ICGatewayTests

- (void)setUp
{
    [super setUp];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"testservice.com"] && [request.URL.path isEqualToString:@"/remotelinks/3/test_action"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:@{@"upvoteCount": @2} options:0 error:nil];
        return [OHHTTPStubsResponse responseWithData:responseData
                                          statusCode:200
                                             headers:@{@"Content-Type":@"text/json"}];
        
    }];
    
    [ICRemoteConfiguration setDefaultConfiguration:[ICTestServiceConfiguration new]];
}

- (void)testSimpleGateway {
    ICRemoteLink *post = [ICRemoteLink new];
    post.objectID = @3;
    post.upvoteCount = 1;

    [post.gateway performAction:@"test_action"
                queryParameters:@{@"required_parameter": @"value"}
                   successBlock:^(id object) {
                       XCTAssert(post == object, @"The returned object should be the same as the object that was passed in");
                       XCTAssert(post.upvoteCount == 2, @"The default should be to map the new values from the API onto the source object");
                       [self complete];
                   }
                   failureBlock:^(id object, NSError *error) {
                       XCTFail(@"should not fail on an active action");
                       [self complete];
                   }];
    [self waitForCompletion];
}

- (void)testGatewayWithNoObjectUpdating {
    ICRemoteLink *post = [ICRemoteLink new];
    post.objectID = @3;
    post.upvoteCount = 1;
    
    post.gateway.updateObjectOnCompletion = NO;
    [post.gateway performAction:@"test_action"
                queryParameters:@{@"required_parameter": @"value"}
                   successBlock:^(id object) {
                       XCTAssert(post == object, @"The returned object should be the same as the object that was passed in");
                       XCTAssert(post.upvoteCount == 1, @"`updateObjectOnCompletion` should prevent mapping new values from the API onto the source object");
                       [self complete];
                   }
                   failureBlock:^(id object, NSError *error) {
                       XCTFail(@"should not fail on an active action");
                       [self complete];
                   }];
    [self waitForCompletion];
}


@end
