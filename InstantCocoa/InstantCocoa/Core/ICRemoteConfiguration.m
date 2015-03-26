//
//  ICConfiguration.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/11/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICRemoteConfiguration.h"
#import <AFNetworking/AFNetworking.h>

@interface ICRemoteConfiguration ()

@property (nonatomic, strong, readwrite) AFHTTPRequestOperationManager *requestManager;


@end

@implementation ICRemoteConfiguration

static ICRemoteConfiguration *_defaultConfiguration;

+ (void) setDefaultConfiguration:(ICRemoteConfiguration*)configuration {
    _defaultConfiguration = configuration;
}

+ (ICRemoteConfiguration*) defaultConfiguration {
    if (!_defaultConfiguration) {
        _defaultConfiguration = [ICRemoteConfiguration new];
    }
    return _defaultConfiguration;
}

- (NSURL *)baseURL {
    return [NSURL URLWithString:self.baseURLString];
}

- (NSString *)baseURLString {
    [[NSException exceptionWithName:@"ICMissingBaseURLException" reason:@"ICRemoteConfiguration expects a baseURL or a baseURLString" userInfo:nil] raise];
    return nil;
}

- (NSString *)contentTypeHeaderValue {
    return @"application/json";
}

- (NSString *)acceptHeaderValue {
    return @"application/json";
}

- (NSTimeInterval)timeoutInterval {
    return 120;
}

- (NSURLRequestCachePolicy)cachePolicy {
    return NSURLRequestUseProtocolCachePolicy;
}

- (AFHTTPRequestOperationManager *)requestManager {
    if (!_requestManager) {
        self.requestManager = [self newRequestManager];
    }
    return _requestManager;
}

- (AFHTTPRequestOperationManager *)newRequestManager {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseURL];
    manager.securityPolicy = self.securityPolicy;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:self.acceptHeaderValue forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:self.contentTypeHeaderValue forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer.timeoutInterval = self.timeoutInterval;
    manager.requestSerializer.cachePolicy = self.cachePolicy;
    [self.additionalHTTPHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }];

    return manager;
}

@end
