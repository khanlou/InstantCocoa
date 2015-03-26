//
//  ICDataSource.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/11/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICDataSource.h"
#import <AFNetworking.h>

@class ICRemoteConfiguration;

typedef NS_ENUM(NSUInteger, ICRemoteDataSourceStorage) {
    ICRemoteDataSourceShouldStoreLoadingPlaceholder = 1 << 1,
    ICRemoteDataSourceShouldStoreNoResultsPlaceholder = 1 << 2,
    ICRemoteDataSourceShouldStoreErrors = 1 << 3,
};

@interface ICRemoteDataSource : NSObject <ICDataSource>

@property (nonatomic, weak) id<ICDataSourceDelegate> delegate;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, readonly) NSArray *sectionTitles;

@property (nonatomic, strong, readonly) NSArray *allObjects;

@property (nonatomic, assign, readonly) NSUInteger numberOfSections;
- (NSUInteger) numberOfObjectsInSection:(NSUInteger)section;
- (id) objectAtIndexPath:(NSIndexPath*)indexPath;

- (void)fetchData;


@property (nonatomic, assign) ICRemoteDataSourceStorage placeholderStorageOptions;

@property (nonatomic, readonly) BOOL isFetching;

- (void)resetObjects;
- (void)cancelFetch;

//forwarded to ICCollectionFetcher
@property (nonatomic, strong) Class mappingClass;

@property (nonatomic, strong) ICRemoteConfiguration *remoteConfiguration;
@property (nonatomic, strong) NSDictionary *queryParameters;
@property (nonatomic, strong) NSString *apiPath;
@property (nonatomic, strong) NSString *keyPath;

@property (nonatomic, strong) AFHTTPRequestOperationManager *networkRequestManager;

@end
