//
//  ICModel+Remote.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/27/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICModel+Remote.h"
#import "ICResourceGateway.h"

@implementation ICModel (Remote)

+ (void)getRemoteObjectWithID:(id<NSCopying, NSObject>)ID success:(void (^)(id object))successBlock failure:(void (^)(id object, NSError *error))failureBlock {
    ICModel *newObject = [self new];
    newObject.objectID = ID;
    [[newObject gateway] performAction:@"GET" successBlock:^(id object) {
        if (successBlock) successBlock(object);
    } failureBlock:^(id object, NSError *error) {
        if (failureBlock) failureBlock(object, error);
    }];
}

+ (void)createRemoteObjectWithSuccess:(void (^)(id newObject))successBlock failure:(void (^)(id object, NSError *error))failureBlock {
    [[self gateway] performAction:@"POST" successBlock:^(id object) {
        if (successBlock) successBlock(object);
    } failureBlock:^(id object, NSError *error) {
        if (failureBlock) failureBlock(object, error);
    }];
}

- (void)saveRemoteObjectWithSuccess:(void (^)(id object))successBlock failure:(void (^)(id object, NSError *error))failureBlock {
    [[self gateway] performAction:@"POST" queryParameters:self.JSONRepresentation successBlock:^(id object) {
        if (successBlock) successBlock(object);
    } failureBlock:^(id object, NSError *error) {
        if (failureBlock) failureBlock(object, error);
    }];
}

- (void)updateRemoteObjectWithSuccess:(void (^)(id updatedObject))successBlock failure:(void (^)(id object, NSError *error))failureBlock {
    [[self gateway] performAction:@"PUT" queryParameters:self.JSONRepresentation successBlock:^(id object) {
        if (successBlock) successBlock(object);
    } failureBlock:^(id object, NSError *error) {
        if (failureBlock) failureBlock(object, error);
    }];
}

- (void)deleteRemoteObjectWithSuccess:(void (^)())successBlock failure:(void (^)(id object, NSError *error))failureBlock {
    [[self gateway] performAction:@"DELETE" successBlock:^(id object) {
        if (successBlock) successBlock();
    } failureBlock:^(id object, NSError *error) {
        if (failureBlock) failureBlock(object, error);
    }];
}

@end
