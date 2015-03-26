//
//  ICPaginatedDataSource.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/13/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICPaginatedDataSource.h"
#import "NSArray+FunctionalMethods.h"
#import "ICPlaceholders.h"
#import "ICSimpleDataSource.h"
#import "ICCollectionFetcher.h"

@implementation ICPaginatorKeys @end

@interface ICPaginatedDataSource ()

@property (nonatomic, strong) ICSimpleDataSource *backingDataSource;

@property (nonatomic, assign, readwrite) NSInteger pageSize;
@property (nonatomic, assign, readwrite) NSInteger currentPage;
@property (nonatomic, assign, readwrite) NSInteger numberOfPages;
@property (nonatomic, assign, readwrite) NSInteger numberOfTotalResults;
@property (nonatomic, assign, readwrite) BOOL hasMorePages;

@property (nonatomic, strong) ICCollectionFetcher *fetcher;
@property (nonatomic, readwrite) BOOL isFetching;

@property (readonly) BOOL storeErrors;
@property (readonly) BOOL storeNoResultsPlaceholder;
@property (readonly) BOOL storeLoadingPlaceholder;

@end

@implementation ICPaginatedDataSource

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
    [self resetObjects];
    [self fetchDataInternal];
}

- (void)fetchDataInternal {
    self.isFetching = YES;
    [self.fetcher cancelFetch];
    if ([self.delegate respondsToSelector:@selector(dataSourceWillLoadData:)]) {
        [self.delegate dataSourceWillLoadData:self];
    }
    if ([self.delegate respondsToSelector:@selector(dataSourceDidPartiallyLoad:)]) {
        [self.delegate dataSourceDidPartiallyLoad:self];
    }
    
    [self.fetcher fetchCollectionWithSuccessBlock:^(NSArray *objects) {
        self.isFetching = NO;
        [self handleNewObjects:objects];
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

- (void)handleNewObjects:(NSArray *)objects {
    NSArray *oldObjects = self.backingDataSource.allObjects;
    NSArray *newObjects = objects;
    if (newObjects.count == 0) {
        self.hasMorePages = NO;
    } else {
        self.hasMorePages = YES;
    }
    NSArray *newObjectsArray = [oldObjects arrayByAddingObjectsFromArray:newObjects];
    newObjectsArray = [newObjectsArray arrayByRejectingObjectsPassingTest:^BOOL(id object) {
        return [object isKindOfClass:[ICLoadingPlaceholder class]];
    }];
    if (self.hasMorePages && self.storeLoadingPlaceholder) {
        newObjectsArray = [newObjectsArray arrayByAddingObject:[ICLoadingPlaceholder new]];
    }
    [self storeObjects:newObjectsArray];
}

- (void)resetObjects {
    NSArray *resetArray = self.storeLoadingPlaceholder ? @[[ICLoadingPlaceholder new]] : @[];
    [self storeObjects:resetArray];
    self.currentPage = 1;
}

- (void)storeObjects:(NSArray *)objects {
    self.backingDataSource = [[ICSimpleDataSource alloc] initWithObjects:objects];
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


- (ICPaginatorKeys *)keys {
    if (!_keys) {
        _keys = [ICPaginatorKeys new];
        _keys.pageSize = @"page_size";
        _keys.currentPage = @"page";
        _keys.numberOfPages = @"number_of_pages";
        _keys.numberOfTotalObjects = @"total_count";
    }
    return _keys;
}

- (void)fetchNextPage {
    if (self.isFetching || !self.hasMorePages) {
        return;
    }
    self.currentPage = self.currentPage + 1;
    
    [self fetchDataInternal];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    NSMutableDictionary *mutableParameters = self.queryParameters.mutableCopy;
    mutableParameters[self.keys.currentPage] = @(self.currentPage);
    self.queryParameters = mutableParameters;
}

- (ICSimpleDataSource *)backingDataSource {
    if (!_backingDataSource) {
        self.backingDataSource = [[ICSimpleDataSource alloc] initWithObjects:@[[ICLoadingPlaceholder new]]];
    }
    return _backingDataSource;
}

- (id)lastObject {
    return [self.backingDataSource.allObjects lastObject];
}

- (void)willDisplayObjectAtIndexPath:(NSIndexPath*)indexPath {
    if ([self objectAtIndexPath:indexPath] == self.lastObject) {
        [self fetchNextPage];
    }
}

//forwarded access methods

- (NSUInteger)numberOfSections {
    return [self.backingDataSource numberOfSections];
}

- (NSUInteger)numberOfObjectsInSection:(NSUInteger)section {
    return [self.backingDataSource numberOfObjectsInSection:section];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.backingDataSource objectAtIndexPath:indexPath];;
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
