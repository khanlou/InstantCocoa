//
//  ICRemoteConfigurationTests.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 9/9/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICRemoteConfiguration.h"
#import <AFNetworking.h>
#import <XCTest/XCTest.h>

@interface ICTestingConfiguration : ICRemoteConfiguration

@end

@implementation ICTestingConfiguration

- (NSString *)baseURLString {
    return @"http://testservice.com";
}

- (NSTimeInterval)timeoutInterval {
    return 47;
}

- (NSURLRequestCachePolicy)cachePolicy {
    return NSURLRequestReloadIgnoringLocalCacheData;
}

- (NSDictionary *)additionalHTTPHeaders {
    return @{ @"X-Custom-HTTP-Header": @"shibboleth" };
}

@end

@interface ICRemoteConfigurationTests : XCTestCase

@end

@implementation ICRemoteConfigurationTests

- (void)testDefaultConfigurationThrowsException {
    ICRemoteConfiguration *remoteConfiguration = [ICRemoteConfiguration new];
    XCTAssertThrows(remoteConfiguration.requestManager, @"A default remote configuration should throw an error when trying to access its baseURLString.");
}

- (void)testRequestManager {
    ICTestingConfiguration *testingConfiguration = [ICTestingConfiguration new];
    AFHTTPRequestOperationManager *manager = testingConfiguration.requestManager;
    XCTAssertEqualObjects(manager.baseURL.absoluteString, @"http://testservice.com", @"");
    XCTAssertEqual(manager.requestSerializer.cachePolicy, NSURLRequestReloadIgnoringLocalCacheData, @"");
    XCTAssertEqual(manager.requestSerializer.timeoutInterval, 47, @"");
    
    NSDictionary *headers = manager.requestSerializer.HTTPRequestHeaders;
    XCTAssertEqualObjects(headers[@"Content-Type"], @"application/json", @"");
    XCTAssertEqualObjects(headers[@"Accept"], @"application/json", @"");
    XCTAssertEqualObjects(headers[@"X-Custom-HTTP-Header"], @"shibboleth", @"");
}

@end
