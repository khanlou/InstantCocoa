//
//  ICCollectionFetcher.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 8/27/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@class ICRemoteConfiguration;

@interface ICCollectionFetcher : NSObject

@property (nonatomic, strong) Class mappingClass;

@property (nonatomic, strong) ICRemoteConfiguration *remoteConfiguration;
@property (nonatomic, strong) NSDictionary *queryParameters;
@property (nonatomic, strong) NSString *apiPath;
@property (nonatomic, strong) NSString *keyPath;

@property (nonatomic, strong) AFHTTPRequestOperationManager *networkRequestManager;

- (void)fetchCollectionWithSuccessBlock:(void (^)(NSArray *objects))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)cancelFetch;

@end
