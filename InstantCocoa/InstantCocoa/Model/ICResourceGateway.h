//
//  ICAPIController.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 3/16/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString HTTPVerb;

extern HTTPVerb * const HTTPVerbGET;
extern HTTPVerb * const HTTPVerbPOST;
extern HTTPVerb * const HTTPVerbPUT;
extern HTTPVerb * const HTTPVerbPATCH;
extern HTTPVerb * const HTTPVerbDELETE;

@protocol ICRemoteObject;

@class ICModel, ICRemoteConfiguration, AFHTTPRequestOperationManager;

@interface ICResourceGateway : NSObject

@property (nonatomic, strong) ICRemoteConfiguration *remoteConfiguration;
@property (nonatomic, strong) AFHTTPRequestOperationManager *networkRequestManager;

@property (nonatomic, strong) HTTPVerb *HTTPVerbForCustomActions;

@property (nonatomic, assign) BOOL updateObjectOnCompletion;

//things that are inferred from the model but can be overridden
@property (nonatomic, strong) NSString *remoteKeypath;

- (instancetype)initWithClass:(Class)objectClass modelObject:(id<ICRemoteObject>)object;

@property (nonatomic, weak, readonly) Class objectClass;
@property (nonatomic, weak, readonly) id<ICRemoteObject> object;

- (void)performAction:(NSString*)action
         successBlock:(void(^)(id object))successBlock
         failureBlock:(void(^)(id object, NSError *error))failureBlock;

- (void)performAction:(NSString*)action
      queryParameters:(NSDictionary*)queryParameters
         successBlock:(void(^)(id object))successBlock
         failureBlock:(void(^)(id object, NSError *error))failureBlock;

@end
