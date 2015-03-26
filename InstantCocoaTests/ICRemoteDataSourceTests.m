//
//  ICRemoteDataSourceTests.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/5/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//


#import "ICAsyncTestCase.h"
#import "ICRemoteDataSource.h"
#import "ICTestServiceConfiguration.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OCMock/OCMock.h>
#import "ICLink.h"

@interface ICRemoteDataSourceTests : ICAsyncTestCase

@end

@implementation ICRemoteDataSourceTests

- (void)setUp
{
    [super setUp];
    
    NSArray *listOfLinks = @[
                             @{@"name": @"first link",
                               @"link": @"http://amazon.com",
                               @"category": @"retail",},
                             @{@"name": @"first link",
                               @"link": @"http://apple.com",
                               @"category": @"retail",},
                             @{@"name": @"first link",
                               @"link": @"http://facebook.com",
                               @"category": @"social",},
                             @{@"name": @"first link",
                               @"link": @"http://twitter.com",
                               @"category": @"social",},
                             ];
    NSDictionary *keyedResponse = @{@"links": listOfLinks};

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"testservice.com"] && [request.URL.path isEqualToString:@"/links"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:listOfLinks options:0 error:nil];
        return [OHHTTPStubsResponse responseWithData:responseData
                                          statusCode:200
                                             headers:@{@"Content-Type":@"text/json"}];

    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"testservice.com"] && [request.URL.path isEqualToString:@"/keyed_links"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:keyedResponse options:0 error:nil];
        return [OHHTTPStubsResponse responseWithData:responseData
                                          statusCode:200
                                             headers:@{@"Content-Type":@"text/json"}];
    }];
    
    [ICRemoteConfiguration setDefaultConfiguration:[ICTestServiceConfiguration new]];
}

- (void)testSimpleRemoteDataSource
{
    [self reset];
    OCMockObject<ICDataSourceDelegate> *mockDelegate = [OCMockObject niceMockForProtocol:@protocol(ICDataSourceDelegate)];
    
    ICRemoteDataSource *remoteDataSource = [[ICRemoteDataSource alloc] init];
    remoteDataSource.apiPath = @"links";
    remoteDataSource.delegate = mockDelegate;
    
    [[[mockDelegate expect]
      andDo:^(NSInvocation *invocation) {
          [self complete];
      }]
     dataSourceFinishedLoading:remoteDataSource];
    
    [[[mockDelegate reject]
      andDo:^(NSInvocation *invocation) {
          [self complete];
      }]
     dataSource:remoteDataSource failedWithError:[OCMArg any]];
    
    [remoteDataSource fetchData];
    
    [self waitForCompletion];
    
    [mockDelegate verify];
    
    XCTAssert([remoteDataSource numberOfSections] == 1, @"Remote data sources should be able to fetch one section of objects");
    XCTAssert([remoteDataSource numberOfObjectsInSection:0] == 4, @"Remote data sources should fetch all the objects from the remote server");
    
    XCTAssert([[remoteDataSource objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] isKindOfClass:[NSDictionary class]], @"Returned objects should be NSDictionaries");
    
}

- (void)testMappingWithKeypath {
    [self reset];
    OCMockObject<ICDataSourceDelegate> *mockDelegate = [OCMockObject niceMockForProtocol:@protocol(ICDataSourceDelegate)];
    
    ICRemoteDataSource *remoteDataSource = [[ICRemoteDataSource alloc] init];
    remoteDataSource.apiPath = @"keyed_links";
    remoteDataSource.keyPath = @"links";
    remoteDataSource.delegate = mockDelegate;
    remoteDataSource.mappingClass = [ICLink class];
    
    [[[mockDelegate expect]
      andDo:^(NSInvocation *invocation) {
          [self complete];
      }]
     dataSourceFinishedLoading:remoteDataSource];
    
    [[[mockDelegate reject]
      andDo:^(NSInvocation *invocation) {
          [self complete];
      }]
     dataSource:remoteDataSource failedWithError:[OCMArg any]];
    
    [remoteDataSource fetchData];
    
    [self waitForCompletion];
    
    [mockDelegate verify];
    
    XCTAssert([remoteDataSource numberOfSections] == 1, @"Remote data sources should be able to fetch one section of objects");
    XCTAssert([remoteDataSource numberOfObjectsInSection:0] == 4, @"Remote data sources should fetch all the objects from the remote server");
    
    XCTAssert([[remoteDataSource objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] isKindOfClass:[ICLink class]], @"Returned objects should be of ICLink type");
}

@end
