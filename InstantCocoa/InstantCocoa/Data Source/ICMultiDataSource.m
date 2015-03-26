//
//  ICMultiDataSource.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/2/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICMultiDataSource.h"
#import "ICPaginatedDataSource.h"
#import "NSArray+FunctionalMethods.h"
#import "NSArray+Convenience.h"

@interface ICMultiDataSource ()<ICDataSourceDelegate>

@property (nonatomic, strong) NSArray *sectionedObjects;
@property (nonatomic, strong) NSMutableArray *dataSourceResponses;
@property (nonatomic, strong) NSMutableArray *dataSourcesBySectionIndex;
@property (nonatomic, strong) NSMutableArray *mutableSectionTitles;
@property (nonatomic, strong, readwrite) NSArray *sectionTitles;
@property (nonatomic, copy, readwrite) NSArray *dataSources;
@property (nonatomic, assign, readwrite) BOOL isFetching;


@end

@implementation ICMultiDataSource

- (instancetype)initWithDataSources:(NSArray *)dataSources {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.dataSources = dataSources;
    
    return self;
}

- (void)setDataSources:(NSArray *)dataSources {
    [_dataSources enumerateObjectsUsingBlock:^(id<ICDataSource> dataSource, NSUInteger idx, BOOL *stop) {
        dataSource.delegate = nil;
    }];
    _dataSources = dataSources;
    for (id<ICDataSource> dataSource in _dataSources) {
        dataSource.delegate = self;
    }
}

#pragma mark - exposing data

- (NSArray *)allObjects {
    NSMutableArray *allObjects = [NSMutableArray array];
    NSInteger numberOfSections = [self numberOfSections];
    for (NSInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {
        NSInteger numberOfObjectsInSection = [self numberOfObjectsInSection:sectionIndex];
        for (NSInteger objectIndex = 0; objectIndex < numberOfObjectsInSection; objectIndex++) {
            [allObjects addObject:[self objectAtIndexPath:[NSIndexPath indexPathForRow:objectIndex inSection:sectionIndex]]];
        }
    }
    return allObjects;
}

- (NSUInteger)numberOfSections {
    return _sectionedObjects.count;
}

- (NSUInteger)numberOfObjectsInSection:(NSUInteger)section {
    return [_sectionedObjects[section] count];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return _sectionedObjects[indexPath.section][indexPath.row];
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

#pragma mark - fetching data

- (void)fetchData {
    _isFetching = YES;
    if ([_delegate respondsToSelector:@selector(dataSourceWillLoadData:)]) {
        [_delegate dataSourceWillLoadData:self];
    }

    self.dataSourceResponses = [_dataSources mutableCopy];
    self.dataSourcesBySectionIndex = [[_dataSources arrayByTransformingObjectsUsingBlock:^id(id object) {
        return [NSNull null];
    }] mutableCopy];
    self.mutableSectionTitles = [[_dataSources arrayByTransformingObjectsUsingBlock:^id(id object) {
        return @"";
    }] mutableCopy];

    
    [_dataSources enumerateObjectsUsingBlock:^(id<ICDataSource> dataSource, NSUInteger idx, BOOL *stop) {
        [dataSource fetchData];
    }];
}

- (void)dataSourceFinishedLoading:(id<ICDataSource>)dataSource {
    [self handleResponseFromDataSource:dataSource];
}

- (void) dataSource:(id<ICDataSource>)dataSource failedWithError:(NSError *)error {
    [self handleResponseFromDataSource:dataSource];
}

- (NSArray *)allSectionsInDataSource:(id)dataSource {
    NSMutableArray *allSections = [NSMutableArray array];
    NSInteger numberOfSections = [dataSource numberOfSections];
    for (NSInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {
        
        NSMutableArray *currentSection = [NSMutableArray array];
        NSInteger numberOfObjectsInSection = [dataSource numberOfObjectsInSection:sectionIndex];
        for (NSInteger objectIndex = 0; objectIndex < numberOfObjectsInSection; objectIndex++) {
            
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:objectIndex inSection:sectionIndex];
            [currentSection addObject:[dataSource objectAtIndexPath:currentIndexPath]];
        }
        [allSections addObject:currentSection];
    }
    return allSections;
}

- (void)handleResponseFromDataSource:(id<ICDataSource>)dataSource {
    NSUInteger indexOfDataSource = [self.dataSourceResponses indexOfObject:dataSource];
    if (indexOfDataSource == NSNotFound) {
        return;
    }
    
    if (self.preserveSectionsInSubDataSources) {
        NSArray *allSections = [self allSectionsInDataSource:dataSource];
        {
            NSUInteger currentIndex = indexOfDataSource;
            [self.dataSourceResponses removeObjectAtIndex:currentIndex];
            for (NSArray *section in allSections) {
                [self.dataSourceResponses insertObject:section atIndex:currentIndex];
                currentIndex++;
            }
        }
        {
            NSUInteger currentIndex = indexOfDataSource;
            [self.dataSourcesBySectionIndex removeObjectAtIndex:currentIndex];
            for (NSInteger index = 0; index < allSections.count; index++) {
                [self.dataSourcesBySectionIndex insertObject:dataSource atIndex:currentIndex];
                currentIndex++;
            }
        }
        {
            NSUInteger currentIndex = indexOfDataSource;
            [self.mutableSectionTitles removeObjectAtIndex:currentIndex];
            NSArray *sectionTitles = dataSource.sectionTitles;
            for (NSString *sectionTitle in sectionTitles) {
                [self.mutableSectionTitles insertObject:sectionTitle atIndex:currentIndex];
                currentIndex++;
            }
        }
    } else {
        [self.dataSourceResponses replaceObjectAtIndex:indexOfDataSource withObject:dataSource.allObjects];
        [self.dataSourcesBySectionIndex replaceObjectAtIndex:indexOfDataSource withObject:dataSource];
        [self.mutableSectionTitles replaceObjectAtIndex:indexOfDataSource withObject:dataSource.name?:@""];
    }
    
    NSIndexSet *onlyArraysIndexSet = [self.dataSourceResponses indexesOfObjectsPassingTest:^BOOL(id object, NSUInteger idx, BOOL *stop) {
        return [object isKindOfClass:[NSArray class]];
    }];
    
    self.sectionedObjects = [self.dataSourceResponses objectsAtIndexes:onlyArraysIndexSet];
    self.sectionTitles = [self.mutableSectionTitles objectsAtIndexes:onlyArraysIndexSet];
    
    [self informDelegateIfCompleted];
}

- (void) informDelegateIfCompleted {
    if ([_dataSourceResponses allObjectsPassTest:^BOOL(id object) { return [object isKindOfClass:[NSArray class]]; }]) {
        self.sectionedObjects = _dataSourceResponses;
        self.dataSourceResponses = nil;
        _isFetching = NO;
        if ([_delegate respondsToSelector:@selector(dataSourceFinishedLoading:)]) {
            [_delegate dataSourceFinishedLoading:self];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(dataSourceDidPartiallyLoad:)]) {
            [_delegate dataSourceDidPartiallyLoad:self];
        }
    }
}

- (void)willDisplayObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger sectionIndex = indexPath.section;
    id<ICDataSource> dataSourceAtIndex = self.dataSourcesBySectionIndex[sectionIndex];
    if (![dataSourceAtIndex isKindOfClass:[ICPaginatedDataSource class]]) {
        return;
    }
    if ([self numberOfObjectsInSection:sectionIndex] - 1 != indexPath.row) {
        return;
    }
    if (//EITHER this is the last section OR
        self.dataSourcesBySectionIndex.count - 1 == sectionIndex ||
        //the next data source is a different one, meaning this is last section for this datasource
        self.dataSourcesBySectionIndex[sectionIndex+1] != dataSourceAtIndex) {
        
        self.dataSourceResponses = [self.sectionedObjects mutableCopy];
        NSIndexSet *sectionIndexesForPaginator = [self.dataSourcesBySectionIndex indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return (obj == dataSourceAtIndex);
        }];
        
        [self.dataSourceResponses removeObjectsAtIndexes:sectionIndexesForPaginator];
        [self.dataSourceResponses insertObject:dataSourceAtIndex atIndex:sectionIndexesForPaginator.firstIndex];
        
        self.isFetching = YES;
        [(ICPaginatedDataSource*)dataSourceAtIndex fetchNextPage];
        
    }
}

- (id<ICDataSource>)dataSourceAtSectionIndex:(NSUInteger)sectionIndex {
    return self.dataSourcesBySectionIndex[sectionIndex];
}

@end
