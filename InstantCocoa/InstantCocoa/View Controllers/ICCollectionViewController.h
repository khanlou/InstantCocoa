//
//  ICCollectionViewController.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 7/13/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICViewController.h"
#import "ICDataSource.h"

@class ICLoadingCollectionViewCell, ICCollectionViewCell;

@protocol ICCollectionCellConfigurationDelegate <NSObject>

@optional
- (void)configureCell:(UICollectionViewCell *)cell withObject:(id)object;
- (void)configureLoadingCell:(ICLoadingCollectionViewCell *)loadingCell;
- (void)configureNoResultsCell:(UICollectionViewCell *)noResultsCell;
- (void)configureCell:(UICollectionViewCell *)cell withError:(NSError*)error;

@end


@interface ICCollectionViewController : ICViewController <UICollectionViewDataSource, UICollectionViewDelegate, ICCollectionCellConfigurationDelegate, ICDataSourceDelegate>

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) id<ICCollectionCellConfigurationDelegate> cellConfigurationDelegate;
@property (nonatomic, assign) Class defaultCellClass;
@property (nonatomic, assign) BOOL clearsSelectionOnViewWillAppear;


- (void)configureCell:(UICollectionViewCell *)cell withError:(NSError*)error;
- (void)configureLoadingCell:(ICLoadingCollectionViewCell *)loadingCell;
- (void)configureCell:(UICollectionViewCell *)cell withObject:(id)object;

- (void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass;

@end
