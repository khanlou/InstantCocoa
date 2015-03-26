//
//  ICRouter.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/31/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICRouter.h"
#import "ICRoute.h"
#import "ICModelProtocols.h"
#import <NSArray+FunctionalMethods.h>

NSString * const ICRouterRoutingPathKey = @"ICRouterRoutingPathKey";
NSString * const ICRouterPathComponentsKey = @"ICRouterPathComponentsKey";
NSString * const ICRouterMatchedRouteKey = @"ICRouterMatchedRouteKey";


@interface ICRouter ()

@property (nonatomic, strong) NSMutableArray *routes;

@end

@implementation ICRouter

+ (instancetype)sharedRouter {
    static ICRouter *_sharedRouter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedRouter = [[self alloc] init];
    });
    return _sharedRouter;
}

- (NSMutableArray*)routes {
    if (!_routes) {
        self.routes = [NSMutableArray array];
    }
    return _routes;
}

- (void)registerRoute:(ICRoute*)route {
    [self.routes addObject:route];
}

- (NSString*)pathFromURL:(NSURL*)url {
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSString *routePath = [urlComponents.host copy] ?: @"";
    if (urlComponents.path) {
        routePath = [routePath stringByAppendingPathComponent:urlComponents.path];
    }
    return routePath;
}

- (ICRoute*)routeMatchingPath:(NSString*)routePath {
    return [[[_routes reverseObjectEnumerator] allObjects] firstObjectPassingTest:^BOOL(ICRoute* route) {
        return [route canHandlePath:routePath];
    }];
}

- (BOOL)canHandleURL:(NSURL*)url {
    NSString *routePath = [self pathFromURL:url];
    return [self routeMatchingPath:routePath] != nil;
}

- (BOOL)handleURL:(NSURL*)url {
    NSString *routePath = [self pathFromURL:url];
    ICRoute *matchingRoute = [self routeMatchingPath:routePath];
    
    if (!matchingRoute) {
        return NO;
    }
    
    NSMutableDictionary *parameters = [[matchingRoute parametersForPath:routePath] mutableCopy];
    
    parameters[ICRouterRoutingPathKey] = routePath;
    parameters[ICRouterPathComponentsKey] = [routePath pathComponents];
    parameters[ICRouterMatchedRouteKey] = matchingRoute;
    
    for (ICRoute *dependency in matchingRoute.dependencies) {
        [self navigateToRoute:dependency withParameters:parameters isDependency:YES];
    }
    [self navigateToRoute:matchingRoute withParameters:parameters isDependency:NO];
    return YES;
}

- (void)navigateToRoute:(ICRoute*)route withParameters:(NSDictionary*)parameters isDependency:(BOOL)isDependency {
    if (!route) return;
    
    UIViewController *presentingViewController;
    if ([_delegate respondsToSelector:@selector(showViewControllerWithKey:)]) {
        presentingViewController = [_delegate showViewControllerWithKey:route.navigationControllerKey];
    }
    
    id viewController = [route.viewControllerClass alloc];
    if ([viewController conformsToProtocol:@protocol(ICRoutable)]) {
        viewController = [viewController initWithRoutingInfo:parameters];
    } else {
        viewController = [viewController init];
    }
    
    if (!presentingViewController) {
        presentingViewController = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    }
    
    if ([self.delegate respondsToSelector:@selector(viewController:requiresPopToRootForRoute:)]) {
        if (isDependency && route.shouldPopToRoot) {
            [self.delegate viewController:presentingViewController requiresPopToRootForRoute:route];
        }
    } else {
        UINavigationController *navigationController = (UINavigationController*)presentingViewController;
        if ([navigationController respondsToSelector:@selector(popToRootViewControllerAnimated:)]) {
            if (route.shouldPopToRoot) {
                [navigationController popToRootViewControllerAnimated:NO];
            }
        }
    }
    
    if ([_delegate respondsToSelector:@selector(presentViewController:forRoute:fromViewController:)]) {
        [_delegate presentViewController:viewController forRoute:route fromViewController:presentingViewController];
    } else {
        UINavigationController *navigationController = (UINavigationController*)presentingViewController;
        if ([presentingViewController respondsToSelector:@selector(pushViewController:animated:)]) {
            [navigationController pushViewController:viewController animated:NO];
        }
    }
}

@end
