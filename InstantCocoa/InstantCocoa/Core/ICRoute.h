//
//  ICRoute.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/31/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ICRouteMatcher <NSObject>

- (BOOL)canHandlePath:(NSString*)incomingPath;
- (NSDictionary*)parametersForPath:(NSString*)incomingPath;

@end

@interface ICSimpleRouteMatcher : NSObject <ICRouteMatcher>

- (instancetype)initWithPath:(NSString *)path;

@property (nonatomic, readonly) NSString *path;

- (BOOL) canHandlePath:(NSString*)incomingPath;
- (NSDictionary*)parametersForPath:(NSString*)incomingPath;

@end

@interface ICRoute : NSObject

+ (instancetype)routeWithPath:(NSString*)path;

- (instancetype)initWithPath:(NSString*)path;
- (instancetype)initWithMatcher:(id<ICRouteMatcher>)matcher;

@property (nonatomic, strong) NSString *navigationControllerKey;
@property (nonatomic, strong) Class viewControllerClass;
@property (nonatomic, assign) BOOL shouldPopToRoot;
@property (nonatomic, strong) NSArray *dependencies;

- (BOOL)canHandlePath:(NSString*)incomingPath;
- (NSDictionary*)parametersForPath:(NSString*)incomingPath;

@end
