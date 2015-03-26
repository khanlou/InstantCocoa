//
//  ICCollectionViewControllerTests.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 7/15/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ICCollectionViewController.h"
#import "ICSimpleDataSource.h"
#import <OCMock.h>
#import "ICAsyncTestCase.h"
#import "ICPlaceholders.h"
#import "ICLoadingCollectionViewCell.h"

@interface ICCVTestPlaceholder : NSObject @end

@implementation ICCVTestPlaceholder

+ (NSString *)modelName {
    return @"Placeholder";
}

@end

@interface ICPlaceholderCVCell : UICollectionViewCell @end
@implementation ICPlaceholderCVCell @end

@protocol ICCVTestCellConfigurator <ICCollectionCellConfigurationDelegate>

- (void)configureCell:(UICollectionViewCell *)cell withPlaceholder:(id)placeholder;
- (void)collectionView:(UICollectionView *)collectionView didSelectPlaceholder:(id)placeholder;

@end

@interface ICCollectionViewControllerTests : ICAsyncTestCase

@property (nonatomic, strong) ICSimpleDataSource *dataSource;

@end

@implementation ICCollectionViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.dataSource = [[ICSimpleDataSource alloc] initWithObjects:@[
                                                                    @"a string",
                                                                    @341,
                                                                    [ICCVTestPlaceholder new],
                                                                    [NSError new],
                                                                    [ICLoadingPlaceholder new],
                                                                    [ICNoResultsPlaceholder new],
                                                                    ]];
    
}

- (void)testDataSourceUsage {
    ICCollectionViewController *collectionViewController = [[ICCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
    collectionViewController.dataSource = self.dataSource;
    
    [collectionViewController.collectionView reloadData];
    
    XCTAssert(collectionViewController.collectionView.numberOfSections == [self.dataSource numberOfSections], @"The collection view should report the same number of sections as the data source");
    XCTAssert([collectionViewController.collectionView numberOfItemsInSection:0] == [self.dataSource numberOfObjectsInSection:0], @"The collection view should report the same number of rows as the data source");
}

- (void)testConfigurationSelector {
    id mockConfiguationDelegate = [OCMockObject mockForProtocol:@protocol(ICCVTestCellConfigurator)];
    [[mockConfiguationDelegate expect] configureCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[UICollectionViewCell class]]; }] withObject:@"a string"];
    [[mockConfiguationDelegate expect] configureCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[UICollectionViewCell class]]; }] withObject:@341];
    [[mockConfiguationDelegate expect] configureCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[ICPlaceholderCVCell class]]; }] withPlaceholder:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[ICCVTestPlaceholder class]]; }]];
    [[mockConfiguationDelegate expect] configureCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[UICollectionViewCell class]]; }] withError:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[NSError class]]; }]];
    [[mockConfiguationDelegate expect] configureLoadingCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[ICLoadingCollectionViewCell class]]; }]];
    [[mockConfiguationDelegate expect] configureNoResultsCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[UICollectionViewCell class]]; }]];
    
    ICCollectionViewController *collectionViewController = [[ICCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
    collectionViewController.dataSource = self.dataSource;
    [collectionViewController registerCellClass:[ICPlaceholderCVCell class] forModelClass:[ICCVTestPlaceholder class]];
    collectionViewController.cellConfigurationDelegate = mockConfiguationDelegate;
    [[[UIApplication sharedApplication] keyWindow] addSubview:collectionViewController.view];
    
    [collectionViewController.collectionView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertNoThrow([mockConfiguationDelegate verify], @"Collection View Controllers should call the proper methods with various data source objects");
        
        [collectionViewController.view removeFromSuperview];
        
        [self complete];
    });
    [self waitForCompletion];
}

- (void)testDefaultCell {
    id mockConfiguationDelegate = [OCMockObject mockForProtocol:@protocol(ICCollectionCellConfigurationDelegate)];
    [[mockConfiguationDelegate expect] configureCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[UICollectionViewCell class]]; }] withObject:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[ICCVTestPlaceholder class]]; }]];
    
    ICCollectionViewController *collectionViewController = [[ICCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
    collectionViewController.dataSource = [[ICSimpleDataSource alloc] initWithObjects:@[[ICCVTestPlaceholder new]]];
    collectionViewController.defaultCellClass = [ICPlaceholderCVCell class];
    collectionViewController.cellConfigurationDelegate = mockConfiguationDelegate;
    [[[UIApplication sharedApplication] keyWindow] addSubview:collectionViewController.view];
    
    [collectionViewController.collectionView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        XCTAssertNoThrow([mockConfiguationDelegate verify], @"Collection View Controllers should use the default cell class if it's set");
        
        [collectionViewController.view removeFromSuperview];
        
        [self complete];
    });
    [self waitForCompletion];
}

- (void)testCellSelection {
    id mockConfiguationDelegate = [OCMockObject niceMockForProtocol:@protocol(ICCVTestCellConfigurator)];
    
    ICCollectionViewController *collectionViewController = [[ICCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
    collectionViewController.dataSource = self.dataSource;
    collectionViewController.cellConfigurationDelegate = mockConfiguationDelegate;
    [[[UIApplication sharedApplication] keyWindow] addSubview:collectionViewController.view];
    
    [[mockConfiguationDelegate expect] collectionView:collectionViewController.collectionView didSelectPlaceholder:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[ICCVTestPlaceholder class]]; }]];
    
    [collectionViewController.collectionView reloadData];
    
    [collectionViewController collectionView:collectionViewController.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertNoThrow([mockConfiguationDelegate verify], @"Collection View Controllers should call the correct custom selection method");
        
        [collectionViewController.view removeFromSuperview];
        
        [self complete];
    });
    [self waitForCompletion];
}

@end
