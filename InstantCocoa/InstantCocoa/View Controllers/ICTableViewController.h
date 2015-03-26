//
//  ICTableViewController.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/11/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICViewController.h"
#import "ICDataSource.h"

@class ICLoadingTableViewCell;

@protocol ICTableCellConfigurationDelegate <NSObject>

@optional
- (void)configureCell:(UITableViewCell*)cell withObject:(id)object;
- (void)configureLoadingCell:(ICLoadingTableViewCell *)loadingCell;
- (void)configureNoResultsCell:(UITableViewCell *)noResultsCell;
- (void)configureCell:(UITableViewCell *)cell withError:(NSError*)error;

@end


@interface ICTableViewController : ICViewController <UITableViewDelegate, UITableViewDataSource, ICTableCellConfigurationDelegate, ICDataSourceDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<ICTableCellConfigurationDelegate> cellConfigurationDelegate;
@property (nonatomic, assign) Class defaultCellClass;
@property (nonatomic, assign) BOOL clearsSelectionOnViewWillAppear;


- (void)configureCell:(UITableViewCell *)cell withError:(NSError*)error;
- (void)configureLoadingCell:(ICLoadingTableViewCell *)loadingCell;
- (void)configureCell:(UITableViewCell *)cell withObject:(id)object;

- (void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass;

@end
