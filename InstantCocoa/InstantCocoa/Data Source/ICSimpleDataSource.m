//
//  ICSimpleDataSource.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/2/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICSimpleDataSource.h"
#import "NSArray+Convenience.h"

@interface ICSimpleDataSource ()

@property (nonatomic, strong, readwrite) NSArray *objects;

@end

@implementation ICSimpleDataSource

- (instancetype)initWithObjects:(NSArray*)objects {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.objects = objects;
    
    return self;
}

- (NSArray *)sectionTitles {
    return @[self.name ?: @""];
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSUInteger)numberOfObjectsInSection:(NSUInteger)section {
    return _objects.count;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return _objects[indexPath.row];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    NSUInteger indexOfObject = [self.objects indexOfObject:object];
    if (indexOfObject == NSNotFound) {
        return nil;
    }
    return [NSIndexPath indexPathForRow:indexOfObject inSection:0];
}

- (void) fetchData {
    if ([_delegate respondsToSelector:@selector(dataSourceWillLoadData:)]) {
        [_delegate dataSourceWillLoadData:self];
    }
    if ([_delegate respondsToSelector:@selector(dataSourceFinishedLoading:)]) {
        [_delegate dataSourceFinishedLoading:self];
    }
}

- (NSArray *)allObjects {
    return self.objects ?: @[];
}

@end
