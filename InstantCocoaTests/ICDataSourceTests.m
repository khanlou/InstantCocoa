//
//  ICDataSourceTests.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/5/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ICSimpleDataSource.h"
#import "ICSectionedDataSource.h"
#import "ICMultiDataSource.h"

@interface ICDataSourceTests : XCTestCase

@end

@implementation ICDataSourceTests

- (void)testSimpleDataSource {
    ICSimpleDataSource *simpleDataSource = [[ICSimpleDataSource alloc] initWithObjects:@[@1, @2, @"third object"]];
    simpleDataSource.name = @"Test Data Source";
    
    XCTAssert([simpleDataSource numberOfSections] == 1, @"Simple data sources should have 1 section");
    XCTAssert([simpleDataSource numberOfObjectsInSection:0] == 3, @"Simple data sources initialized with 3 objects should have 3 objects in the first section.");
    
    XCTAssert(simpleDataSource.sectionTitles.count == 1, @"Simple data sources should have 1 section titles");
    XCTAssertEqualObjects(simpleDataSource.sectionTitles[0], @"Test Data Source", @"Simple data sources should have a section titles based on the data source's name");
    
    NSIndexPath *indexPathOfString = [simpleDataSource indexPathForObject:@"third object"];
    XCTAssert(indexPathOfString.item == 2, @"-indexPathForObject: should return the right section.");
    XCTAssert(indexPathOfString.section == 0, @"-indexPathForObject: should return the right index.");
}

- (void)testSectionedDataSource {
    ICSimpleDataSource *backingDataSource = [[ICSimpleDataSource alloc] initWithObjects:@[
                                                                                         @{@"category": @"first"},
                                                                                         @{@"category": @"first"},
                                                                                         @{@"category": @"second"},
                                                                                         @{@"category": @"third"},
                                                                                         ]];
    ICSectionedDataSource *sectionedDataSource = [[ICSectionedDataSource alloc] initWithDataSource:backingDataSource
                                                                                     sectioningKey:@"category"
                                                                                   sortDescriptors:nil];
    [sectionedDataSource fetchData];
    XCTAssert([sectionedDataSource numberOfSections] == 3, @"Sectioned data sources should be able to create multiple sections");
    XCTAssert([sectionedDataSource numberOfObjectsInSection:0] == 2, @"Sectioned data sources should contain the correct number of objects in each section");
    XCTAssert([sectionedDataSource numberOfObjectsInSection:1] == 1, @"Sectioned data sources should contain the correct number of objects in each section");
    XCTAssert([sectionedDataSource numberOfObjectsInSection:2] == 1, @"Sectioned data sources should contain the correct number of objects in each section");
    
    XCTAssert(sectionedDataSource.sectionTitles.count == 3, @"Sectioned data sources should be able to create multiple sections");
    XCTAssertEqualObjects(sectionedDataSource.sectionTitles[0], @"first", @"Sectioned data sources should pull section titles from the sectioning key's value");
    XCTAssertEqualObjects(sectionedDataSource.sectionTitles[1], @"second", @"Sectioned data sources should pull section titles from the sectioning key's value");
    XCTAssertEqualObjects(sectionedDataSource.sectionTitles[2], @"third", @"Sectioned data sources should pull section titles from the sectioning key's value");
    
    NSArray *allObjects = [sectionedDataSource allObjects];
    XCTAssert(allObjects.count == 4, @"allObjects should have all objects");
    
    NSIndexPath *indexPathOfDictionary = [sectionedDataSource indexPathForObject:@{@"category": @"third"}];
    XCTAssert(indexPathOfDictionary.section == 2, @"-indexPathForObject: should return the right section.");
    XCTAssert(indexPathOfDictionary.item == 0, @"-indexPathForObject: should return the right index.");
}

- (void)testSectionedDataSourceWithSorting {
    ICSimpleDataSource *backingDataSource = [[ICSimpleDataSource alloc] initWithObjects:@[
                                                                                          @{@"category": @"beta"},
                                                                                          @{@"category": @"alpha"},
                                                                                          @{@"category": @"gamma"},
                                                                                          @{@"category": @"alpha"},
                                                                                          ]];
    ICSectionedDataSource *sectionedDataSource = [[ICSectionedDataSource alloc] initWithDataSource:backingDataSource
                                                                                     sectioningKey:@"category"
                                                                                   sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES]]];
    [sectionedDataSource fetchData];
    XCTAssert([sectionedDataSource numberOfSections] == 3, @"Sectioned data sources should be able to create multiple sections");
    XCTAssert([sectionedDataSource numberOfObjectsInSection:0] == 2, @"Sectioned data sources should contain the correct number of objects in each section");
    XCTAssert([sectionedDataSource numberOfObjectsInSection:1] == 1, @"Sectioned data sources should contain the correct number of objects in each section");
    XCTAssert([sectionedDataSource numberOfObjectsInSection:2] == 1, @"Sectioned data sources should contain the correct number of objects in each section");
    
    XCTAssert(sectionedDataSource.sectionTitles.count == 3, @"Sectioned data sources should be able to create multiple sections");
    XCTAssertEqualObjects(sectionedDataSource.sectionTitles[0], @"alpha", @"Sectioned data sources should pull section titles from the sectioning key's value");
    XCTAssertEqualObjects(sectionedDataSource.sectionTitles[1], @"beta", @"Sectioned data sources should pull section titles from the sectioning key's value");
    XCTAssertEqualObjects(sectionedDataSource.sectionTitles[2], @"gamma", @"Sectioned data sources should pull section titles from the sectioning key's value");
    
    NSArray *allObjects = [sectionedDataSource allObjects];
    XCTAssert(allObjects.count == 4, @"allObjects should have all objects");

}

- (void)testSectionedDataSourceWithFirstCharacter {
    ICSimpleDataSource *backingDataSource = [[ICSimpleDataSource alloc] initWithObjects:@[
                                                                                          @{@"name": @"aardvark"},
                                                                                          @{@"name": @"anteater"},
                                                                                          @{@"name": @"bee"},
                                                                                          @{@"name": @"bear"},
                                                                                          @{@"name": @"blue jay"},
                                                                                          @{@"name": @"cow"},
                                                                                          @{@"name": @"crow"},
                                                                                          ]];
    ICSectionedDataSource *sectionedDataSource = [[ICSectionedDataSource alloc] initWithDataSource:backingDataSource
                                                                                     sectioningKey:@"name.firstCharacter"
                                                                                   sortDescriptors:nil];

    [sectionedDataSource fetchData];

    XCTAssert([sectionedDataSource numberOfSections] == 3, @"Sectioned data sources should support nested keypaths and the first character of a key");
    XCTAssert([sectionedDataSource numberOfObjectsInSection:0] == 2, @"Sectioned data sources should contain the correct number of objects in each section");
    XCTAssert([sectionedDataSource numberOfObjectsInSection:1] == 3, @"Sectioned data sources should contain the correct number of objects in each section");
    XCTAssert([sectionedDataSource numberOfObjectsInSection:2] == 2, @"Sectioned data sources should contain the correct number of objects in each section");
    
    XCTAssert(sectionedDataSource.sectionTitles.count == 3, @"Sectioned data sources should support nested keypaths and the first character of a key");
    XCTAssertEqualObjects(sectionedDataSource.sectionTitles[0], @"a", @"Sectioned data sources should pull section titles from the sectioning key's value");
    XCTAssertEqualObjects(sectionedDataSource.sectionTitles[1], @"b", @"Sectioned data sources should pull section titles from the sectioning key's value");
    XCTAssertEqualObjects(sectionedDataSource.sectionTitles[2], @"c", @"Sectioned data sources should pull section titles from the sectioning key's value");
    
    NSArray *allObjects = [sectionedDataSource allObjects];
    XCTAssert(allObjects.count == 7, @"allObjects should have all objects");
}

- (void)testMultiDataSource {
    
    ICSimpleDataSource *simpleDataSource = [[ICSimpleDataSource alloc] initWithObjects:@[@1, @2, @"third object"]];
    simpleDataSource.name = @"three object data source";

    ICSimpleDataSource *secondSimpleDataSource = [[ICSimpleDataSource alloc] initWithObjects:@[@3, @2, @"other object", @"fourth object"]];
    secondSimpleDataSource.name = @"four object data source";

    ICMultiDataSource *multiDataSource = [[ICMultiDataSource alloc] initWithDataSources:@[simpleDataSource, secondSimpleDataSource]];
    [multiDataSource fetchData];
    
    XCTAssert([multiDataSource numberOfSections] == 2, @"Multi data sources should create a new section for each sub data source");
    XCTAssert([multiDataSource numberOfObjectsInSection:0] == 3, @"Each sub data source's section should contain the same number of objects as its corresponding section");
    XCTAssert([multiDataSource numberOfObjectsInSection:1] == 4, @"Each sub data source's section should contain the same number of objects as its corresponding section");
    XCTAssert(multiDataSource.allObjects.count == 7, @"Multi data sources should be able to concatenate all the objects inside them");
    
    XCTAssert(multiDataSource.sectionTitles.count == 2, @"Multi data sources should pull section titles from their sub data sources");
    XCTAssertEqualObjects(multiDataSource.sectionTitles[0], @"three object data source", @"Multi data sources should pull section titles from their sub data sources");
    XCTAssertEqualObjects(multiDataSource.sectionTitles[1], @"four object data source", @"Multi data sources should pull section titles from their sub data sources");
    
    NSIndexPath *indexPathOfString = [multiDataSource indexPathForObject:@"other object"];
    XCTAssert(indexPathOfString.section == 1, @"-indexPathForObject: should return the right section.");
    XCTAssert(indexPathOfString.item == 2, @"-indexPathForObject: should return the right index.");
}

- (void)testMultiWithPreserveSubSections {
    
    ICSimpleDataSource *backingDataSource = [[ICSimpleDataSource alloc] initWithObjects:@[
                                                                                          @{@"category": @"first"},
                                                                                          @{@"category": @"first"},
                                                                                          @{@"category": @"second"},
                                                                                          @{@"category": @"third"},
                                                                                          ]];
    ICSectionedDataSource *sectionedDataSource = [[ICSectionedDataSource alloc] initWithDataSource:backingDataSource
                                                                                     sectioningKey:@"category"
                                                                                   sortDescriptors:nil];
    

    ICSimpleDataSource *secondSimpleDataSource = [[ICSimpleDataSource alloc] initWithObjects:@[@3, @2, @"other object", @"fourth object"]];
    secondSimpleDataSource.name = @"four object data source";
    
    ICMultiDataSource *multiDataSource = [[ICMultiDataSource alloc] initWithDataSources:@[sectionedDataSource, secondSimpleDataSource]];
    multiDataSource.preserveSectionsInSubDataSources = YES;;
    [multiDataSource fetchData];
    
    XCTAssert([multiDataSource numberOfSections] == 4, @"Multi data sources should be able to preserve sub data sources");
    XCTAssert([multiDataSource numberOfObjectsInSection:0] == 2, @"Multi data sources should contain the correct number of objects in each section");
    XCTAssert([multiDataSource numberOfObjectsInSection:1] == 1, @"Multi data sources should contain the correct number of objects in each section");
    XCTAssert([multiDataSource numberOfObjectsInSection:2] == 1, @"Multi data sources should contain the correct number of objects in each section");
    XCTAssert([multiDataSource numberOfObjectsInSection:3] == 4, @"Multi data sources should contain the correct number of objects in each section");
    XCTAssert(multiDataSource.allObjects.count == 8, @"Multi data sources should be able to concatenate all the objects inside them");
    
    XCTAssert(multiDataSource.sectionTitles.count == 4, @"Multi data sources should pull section titles from their sub data sources");
    XCTAssertEqualObjects(multiDataSource.sectionTitles[0], @"first", @"Multi data sources should pull section titles from their sub data source's sections");
    XCTAssertEqualObjects(multiDataSource.sectionTitles[1], @"second", @"Multi data sources should pull section titles from their sub data source's sections");
    XCTAssertEqualObjects(multiDataSource.sectionTitles[2], @"third", @"Multi data sources should pull section titles from their sub data source's sections");
    XCTAssertEqualObjects(multiDataSource.sectionTitles[3], @"four object data source", @"Multi data sources should pull section titles from their sub data source's sections");

    NSIndexPath *indexPathOfDictionary = [multiDataSource indexPathForObject:@{@"category": @"third"}];
    XCTAssert(indexPathOfDictionary.section == 2, @"-indexPathForObject: should return the right section.");
    XCTAssert(indexPathOfDictionary.item == 0, @"-indexPathForObject: should return the right index.");

}

@end
