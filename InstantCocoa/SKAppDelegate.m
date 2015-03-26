//
//  SKAppDelegate.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/15/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "SKAppDelegate.h"

#import "ICInflector.h"
#import "ICRouter.h"
#import "ICRoute.h"

#import "SKPostsViewController.h"
#import "SKHerokuConfiguration.h"

@interface SKAppDelegate () <ICRouterDelegate>

@end

@implementation SKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[ICInflector sharedInflector] addPrefixes:[NSSet setWithObject:@"SK"]];
        
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[SKPostsViewController alloc] init] ];
    [self.window makeKeyAndVisible];

    [self setUpRouting];
    
    if (launchOptions[UIApplicationLaunchOptionsURLKey]) {
        [[ICRouter sharedRouter] handleURL:launchOptions[UIApplicationLaunchOptionsURLKey]];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[ICRouter sharedRouter] handleURL:url];
    return YES;
}

- (void) setUpRouting {
    [ICRouter sharedRouter].delegate = self;
    
    
    ICRoute *route = [ICRoute routeWithPath:@"/posts/{id}"];
    route.viewControllerClass = [SKPostsViewController class];
    [[ICRouter sharedRouter] registerRoute:route];
}

- (UIViewController *)showViewControllerWithKey:(NSString *)viewControllerKey {
    return self.window.rootViewController;
}

@end
