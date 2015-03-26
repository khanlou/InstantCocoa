//
//  ICConfiguration.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/11/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFSecurityPolicy;
@class AFHTTPRequestOperationManager;

@interface ICRemoteConfiguration : NSObject

+ (void)setDefaultConfiguration:(ICRemoteConfiguration*)configuration;
+ (ICRemoteConfiguration*)defaultConfiguration;

@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) NSString *baseURLString;
@property (nonatomic, readonly) NSString *basicAuthUsername;
@property (nonatomic, readonly) NSString *basicAuthPassword;
@property (nonatomic, readonly) NSTimeInterval timeoutInterval;
@property (nonatomic, readonly) AFSecurityPolicy *securityPolicy;
@property (nonatomic, readonly) NSDictionary *additionalHTTPHeaders;
@property (nonatomic, readonly) NSString *contentTypeHeaderValue;
@property (nonatomic, readonly) NSString *acceptHeaderValue;
@property (nonatomic, readonly) NSURLRequestCachePolicy cachePolicy;

@property (nonatomic, readonly) AFHTTPRequestOperationManager *requestManager;

@end
