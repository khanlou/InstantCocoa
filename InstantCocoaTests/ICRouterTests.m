//
//  ICRouter.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/4/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ICRoute.h"
#import "ICRouter.h"
#import <OCMock/OCMock.h>
#import "ICRoutedPostsViewController.h"


static NSString *ICSomeNavigationControllerKey = @"ICSomeNavigationControllerKey";

@interface ICRouterTests : XCTestCase

@property (nonatomic, strong) ICRoute *forumListRoute;
@property (nonatomic, strong) ICRoute *specificForumRoute;
@property (nonatomic, strong) ICRoute *specificPostRoute;

@end

@implementation ICRouterTests

- (void)setUp {
    [super setUp];
    
    self.forumListRoute = ({
        ICRoute *route = [ICRoute routeWithPath:@"/forums"];
        route.viewControllerClass = [ICRoutedPostsViewController class];
        route.navigationControllerKey = ICSomeNavigationControllerKey;
        [[ICRouter sharedRouter] registerRoute:route];
        route;
    });
    
    
    self.specificForumRoute = ({
        ICRoute *route = [ICRoute routeWithPath:@"/forums/{id}"];
        route.viewControllerClass = [ICRoutedPostsViewController class];
        route.navigationControllerKey = ICSomeNavigationControllerKey;
        [[ICRouter sharedRouter] registerRoute:route];
        route;
    });
    
    self.specificPostRoute = ({
        ICRoute *route = [ICRoute routeWithPath:@"/forums/{forum_id}/post/{post_id}"];
        route.viewControllerClass = [ICRoutedPostsViewController class];
        route.navigationControllerKey = ICSomeNavigationControllerKey;
        route.dependencies = @[_specificForumRoute];
        [[ICRouter sharedRouter] registerRoute:route];
        route;
    });
}

- (void) testRouting {
    
    OCMockObject<ICRouterDelegate> *routerDelegateMock = [OCMockObject mockForProtocol:@protocol(ICRouterDelegate)];
    [ICRouter sharedRouter].delegate = routerDelegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
    
    [[[routerDelegateMock stub] andReturn:navigationController] showViewControllerWithKey:ICSomeNavigationControllerKey];

    [[routerDelegateMock expect]
     presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:_forumListRoute.viewControllerClass]; }]
     forRoute:_forumListRoute
     fromViewController:navigationController];
    
    [[ICRouter sharedRouter] handleURL:[NSURL URLWithString:@"posts://forums"]];
    
    XCTAssertNoThrow([routerDelegateMock verify], @"A simple route with no arguments should work");
}

- (void) testMatchingOneParameter {
    
    OCMockObject<ICRouterDelegate> *routerDelegateMock = [OCMockObject mockForProtocol:@protocol(ICRouterDelegate)];
    [ICRouter sharedRouter].delegate = routerDelegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
    
    [[[routerDelegateMock stub] andReturn:navigationController] showViewControllerWithKey:ICSomeNavigationControllerKey];
    [[routerDelegateMock expect]
     presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:_specificPostRoute.viewControllerClass]; }]
     forRoute:_specificForumRoute
     fromViewController:navigationController];
    
    [[ICRouter sharedRouter] handleURL:[NSURL URLWithString:@"posts://forums/10"]];
    
    XCTAssertNoThrow([routerDelegateMock verify], @"A simple route with one argument should work");
}

- (void) testDependencies {
    
    OCMockObject<ICRouterDelegate> *routerDelegateMock = [OCMockObject mockForProtocol:@protocol(ICRouterDelegate)];
    [ICRouter sharedRouter].delegate = routerDelegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
    
    [[[routerDelegateMock stub] andReturn:navigationController] showViewControllerWithKey:ICSomeNavigationControllerKey];
    [[routerDelegateMock expect]
     presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:_specificPostRoute.viewControllerClass]; }]
     forRoute:_specificForumRoute
     fromViewController:navigationController];
    
    
    [[[routerDelegateMock stub] andReturn:navigationController] showViewControllerWithKey:ICSomeNavigationControllerKey];
    [[routerDelegateMock expect]
     presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:_specificPostRoute.viewControllerClass]; }]
     forRoute:_specificPostRoute
     fromViewController:navigationController];

    
    [[ICRouter sharedRouter] handleURL:[NSURL URLWithString:@"posts://forums/10/post/35"]];
    
    XCTAssertNoThrow([routerDelegateMock verify], @"A simple route with two arguments should work");
}


@end
