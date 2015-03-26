//
//  ICModel+Remote.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/27/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICModel.h"

@interface ICModel (Remote)

+ (void) getRemoteObjectWithID:(id<NSCopying, NSObject>)ID success:(void (^)(id object))successBlock failure:(void (^)(id object, NSError *error))failureBlock;
+ (void) createRemoteObjectWithSuccess:(void (^)(id newObject))successBlock failure:(void (^)(id object, NSError *error))failureBlock;
- (void) updateRemoteObjectWithSuccess:(void (^)(id updatedObject))successBlock failure:(void (^)(id object, NSError *error))failureBlock;
- (void) deleteRemoteObjectWithSuccess:(void (^)())successBlock failure:(void (^)(id object, NSError *error))failureBlock;

@end
