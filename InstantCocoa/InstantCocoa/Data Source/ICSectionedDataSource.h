//
//  ICSectionedDataSource.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/5/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICDataSource.h"

@interface ICSectionedDataSource : NSObject <ICDataSource>

- (instancetype)initWithDataSource:(id<ICDataSource>)dataSource sectioningKey:(NSString *)sectioningKey sortDescriptors:(NSArray *)sortDescriptors;

@property (nonatomic, strong, readonly) id<ICDataSource> wrappedDataSource;
@property (nonatomic, strong, readonly) NSString *sectioningKey;
@property (nonatomic, strong, readonly) NSArray *sortDescriptors;

@property (nonatomic, weak) id<ICDataSourceDelegate> delegate;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, readonly) NSArray *sectionTitles;
@property (nonatomic, strong, readonly) NSArray *sectionedObjects;

@property (nonatomic, strong, readonly) NSArray *allObjects;

@property (nonatomic, assign, readonly) NSUInteger numberOfSections;
- (NSUInteger) numberOfObjectsInSection:(NSUInteger)section;
- (id) objectAtIndexPath:(NSIndexPath*)indexPath;

- (void)fetchData;


@end
