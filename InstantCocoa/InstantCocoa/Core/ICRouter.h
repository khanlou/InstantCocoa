//
//  ICRouter.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/31/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ICRouterRoutingPathKey;
extern NSString * const ICRouterPathComponentsKey;
extern NSString * const ICRouterMatchedRouteKey;

@class ICRoute;

@protocol ICRouterDelegate <NSObject>

@optional;
- (UIViewController*)showViewControllerWithKey:(NSString*)viewControllerKey;
- (void)viewController:(UIViewController*)viewController requiresPopToRootForRoute:(ICRoute*)route;
- (void) presentViewController:(UIViewController*)viewControllerToPresent forRoute:(ICRoute*)route fromViewController:(UIViewController*)fromViewController;

@end


@interface ICRouter : NSObject

+ (instancetype) sharedRouter;

@property (nonatomic, weak) id<ICRouterDelegate> delegate;

- (void)registerRoute:(ICRoute*)route;

- (BOOL)canHandleURL:(NSURL*)url;
- (BOOL)handleURL:(NSURL*)url;

@end
