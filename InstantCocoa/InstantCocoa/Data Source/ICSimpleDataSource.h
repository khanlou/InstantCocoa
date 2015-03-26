//
//  ICSimpleDataSource.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/2/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICDataSource.h"

@interface ICSimpleDataSource : NSObject<ICDataSource>

- (instancetype)initWithObjects:(NSArray*)objects;

@property (nonatomic, weak) id<ICDataSourceDelegate> delegate;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, readonly) NSArray *sectionTitles;

@property (nonatomic, strong, readonly) NSArray *allObjects;

@property (nonatomic, assign, readonly) NSUInteger numberOfSections;
- (NSUInteger) numberOfObjectsInSection:(NSUInteger)section;
- (id) objectAtIndexPath:(NSIndexPath*)indexPath;

- (void)fetchData;

@end
