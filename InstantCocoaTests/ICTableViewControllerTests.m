//
//  ICTableViewControllerTest.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 7/13/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ICTableViewController.h"
#import "ICSimpleDataSource.h"
#import <OCMock.h>
#import "ICAsyncTestCase.h"
#import "ICPlaceholders.h"
#import "ICLoadingTableViewCell.h"

@interface ICTestPlaceholder : NSObject @end

@implementation ICTestPlaceholder

+ (NSString *)modelName {
    return @"Placeholder";
}

@end

@interface ICPlaceholderCell : UITableViewCell @end
@implementation ICPlaceholderCell @end

@protocol ICTestCellConfigurator <ICTableCellConfigurationDelegate>

- (void)configureCell:(UITableViewCell *)cell withPlaceholder:(id)placeholder;
- (void)tableView:(UITableView *)tableView didSelectPlaceholder:(id)placeholder;

@end

@interface ICMockCellConfigurator : NSObject<ICTableCellConfigurationDelegate>

@property (nonatomic, assign) BOOL calledHeightSelector;

@end

@implementation ICMockCellConfigurator

- (CGFloat)tableView:(UITableView *)tableView heightForPlaceholder:(ICTestPlaceholder *)placeholder  {
    self.calledHeightSelector = YES;
    return 70.0f;
}

- (void)configureCell:(UITableViewCell *)cell withObject:(id)object {
    
}

@end

@interface ICTableViewControllerTest : ICAsyncTestCase

@property (nonatomic, strong) ICSimpleDataSource *dataSource;

@end

@implementation ICTableViewControllerTest

- (void)setUp {
    [super setUp];
    
    self.dataSource = [[ICSimpleDataSource alloc] initWithObjects:@[
                                                                    @"a string",
                                                                    @341,
                                                                    [ICTestPlaceholder new],
                                                                    [NSError new],
                                                                    [ICLoadingPlaceholder new],
                                                                    [ICNoResultsPlaceholder new],
                                                                    ]];
}

- (void)testDataSourceUsage {
    ICTableViewController *tableViewController = [[ICTableViewController alloc] init];
    tableViewController.dataSource = self.dataSource;
    
    [tableViewController.tableView reloadData];
    
    XCTAssert(tableViewController.tableView.numberOfSections == [self.dataSource numberOfSections], @"The tableview should report the same number of sections as the data source");
    XCTAssert([tableViewController.tableView numberOfRowsInSection:0] == [self.dataSource numberOfObjectsInSection:0], @"The tableview should report the same number of rows as the data source");
}

- (void)testConfigurationSelector {
    id mockConfiguationDelegate = [OCMockObject mockForProtocol:@protocol(ICTestCellConfigurator)];
    [[mockConfiguationDelegate expect] configureCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[UITableViewCell class]]; }] withObject:@"a string"];
    [[mockConfiguationDelegate expect] configureCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[UITableViewCell class]]; }] withObject:@341];
    [[mockConfiguationDelegate expect] configureCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[ICPlaceholderCell class]]; }] withPlaceholder:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[ICTestPlaceholder class]]; }]];
    [[mockConfiguationDelegate expect] configureCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[UITableViewCell class]]; }] withError:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[NSError class]]; }]];
    [[mockConfiguationDelegate expect] configureLoadingCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[ICLoadingTableViewCell class]]; }]];
    [[mockConfiguationDelegate expect] configureNoResultsCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[UITableViewCell class]]; }]];
    
    ICTableViewController *tableViewController = [[ICTableViewController alloc] init];
    tableViewController.dataSource = self.dataSource;
    [tableViewController registerCellClass:[ICPlaceholderCell class] forModelClass:[ICTestPlaceholder class]];
    tableViewController.cellConfigurationDelegate = mockConfiguationDelegate;
    [[[UIApplication sharedApplication] keyWindow] addSubview:tableViewController.view];

    [tableViewController.tableView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertNoThrow([mockConfiguationDelegate verify], @"Table View Controllers should call the proper methods with various data source objects");
        
        [tableViewController.view removeFromSuperview];

        [self complete];
    });
    [self waitForCompletion];
}

- (void)testDefaultCell {
    id mockConfiguationDelegate = [OCMockObject mockForProtocol:@protocol(ICTableCellConfigurationDelegate)];
    [[mockConfiguationDelegate expect] configureCell:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[ICPlaceholderCell class]]; }] withObject:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[ICTestPlaceholder class]]; }]];
    
    ICTableViewController *tableViewController = [[ICTableViewController alloc] init];
    tableViewController.dataSource = [[ICSimpleDataSource alloc] initWithObjects:@[[ICTestPlaceholder new]]];
    tableViewController.defaultCellClass = [ICPlaceholderCell class];
    tableViewController.cellConfigurationDelegate = mockConfiguationDelegate;
    [[[UIApplication sharedApplication] keyWindow] addSubview:tableViewController.view];
    
    [tableViewController.tableView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertNoThrow([mockConfiguationDelegate verify], @"Table View Controllers should use the default cell class if it's set");
        
        [tableViewController.view removeFromSuperview];
        
        [self complete];
    });
    [self waitForCompletion];
}

- (void)testCellSelection {
    id mockConfiguationDelegate = [OCMockObject niceMockForProtocol:@protocol(ICTestCellConfigurator)];
    
    ICTableViewController *tableViewController = [[ICTableViewController alloc] init];
    tableViewController.dataSource = self.dataSource;
    tableViewController.cellConfigurationDelegate = mockConfiguationDelegate;
    [[[UIApplication sharedApplication] keyWindow] addSubview:tableViewController.view];
    
    [[mockConfiguationDelegate expect] tableView:tableViewController.tableView didSelectPlaceholder:[OCMArg checkWithBlock:^BOOL(id obj) { return [obj isKindOfClass:[ICTestPlaceholder class]]; }]];
    
    [tableViewController.tableView reloadData];
    
    [tableViewController tableView:tableViewController.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertNoThrow([mockConfiguationDelegate verify], @"Table View Controllers should call the correct custom selection method");
        
        [tableViewController.view removeFromSuperview];
        
        [self complete];
    });
    [self waitForCompletion];
}

- (void)testHeightSelector {
    ICMockCellConfigurator *cellConfigurator = [ICMockCellConfigurator new];
    
    ICTableViewController *tableViewController = [[ICTableViewController alloc] init];
    tableViewController.dataSource = self.dataSource;
    tableViewController.cellConfigurationDelegate = cellConfigurator;
    [[[UIApplication sharedApplication] keyWindow] addSubview:tableViewController.view];
    
    [tableViewController.tableView reloadData];
    
    [tableViewController tableView:tableViewController.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssert(cellConfigurator.calledHeightSelector, @"should call height selector");
        
        [tableViewController.view removeFromSuperview];
        
        [self complete];
    });
    [self waitForCompletion];
}


@end
