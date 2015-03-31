//
//  ICRouterTests.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/31/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ICRoute.h"
#import "ICRouter.h"
#import "NSString+PathNormalization.h"

@interface ICRouteTests : XCTestCase

@end

@implementation ICRouteTests

- (void) testPathNormalization {
    
    NSLog(@"norm %@", [@"path" normalizedPath]);
    
    XCTAssertEqualObjects([@"path" normalizedPath], @"/path/", @"Path normalization should work with no leading or trailing slashes");
    XCTAssertEqualObjects([@"/path" normalizedPath], @"/path/", @"Path normalization should work with a leading slash but no trailing slash");
    XCTAssertEqualObjects([@"path/" normalizedPath], @"/path/", @"Path normalization should work with a trailing slash but no leading slash");
    XCTAssertEqualObjects([@"/path/" normalizedPath], @"/path/", @"Path normalization should work with a trailing slash but no leading slash");

    XCTAssertEqualObjects([@"path/multipart" normalizedPath], @"/path/multipart/", @"Path normalization should work with no leading or trailing slashes");
    XCTAssertEqualObjects([@"/path/multipart" normalizedPath], @"/path/multipart/", @"Path normalization should work with a leading slash but no trailing slash");
    XCTAssertEqualObjects([@"path/multipart/" normalizedPath], @"/path/multipart/", @"Path normalization should work with a trailing slash but no leading slash");
    XCTAssertEqualObjects([@"/path/multipart/" normalizedPath], @"/path/multipart/", @"Path normalization should work with a trailing slash but no leading slash");
}

- (void)testBasicRouting {
    ICRoute *forumListRoute = [ICRoute routeWithPath:@"/forums"];
    
    XCTAssertTrue([forumListRoute canHandlePath:@"/forums"], @"A properly spelled route should be handled");
    XCTAssertFalse([forumListRoute canHandlePath:@"/forum"], @"A differently spelled route should not be handled");
    XCTAssertFalse([forumListRoute canHandlePath:@"/forums/10"], @"A path with too many components should not be handled");
}

- (void)testParameterRouting {
    ICRoute *specificForumRoute = [ICRoute routeWithPath:@"/forums/{id}"];
    
    XCTAssertFalse([specificForumRoute canHandlePath:@"/forums"], @"A route with too few components should not work");
    XCTAssertFalse([specificForumRoute canHandlePath:@"/forum"], @"A route with too few components should not work");
    XCTAssertTrue([specificForumRoute canHandlePath:@"/forums/10"], @"A route with with one parameter should work");
    XCTAssertTrue([specificForumRoute canHandlePath:@"/forums/10/posts/35"], @"A route with too many components should not work");
}

- (void)testMultipleParameterRouting {
    ICRoute *specificPostRoute = [ICRoute routeWithPath:@"/forums/{forum_id}/post/{post_id}"];
    
    XCTAssertFalse([specificPostRoute canHandlePath:@"/forums"], @"A route with too few components should not work");
    XCTAssertFalse([specificPostRoute canHandlePath:@"/forum/"], @"A route with too few components should not work");
    XCTAssertFalse([specificPostRoute canHandlePath:@"/forums/10"], @"A route with too few components should not work");
    XCTAssertTrue([specificPostRoute canHandlePath:@"/forums/10/post/35/"], @"A route with with two parameters should work");
}

- (void) testTrailingSlashes {
    ICRoute *specificPostRoute = [ICRoute routeWithPath:@"/forums/{forum_id}/post/{post_id}/"];
    
    XCTAssertTrue([specificPostRoute canHandlePath:@"/forums/10/post/35/"], @"A route with leading and trailing slashes should be handled");
    XCTAssertTrue([specificPostRoute canHandlePath:@"/forums/10/post/35"], @"A route with only a leading slash should be handled");
    XCTAssertTrue([specificPostRoute canHandlePath:@"forums/10/post/35"], @"A route with neither a leading or trailing slash should be handled");
}

- (void)testParameterExtraction {
    ICRoute *specificPostRoute = [ICRoute routeWithPath:@"/forums/{forum_id}/post/{post_id}"];
    
    NSDictionary *numberParameters = [specificPostRoute parametersForPath:@"/forums/10/post/35"];
    
    XCTAssertEqualObjects(numberParameters[@"forum_id"], @10, @"Extracting number parameters from a route should work");
    XCTAssertEqualObjects(numberParameters[@"post_id"], @35, @"Extracting number parameters from a route should work");
    
    NSDictionary *stringParameters = [specificPostRoute parametersForPath:@"/forums/kias/post/a_post_name"];
    
    XCTAssertEqualObjects(stringParameters[@"forum_id"], @"kias", @"Extracting string parameters from a route should work");
    XCTAssertEqualObjects(stringParameters[@"post_id"], @"a_post_name", @"Extracting string parameters from a route should work");
}

@end
