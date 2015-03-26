//
//  ICDataSource.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/11/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICRemoteDataSource.h"
#import "ICRemoteConfiguration.h"
#import "ICModel.h"
#import "NSArray+Sectioning.h"
#import "ICPlaceholders.h"
#import "ICSimpleDataSource.h"
#import "ICCollectionFetcher.h"

@interface ICRemoteDataSource ()

@property (nonatomic, strong) ICSimpleDataSource *backingDataSource;

@property (nonatomic, strong) ICCollectionFetcher *fetcher;
@property (nonatomic, readwrite) BOOL isFetching;

@property (readonly) BOOL storeErrors;
@property (readonly) BOOL storeNoResultsPlaceholder;
@property (readonly) BOOL storeLoadingPlaceholder;

@end

@implementation ICRemoteDataSource

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    _placeholderStorageOptions = ICRemoteDataSourceShouldStoreLoadingPlaceholder | ICRemoteDataSourceShouldStoreNoResultsPlaceholder;
    
    return self;
}

- (ICCollectionFetcher *)fetcher {
    if (!_fetcher) {
        self.fetcher = [ICCollectionFetcher new];
    }
    return _fetcher;
}

- (void)fetchData {
    self.isFetching = YES;
    [self.fetcher cancelFetch];
    if ([self.delegate respondsToSelector:@selector(dataSourceWillLoadData:)]) {
        [self.delegate dataSourceWillLoadData:self];
    }
    [self resetObjects];
    if ([self.delegate respondsToSelector:@selector(dataSourceDidPartiallyLoad:)]) {
        [self.delegate dataSourceDidPartiallyLoad:self];
    }
    
    [self.fetcher fetchCollectionWithSuccessBlock:^(NSArray *objects) {
        self.isFetching = NO;
        [self storeObjects:objects];
        if ([self.delegate respondsToSelector:@selector(dataSourceFinishedLoading:)]) {
            [self.delegate dataSourceFinishedLoading:self];
        }
    } failureBlock:^(NSError *error) {
        self.isFetching = NO;
        if (self.allObjects.count == 0) {
            NSArray *errors = self.storeErrors && error ? @[error] : @[];
            [self storeObjects:errors];
        }
        
        if ([self.delegate respondsToSelector:@selector(dataSource:failedWithError:)]) {
            [self.delegate dataSource:self failedWithError:error];
        }
    }];
}

- (void)cancelFetch {
    [self.fetcher cancelFetch];
}

- (void)storeObjects:(NSArray *)objects {
    self.backingDataSource = [[ICSimpleDataSource alloc] initWithObjects:objects];
}

- (void)resetObjects {
    NSArray *resetArray = self.storeLoadingPlaceholder ? @[[ICLoadingPlaceholder new]] : @[];
    [self storeObjects:resetArray];
}

- (BOOL)storeErrors {
    return self.placeholderStorageOptions & ICRemoteDataSourceShouldStoreErrors;
}

- (BOOL)storeLoadingPlaceholder {
    return self.placeholderStorageOptions & ICRemoteDataSourceShouldStoreLoadingPlaceholder;
}

- (BOOL)storeNoResultsPlaceholder {
    return self.placeholderStorageOptions & ICRemoteDataSourceShouldStoreNoResultsPlaceholder;
}

//forwarded access methods

- (NSUInteger)numberOfSections {
    return [self.backingDataSource numberOfSections];
}

- (NSUInteger)numberOfObjectsInSection:(NSUInteger)section {
    return [self.backingDataSource numberOfObjectsInSection:section];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.backingDataSource objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return [self.backingDataSource indexPathForObject:object];
}

- (NSArray *)allObjects {
    return self.backingDataSource.allObjects;
}

//forwarded to fetcher

- (void)setMappingClass:(Class)mappingClass {
    self.fetcher.mappingClass = mappingClass;
}

- (Class)mappingClass {
    return self.fetcher.mappingClass;
}

- (void)setRemoteConfiguration:(ICRemoteConfiguration *)remoteConfiguration {
    self.fetcher.remoteConfiguration = remoteConfiguration;
}

- (ICRemoteConfiguration *)remoteConfiguration {
    return self.fetcher.remoteConfiguration;
}

- (void)setQueryParameters:(NSDictionary *)queryParameters {
    self.fetcher.queryParameters = queryParameters;
}

- (NSDictionary *)queryParameters {
    return self.fetcher.queryParameters;
}

- (void)setApiPath:(NSString *)apiPath {
    self.fetcher.apiPath = apiPath;
}

- (NSString *)apiPath {
    return self.fetcher.apiPath;
}

- (void)setKeyPath:(NSString *)keyPath {
    self.fetcher.keyPath = keyPath;
}

- (NSString *)keyPath {
    return self.fetcher.keyPath;
}

- (void)setNetworkRequestManager:(AFHTTPRequestOperationManager *)networkRequestManager {
    self.fetcher.networkRequestManager = networkRequestManager;
}

- (AFHTTPRequestOperationManager *)networkRequestManager {
    return self.fetcher.networkRequestManager;
}

@end
