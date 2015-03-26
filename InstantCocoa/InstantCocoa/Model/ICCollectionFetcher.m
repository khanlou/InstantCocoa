//
//  ICCollectionFetcher.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 8/27/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICCollectionFetcher.h"
#import "ICRemoteConfiguration.h"
#import "ICModel.h"

@interface ICCollectionFetcher ()

@property (nonatomic, strong) AFHTTPRequestOperation *currentOperation;

@end

@implementation ICCollectionFetcher

@synthesize remoteConfiguration = _remoteConfiguration;

- (void) setRemoteConfiguration:(ICRemoteConfiguration *)remoteConfiguration {
    _remoteConfiguration = remoteConfiguration;
    self.networkRequestManager = nil;
}

- (ICRemoteConfiguration *)remoteConfiguration {
    if (!_remoteConfiguration) {
        return [ICRemoteConfiguration defaultConfiguration];
    }
    return _remoteConfiguration;
}

- (NSDictionary *)queryParameters {
    return _queryParameters ?: @{};
}

- (AFHTTPRequestOperationManager*)networkRequestManager {
    if (!_networkRequestManager) {
        return self.remoteConfiguration.requestManager;
    }
    return _networkRequestManager;
}

- (void)fetchCollectionWithSuccessBlock:(void (^)(NSArray *))successBlock failureBlock:(void (^)(NSError *))failureBlock {
    [self.currentOperation cancel];
    
    self.currentOperation = [self.networkRequestManager GET:self.apiPath parameters:self.queryParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.currentOperation = nil;
        NSArray *mappedObjects = [self mappedObjectsFromResponse:responseObject];
        if (mappedObjects && successBlock) {
            successBlock(mappedObjects);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.currentOperation = nil;
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

- (NSArray *)mappedObjectsFromResponse:(id)responseObject {
    id objectAtKeypath;
    if (_keyPath) {
        objectAtKeypath = [responseObject valueForKeyPath:_keyPath];
    } else {
        objectAtKeypath = responseObject;
    }
    if (!objectAtKeypath) {
        return @[];
    }
    if (![objectAtKeypath respondsToSelector:@selector(objectAtIndex:)]) {
        objectAtKeypath = @[objectAtKeypath];
    }
    
    NSMutableArray *localDomainObjects = [NSMutableArray array];
    for (NSDictionary *remoteObject in objectAtKeypath) {
        if (self.mappingClass && [remoteObject isKindOfClass:[NSDictionary class]]) {
            id localDomainObject = [self mapRemoteObject:remoteObject toDomainObjectOfClass:_mappingClass];
            [localDomainObjects addObject:localDomainObject];
        } else {
            [localDomainObjects addObject:remoteObject];
        }
    }
    return localDomainObjects;
}

- (void)cancelFetch {
    [self.currentOperation cancel];
    self.currentOperation = nil;
}

- (id)mapRemoteObject:(NSDictionary*)remoteObject toDomainObjectOfClass:(Class)mappingClass {
    id localDomainObject = [mappingClass alloc];
    if ([localDomainObject conformsToProtocol:@protocol(ICJSONMappable)]) {
        localDomainObject = [localDomainObject initWithJSONDictionary:remoteObject];
    } else if ([localDomainObject conformsToProtocol:@protocol(ICMappable)]) {
        localDomainObject = [localDomainObject initWithDictionary:remoteObject];
    } else {
        localDomainObject = [localDomainObject init];
    }
    
    return localDomainObject;
}


@end
