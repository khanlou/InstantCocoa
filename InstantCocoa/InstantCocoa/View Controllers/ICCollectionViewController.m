//
//  ICCollectionViewController.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 7/13/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICCollectionViewController.h"
#import "ICRemoteDataSource.h"
#import "ICMultiDataSource.h"
#import "ICModel.h"
#import "ICInflector.h"
#import "ICPlaceholders.h"
#import "ICLoadingCollectionViewCell.h"
#import "ICCollectionViewCell.h"
#import "ICPaginatedDataSource.h"

@interface ICCollectionViewController ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *registeredCellsForIdentifier;
@property (nonatomic, strong) UICollectionViewLayout *layout;

@end

@implementation ICCollectionViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super init];
    if (!self) return nil;
    
    _clearsSelectionOnViewWillAppear = YES;
    _layout = layout;
    
    return self;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        [self view];
    }
    return _collectionView;
}

- (void)loadView {
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:_layout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    if (!self.cellConfigurationDelegate) {
        self.cellConfigurationDelegate = self;
    }
    if (!self.defaultCellClass) {
        self.defaultCellClass = [UICollectionViewCell class];
    }
    
    self.view = collectionView;
    self.collectionView = collectionView;
    
    
    [self registerCellClass:[ICLoadingCollectionViewCell class] forModelClass:[ICLoadingPlaceholder class]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.clearsSelectionOnViewWillAppear) {
        [self.collectionView.indexPathsForSelectedItems enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }];
    }
}

- (NSMutableDictionary *)registeredCellsForIdentifier {
    if (!_registeredCellsForIdentifier) {
        self.registeredCellsForIdentifier = [NSMutableDictionary dictionary];
    }
    return _registeredCellsForIdentifier;
}

- (void) registerCellClass:(Class)cellClass forModelClass:(Class)modelClass {
    NSString *modelClassName = NSStringFromClass(modelClass);
    self.registeredCellsForIdentifier[modelClassName] = cellClass;
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:modelClassName];
}

- (void) setDataSource:(id<ICDataSource>)dataSource {
    [super setDataSource:dataSource];
    if (![dataSource delegate]) {
        dataSource.delegate = self;
    }
}

- (void)setDefaultCellClass:(Class)defaultCellClass {
    NSAssert([defaultCellClass isSubclassOfClass:[UICollectionViewCell class]], @"ICCollectionViewController's defaultCellClass must be a subclass of UICollectionViewCell");
    _defaultCellClass = defaultCellClass;
}

- (void)configureCell:(UICollectionViewCell *)cell withObject:(id)object {
    //default no-op
}

- (void)configureCell:(UICollectionViewCell *)cell withError:(NSError*)error {
    if ([cell respondsToSelector:@selector(textLabel)]) {
        ICCollectionViewCell *cellWithTextLabel = (ICCollectionViewCell *)cell;
        cellWithTextLabel.textLabel.text = error.localizedDescription;
    }
}

- (void)configureLoadingCell:(ICLoadingCollectionViewCell *)loadingCell {
    [loadingCell.activityIndicator startAnimating];
}

- (void)configureNoResultsCell:(UICollectionViewCell *)noResultsCell {
    if ([noResultsCell respondsToSelector:@selector(textLabel)]) {
        ICCollectionViewCell *cellWithTextLabel = (ICCollectionViewCell *)noResultsCell;
        cellWithTextLabel.textLabel.text = @"No Results";
    }
}

- (void)dataSourceWillLoadData:(id<ICDataSource>)dataSource {
    //default no-op
}

- (void)dataSourceDidPartiallyLoad:(id<ICDataSource>)dataSource {
    [self.collectionView reloadData];
}

- (void)dataSourceFinishedLoading:(id<ICDataSource>)dataSource {
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfObjectsInSection:section];
}

//this method is ios 8 only
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(willDisplayObjectAtIndexPath:)]) {
        [(id)self.dataSource willDisplayObjectAtIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = [self.dataSource objectAtIndexPath:indexPath];
    
    NSString *objectClassName = NSStringFromClass([object class]);
    
    if (!self.registeredCellsForIdentifier[objectClassName]) {
        self.registeredCellsForIdentifier[objectClassName] = self.defaultCellClass;
        [collectionView registerClass:self.defaultCellClass forCellWithReuseIdentifier:objectClassName];
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:objectClassName forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
	
    return cell;
}

- (NSArray *)objectNamesForObject:(id)object {
    NSMutableArray *objectNames = [NSMutableArray array];
    if ([object isKindOfClass:[NSError class]]) {
        [objectNames addObject:@"error"];
    }
    if ([[object class] respondsToSelector:@selector(modelName)]) {
        [objectNames addObject:[[object class] modelName]];
    }
    [objectNames addObject:NSStringFromClass([object class])];
    [objectNames addObject:@"object"];
    return objectNames;
}

- (void)configureCell:(UICollectionViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.dataSource objectAtIndexPath:indexPath];
    
    if ([object isKindOfClass:[ICLoadingPlaceholder class]]
        && [_cellConfigurationDelegate respondsToSelector:@selector(configureLoadingCell:)]) {
        [_cellConfigurationDelegate configureLoadingCell:(ICLoadingCollectionViewCell*)cell];
        return;
    }
    if ([object isKindOfClass:[ICNoResultsPlaceholder class]]
        && [_cellConfigurationDelegate respondsToSelector:@selector(configureNoResultsCell:)]) {
        [_cellConfigurationDelegate configureNoResultsCell:cell];
        return;
    }
    
    NSArray *objectNames = [self objectNamesForObject:object];
    [self performConfigurationSelectorWithObjectNames:objectNames onCell:cell withObject:object];
}

- (void)performConfigurationSelectorWithObjectNames:(NSArray*)objectNames onCell:(UICollectionViewCell *)cell withObject:(id)object {
    SEL configurationSelector = NULL;
    for (NSString *objectName in objectNames) {
        if (!configurationSelector || ![_cellConfigurationDelegate respondsToSelector:configurationSelector]) {
            configurationSelector = [[ICInflector sharedInflector] selectorWithPrefix:@"configureCell:with" propertyName:objectName suffix:@":"];
        }
    }
    
    if (configurationSelector && [_cellConfigurationDelegate respondsToSelector:configurationSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_cellConfigurationDelegate performSelector:configurationSelector withObject:cell withObject:object];
#pragma clang diagnostic pop
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.dataSource objectAtIndexPath:indexPath];
    NSArray *objectNames = [self objectNamesForObject:object];
    [self performSelectionSelectorWithObjectNames:objectNames withObject:object];
}

- (void)performSelectionSelectorWithObjectNames:(NSArray*)objectNames withObject:(id)object {
    SEL selectionSelector = NULL;
    for (NSString *objectName in objectNames) {
        if (!selectionSelector || ![_cellConfigurationDelegate respondsToSelector:selectionSelector]) {
            selectionSelector = [[ICInflector sharedInflector] selectorWithPrefix:@"collectionView:didSelect" propertyName:objectName suffix:@":"];
        }
    }
    
    if (selectionSelector && [_cellConfigurationDelegate respondsToSelector:selectionSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_cellConfigurationDelegate performSelector:selectionSelector withObject:self.collectionView withObject:object];
#pragma clang diagnostic pop
    }
}

@end
