//
//  ICCollectionFetcherTests.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 9/6/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ICAsyncTestCase.h"
#import <OHHTTPStubs.h>
#import "ICTestServiceConfiguration.h"
#import "ICCollectionFetcher.h"
#import <NSArray+FunctionalMethods.h>
#import "ICLink.h"

@interface ICCollectionFetcherTests : ICAsyncTestCase

@end

@implementation ICCollectionFetcherTests

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

- (void)testSimpleCollectionFetcher {
    [self reset];
    
    ICCollectionFetcher *collectionFetcher = [[ICCollectionFetcher alloc] init];
    collectionFetcher.apiPath = @"links";
    
    
    [collectionFetcher fetchCollectionWithSuccessBlock:^(NSArray *objects) {
        XCTAssert(objects.count == 4, @"Fetching a collection should return the number of objects in the collection.");
        XCTAssertTrue([objects allObjectsPassTest:^BOOL(id object) { return [object isKindOfClass:[NSDictionary class]]; }], @"all objects in the collection fetcher should not be mapped");
        [self complete];
    } failureBlock:^(NSError *error) {
        XCTFail(@"A collection fetcher with a valid url should not be entered");
    }];
    
    [self waitForCompletion];
}


- (void)testMappedCollectionFetcherWithKeyPath {
    [self reset];
    
    ICCollectionFetcher *collectionFetcher = [[ICCollectionFetcher alloc] init];
    collectionFetcher.apiPath = @"keyed_links";
    collectionFetcher.keyPath = @"links";
    collectionFetcher.mappingClass = [ICLink class];
    
    [collectionFetcher fetchCollectionWithSuccessBlock:^(NSArray *objects) {
        XCTAssert(objects.count == 4, @"Fetching a collection should return the number of objects in the collection.");
        XCTAssertTrue([objects allObjectsPassTest:^BOOL(id object) { return [object isKindOfClass:[ICLink class]]; }], @"All objects in the collection fetcher should be mapped to ICLinks");
        [self complete];
    } failureBlock:^(NSError *error) {
        XCTFail(@"A collection fetcher with a valid url should not be entered");
    }];
    
    [self waitForCompletion];
}

@end
