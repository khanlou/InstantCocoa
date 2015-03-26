//
//  ICPaginatedDataSource.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/5/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICAsyncTestCase.h"

#import "ICPaginatedDataSource.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "ICRemoteConfiguration.h"
#import <OCMock/OCMock.h>
#import "NSArray+Convenience.h"
#import "ICTestServiceConfiguration.h"

@interface ICPaginatedDataSourceTests : ICAsyncTestCase

@end

@implementation ICPaginatedDataSourceTests

- (void)setUp
{
    [super setUp];
    
    NSArray *pageOneLinks = @[
                              @{@"name": @"first link",
                                @"link": @"http://amazon.com",},
                              @{@"name": @"first link",
                                @"link": @"http://apple.com",},
                              ];
    NSArray *pageTwoLinks = @[
                              @{@"name": @"first link",
                                @"link": @"http://facebook.com",},
                              @{@"name": @"first link",
                                @"link": @"http://twitter.com",},
                              ];
    
    NSArray *pages = @[pageOneLinks, pageTwoLinks, @[]];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"testservice.com"] && [request.URL.path isEqualToString:@"/links"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        
        NSInteger pageNumber = 1;
        NSArray *parameters = [request.URL.query componentsSeparatedByString:@"&"];
        for (NSString *parameter in parameters) {
            NSArray *components = [parameter componentsSeparatedByString:@"="];
            if ([components[0] isEqualToString:@"page"]) {
                pageNumber = [components[1] integerValue];
            }
        }
        
        NSDictionary *responseDictionary = @{@"page": @(pageNumber),
                                             @"per_page": @(pageOneLinks.count),
                                             @"number_of_pages": @(pages.count),
                                             @"number_of_total_objects": @([pages flattenedArray].count),
                                             @"links": pages[pageNumber-1],
                                             };
        
        
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDictionary options:0 error:nil];
        return [OHHTTPStubsResponse responseWithData:responseData
                                          statusCode:200
                                             headers:@{@"Content-Type":@"text/json"}];
        
    }];
    
    
    
    [ICRemoteConfiguration setDefaultConfiguration:[ICTestServiceConfiguration new]];
}

- (void)testPaginatedRemoteDataSource
{
    [self reset];
    OCMockObject<ICDataSourceDelegate> *mockDelegate = [OCMockObject niceMockForProtocol:@protocol(ICDataSourceDelegate)];
    
    ICPaginatedDataSource *paginatedDataSource = [[ICPaginatedDataSource alloc] init];
    paginatedDataSource.keys.pageSize = @"per_page";
    paginatedDataSource.keys.numberOfPages = @"number_of_pages";
    paginatedDataSource.keys.numberOfTotalObjects = @"number_of_total_objects";
    paginatedDataSource.keys.currentPage = @"page";
    
    paginatedDataSource.keyPath = @"links";
    paginatedDataSource.apiPath = @"links";
    paginatedDataSource.delegate = mockDelegate;
    
    [[[mockDelegate expect]
      andDo:^(NSInvocation *invocation) { [self complete]; }]
     dataSourceFinishedLoading:paginatedDataSource];
    
    [[[mockDelegate reject]
      andDo:^(NSInvocation *invocation) { [self complete]; }]
     dataSource:paginatedDataSource failedWithError:[OCMArg any]];
    
    [paginatedDataSource fetchData];
    
    [self waitForCompletion];
    
    [mockDelegate verify];
    
    XCTAssert([paginatedDataSource numberOfSections] == 1, @"Paginated data source should return 1 section");
    XCTAssert([paginatedDataSource numberOfObjectsInSection:0] == 2 + 1, @"Paginated data source should return two objects and one loading indicator");
    
    XCTAssert([[paginatedDataSource objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] isKindOfClass:[NSDictionary class]], @"Returned objects should be dictionaries.");

    
    
    //now get the second page
    [[[mockDelegate expect]
      andDo:^(NSInvocation *invocation) { [self complete]; }]
     dataSourceFinishedLoading:paginatedDataSource];
    
    [[[mockDelegate reject]
      andDo:^(NSInvocation *invocation) { [self complete]; }]
     dataSource:paginatedDataSource failedWithError:[OCMArg any]];
    
    [paginatedDataSource fetchNextPage];
    
    [self waitForCompletion];
    
    [mockDelegate verify];

    XCTAssert([paginatedDataSource numberOfSections] == 1, @"Paginated data source should return 1 section");
    XCTAssert([paginatedDataSource numberOfObjectsInSection:0] == 4 + 1, @"Paginated data source should return four objects and one loading indicator");
    
    XCTAssert([[paginatedDataSource objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] isKindOfClass:[NSDictionary class]], @"Returned objects should be dictionaries.");
    
    
    //now attempt to get the third page
    [[[mockDelegate expect]
      andDo:^(NSInvocation *invocation) { [self complete]; }]
     dataSourceFinishedLoading:paginatedDataSource];
    
    [[[mockDelegate reject]
      andDo:^(NSInvocation *invocation) { [self complete]; }]
     dataSource:paginatedDataSource failedWithError:[OCMArg any]];
    
    [paginatedDataSource fetchNextPage];
    
    [self waitForCompletion];
    
    [mockDelegate verify];
    
    XCTAssert([paginatedDataSource numberOfSections] == 1, @"Paginated data source should return 1 section");
    XCTAssert([paginatedDataSource numberOfObjectsInSection:0] == 4, @"Paginated data source should return four objects and no loading indicator");
    
    XCTAssert([[paginatedDataSource objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] isKindOfClass:[NSDictionary class]], @"Returned objects should be dictionaries.");

}

@end
