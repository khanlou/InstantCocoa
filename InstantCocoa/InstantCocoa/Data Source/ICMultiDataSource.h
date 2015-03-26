//
//  ICMultiDataSource.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/2/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICDataSource.h"

@interface ICMultiDataSource : NSObject <ICDataSource>

- (instancetype)initWithDataSources:(NSArray*)dataSources;
@property (nonatomic, copy, readonly) NSArray *dataSources;

@property (nonatomic, weak) id<ICDataSourceDelegate> delegate;

@property (nonatomic, assign, readonly) NSUInteger numberOfSections;
- (NSUInteger) numberOfObjectsInSection:(NSUInteger)section;
- (id) objectAtIndexPath:(NSIndexPath*)indexPath;

- (void)willDisplayObjectAtIndexPath:(NSIndexPath*)indexPath;
- (void)fetchData;

- (id<ICDataSource>)dataSourceAtSectionIndex:(NSUInteger)sectionIndex;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) BOOL preserveSectionsInSubDataSources;

@property (nonatomic, readonly) NSArray *sectionTitles;

@property (nonatomic, readonly) BOOL isFetching;

@end
