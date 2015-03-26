//
//  ICAPIController.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 3/16/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICResourceGateway.h"
#import "ICModel.h"
#import "ICModel+Remote.h"
#import <AFHTTPRequestOperationManager.h>
#import "ICJSONMapper.h"
#import "ICRemoteConfiguration.h"

//replace with types?
HTTPVerb * const HTTPVerbGET = @"GET";
HTTPVerb * const HTTPVerbPOST = @"POST";
HTTPVerb * const HTTPVerbPUT = @"PUT";
HTTPVerb * const HTTPVerbPATCH = @"PATCH";
HTTPVerb * const HTTPVerbDELETE = @"DELETE";
//HEAD?

@interface ICResourceGateway ()

@property (nonatomic, weak, readwrite) Class objectClass;
@property (nonatomic, weak, readwrite) id<ICRemoteObject> object;

@end

@implementation ICResourceGateway

+ (NSArray *)HTTPVerbs {
    return @[HTTPVerbDELETE, HTTPVerbGET, HTTPVerbPATCH, HTTPVerbPOST, HTTPVerbPUT];
}

- (instancetype)initWithClass:(Class)objectClass modelObject:(id<ICRemoteObject>)object {
    self = [super init];
    if (!self) return nil;
    
    _object = object;
    _objectClass = objectClass;
    _updateObjectOnCompletion = YES;
    
    return self;
}

- (ICRemoteConfiguration *)remoteConfiguration {
    if (!_remoteConfiguration) {
        _remoteConfiguration = [ICRemoteConfiguration defaultConfiguration];
    }
    return _remoteConfiguration;
}

- (NSString *)HTTPVerbForCustomActions {
    if (_HTTPVerbForCustomActions) {
        return _HTTPVerbForCustomActions;
    }
    return HTTPVerbPUT;
}

- (AFHTTPRequestOperationManager*)networkRequestManager {
    if (!_networkRequestManager) {
        return self.remoteConfiguration.requestManager;
    }
    return _networkRequestManager;
}

- (NSString *)remoteKeypath {
    if (_remoteKeypath) {
        return _remoteKeypath;
    }
    if ([self.object.class respondsToSelector:@selector(remoteKeyPath)]) {
        return [self.object.class remoteKeyPath];
    }
    return @"";
}

- (void)performAction:(NSString*)action successBlock:(void(^)(id object))successBlock failureBlock:(void(^)(id object, NSError *error))failureBlock {
    [self performAction:action queryParameters:@{} successBlock:successBlock failureBlock:failureBlock];
}

- (void)performAction:(NSString*)action
      queryParameters:(NSDictionary*)queryParameters
         successBlock:(void(^)(id object))successBlock
         failureBlock:(void(^)(id object, NSError *error))failureBlock;
{
    HTTPVerb *HTTPVerb;
    if ([[self.class HTTPVerbs] containsObject:action]) {
        HTTPVerb = action;
        action = @"";
    } else {
        HTTPVerb = self.HTTPVerbForCustomActions;
    }
    NSString *urlString = [self urlStringForAction:action HTTPVerb:&HTTPVerb withQueryParameters:&queryParameters];
    
    [self requestURLString:urlString withHTTPVerb:HTTPVerb queryParameters:queryParameters successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self mapResponse:responseObject];
        if (successBlock) successBlock(self.object);
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureBlock) {
            failureBlock(self.object, error);
        }
    }];
}

- (void)mapResponse:(id)responseObject {
    if (responseObject
        && self.updateObjectOnCompletion
        && [self.object conformsToProtocol:@protocol(ICJSONMappable)]) {
        id<ICJSONMappable> mappableObject = (id<ICJSONMappable>)self.object;
        [[ICJSONMapper new] mapFromJSONDictionary:[self responseObjectAtKeypath:responseObject] toObject:mappableObject];
    }
}

- (id)responseObjectAtKeypath:(id)responseObject {
    if (self.remoteKeypath.length == 0) {
        return responseObject;
    }
    return [responseObject valueForKeyPath:self.remoteKeypath];
}

- (NSString *)urlStringForAction:(NSString *)action HTTPVerb:(NSString **)HTTPVerb withQueryParameters:(NSDictionary **)queryParameters {
    if (!self.object) {
        return [[self.objectClass resourceEndpoint] stringByAppendingPathComponent:action];
    }
    return [[self.object resourceEndpoint] stringByAppendingPathComponent:action];
}

- (void)requestURLString:(NSString *)urlString
            withHTTPVerb:(HTTPVerb*)HTTPVerb
         queryParameters:(NSDictionary*)queryParameters
            successBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))successBlock
            failureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;
{
    AFHTTPRequestOperationManager *requestOperationManager = self.networkRequestManager;

    NSMutableURLRequest *request = [requestOperationManager.requestSerializer requestWithMethod:HTTPVerb
                                                                                      URLString:[[NSURL URLWithString:urlString relativeToURL:requestOperationManager.baseURL] absoluteString]
                                                                                     parameters:queryParameters
                                                                                          error:nil];
    AFHTTPRequestOperation *operation = [requestOperationManager HTTPRequestOperationWithRequest:request success:successBlock failure:failureBlock];
    
    [requestOperationManager.operationQueue addOperation:operation];
}

@end
