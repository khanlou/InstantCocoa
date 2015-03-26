//
//  ICSectionedDataSource.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/5/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICSectionedDataSource.h"
#import "NSArray+Sectioning.h"
#import <NSArray+FunctionalMethods.h>

@interface ICSectionedDataSource () <ICDataSourceDelegate>

@property (nonatomic, strong, readwrite) id<ICDataSource> wrappedDataSource;
@property (nonatomic, strong, readwrite) NSArray *sortDescriptors;
@property (nonatomic, strong, readwrite) NSArray *sectionedObjects;
@property (nonatomic, strong, readwrite) NSArray *sectionTitles;

@end

@implementation ICSectionedDataSource

- (instancetype)initWithDataSource:(id<ICDataSource>)dataSource sectioningKey:(NSString *)sectioningKey sortDescriptors:(NSArray *)sortDescriptors {
    self = [super init];
    if (!self) return nil;

    _sectioningKey = sectioningKey;
    _wrappedDataSource = dataSource;
    _wrappedDataSource.delegate = self;
    _sortDescriptors = sortDescriptors;

    return self;
}

- (void)sectionObjects:(NSArray *)objects {
    NSArray *sortedObjects = [objects sortedArrayUsingDescriptors:self.sortDescriptors];
    self.sectionedObjects = [sortedObjects sectionedArrayWithKey:self.sectioningKey];
    
    self.sectionTitles = [self.sectionedObjects arrayByTransformingObjectsUsingBlock:^id(NSArray *subArray) {
        if (_sectioningKey) {
            return [[subArray firstObject] valueForKeyPath:_sectioningKey];
        }
        return @"";
    }];
}

- (NSUInteger)numberOfSections {
    return self.sectionedObjects.count;
}

- (NSUInteger)numberOfObjectsInSection:(NSUInteger)section {
    return [self.sectionedObjects[section] count];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return self.sectionedObjects[indexPath.section][indexPath.row];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    for (NSInteger indexOfSection = 0; indexOfSection < self.sectionedObjects.count; indexOfSection++) {
        NSArray *section = self.sectionedObjects[indexOfSection];
        NSUInteger indexOfObject = [section indexOfObject:object];
        if (indexOfObject != NSNotFound) {
            return [NSIndexPath indexPathForRow:indexOfObject inSection:indexOfSection];
        }
    }
    return nil;
}

- (void) fetchData {
    if ([_delegate respondsToSelector:@selector(dataSourceWillLoadData:)]) {
        [_delegate dataSourceWillLoadData:self];
    }
    [self.wrappedDataSource fetchData];
}

- (void)dataSourceFinishedLoading:(id<ICDataSource>)dataSource {
    [self sectionObjects:[dataSource allObjects]];
    if ([_delegate respondsToSelector:@selector(dataSourceFinishedLoading:)]) {
        [_delegate dataSourceFinishedLoading:self];
    }
}

- (NSArray *)allObjects {
    return [self.sectionedObjects objectByReducingObjectsIntoAccumulator:[NSMutableArray array] usingBlock:^id(id accumulator, NSArray *subArray) {
        [accumulator addObjectsFromArray:subArray];
        return accumulator;
    }];
}

@end
