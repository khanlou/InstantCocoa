//
//  ICPaginatedDataSource.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/13/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICDataSource.h"
#import "ICRemoteDataSource.h"

@interface ICPaginatorKeys : NSObject

@property (nonatomic, strong) NSString *pageSize;
@property (nonatomic, strong) NSString *currentPage;
@property (nonatomic, strong) NSString *numberOfPages;
@property (nonatomic, strong) NSString *numberOfTotalObjects;

@end


@interface ICPaginatedDataSource : NSObject <ICDataSource>

//ICDataSource protocol
@property (nonatomic, weak) id<ICDataSourceDelegate> delegate;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, readonly) NSArray *sectionTitles;

@property (nonatomic, strong, readonly) NSArray *allObjects;
@property (nonatomic, strong, readonly) id firstObject;

@property (nonatomic, assign, readonly) NSUInteger numberOfSections;
- (NSUInteger) numberOfObjectsInSection:(NSUInteger)section;
- (id) objectAtIndexPath:(NSIndexPath*)indexPath;

- (void)fetchData;

//standard remote data source
@property (nonatomic, assign) ICRemoteDataSourceStorage placeholderStorageOptions;

@property (nonatomic, readonly) BOOL isFetching;
@property (nonatomic, readonly) NSArray *errors;

- (void)resetObjects;
- (void)cancelFetch;

//paginated data source stuff

@property (nonatomic, assign, readonly) NSInteger pageSize;
@property (nonatomic, assign, readonly) NSInteger currentPage;
@property (nonatomic, assign, readonly) NSInteger numberOfPages;
@property (nonatomic, assign, readonly) NSInteger numberOfTotalResults;
@property (nonatomic, assign, readonly) BOOL hasMorePages;

@property (nonatomic, strong) ICPaginatorKeys *keys;

- (void)fetchNextPage;

- (void)willDisplayObjectAtIndexPath:(NSIndexPath*)indexPath;

//forwarded to ICCollectionFetcher
@property (nonatomic, strong) Class mappingClass;

@property (nonatomic, strong) ICRemoteConfiguration *remoteConfiguration;
@property (nonatomic, strong) NSDictionary *queryParameters;
@property (nonatomic, strong) NSString *apiPath;
@property (nonatomic, strong) NSString *keyPath;

@property (nonatomic, strong) AFHTTPRequestOperationManager *networkRequestManager;



@end

