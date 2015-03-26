//
//  ICDataSource.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/2/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

@protocol ICDataSourceDelegate;


@protocol ICDataSource <NSObject>

@property (nonatomic, weak) id<ICDataSourceDelegate> delegate;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong, readonly) NSArray *sectionTitles;

@property (nonatomic, strong, readonly) NSArray *allObjects;

@property (nonatomic, assign, readonly) NSUInteger numberOfSections;
- (NSUInteger) numberOfObjectsInSection:(NSUInteger)section;
- (id) objectAtIndexPath:(NSIndexPath*)indexPath;

- (NSIndexPath *)indexPathForObject:(id)object;

- (void)fetchData;

@end


@protocol ICDataSourceDelegate <NSObject>

@optional
- (void)dataSourceWillLoadData:(id<ICDataSource>)dataSource;
- (void)dataSourceDidPartiallyLoad:(id<ICDataSource>)dataSource;
- (void)dataSourceFinishedLoading:(id<ICDataSource>)dataSource;
- (void)dataSource:(id<ICDataSource>)dataSource failedWithError:(NSError*)error;

@end
