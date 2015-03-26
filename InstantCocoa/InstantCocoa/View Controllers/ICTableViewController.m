//
//  ICTableViewController.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/11/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICTableViewController.h"
#import "ICRemoteDataSource.h"
#import "ICMultiDataSource.h"
#import "ICModel.h"
#import "ICInflector.h"
#import "ICPlaceholders.h"
#import "ICLoadingTableViewCell.h"

@interface ICTableViewController ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *registeredCellsForIdentifier;

@end

@implementation ICTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return nil;
    
    _clearsSelectionOnViewWillAppear = YES;
    
    return self;
}

- (UITableView *)tableView {
    if (!_tableView) {
        [self view];
    }
    return _tableView;
}

- (void)loadView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.dataSource = self;
    tableView.delegate = self;
    if (!self.cellConfigurationDelegate) {
        self.cellConfigurationDelegate = self;
    }
    if (!self.defaultCellClass) {
        self.defaultCellClass = [UITableViewCell class];
    }
    
    self.view = tableView;
    self.tableView = tableView;
    
    
    [self registerCellClass:[ICLoadingTableViewCell class] forModelClass:[ICLoadingPlaceholder class]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.clearsSelectionOnViewWillAppear) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
    }
}

- (NSMutableDictionary *)registeredCellsForIdentifier {
    if (!_registeredCellsForIdentifier) {
        self.registeredCellsForIdentifier = [NSMutableDictionary dictionary];
    }
    return _registeredCellsForIdentifier;
}

- (void) registerCellClass:(Class)cellClass forModelClass:(Class)modelClass {
    self.registeredCellsForIdentifier[NSStringFromClass(modelClass)] = cellClass;
    [self.tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(modelClass)];
}

- (void) setDataSource:(id<ICDataSource>)dataSource {
    [super setDataSource:dataSource];
    if (![dataSource delegate]) {
        dataSource.delegate = self;
    }
}

- (void)setDefaultCellClass:(Class)defaultCellClass {
    NSAssert([defaultCellClass isSubclassOfClass:[UITableViewCell class]], @"ICTableViewController's defaultCellClass must be a subclass of UITableViewCell");
    _defaultCellClass = defaultCellClass;
}

- (void)configureCell:(UITableViewCell *)cell withObject:(id)object {
    //default no-op
}

- (void)configureCell:(UITableViewCell *)cell withError:(NSError*)error {
    cell.textLabel.text = error.localizedDescription;
}

- (void)configureLoadingCell:(ICLoadingTableViewCell *)loadingCell {
    [loadingCell.activityIndicator startAnimating];
}

- (void)configureNoResultsCell:(UITableViewCell *)noResultsCell {
    noResultsCell.textLabel.text = @"No Results";
}

- (void)dataSourceWillLoadData:(id<ICDataSource>)dataSource {
    //default no-op
}

- (void)dataSourceDidPartiallyLoad:(id<ICDataSource>)dataSource {
    [self.tableView reloadData];
}

- (void)dataSource:(id<ICDataSource>)dataSource failedWithError:(NSError *)error {
    //no op
}

- (void)dataSourceFinishedLoading:(id<ICDataSource>)dataSource {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfObjectsInSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(willDisplayObjectAtIndexPath:)]) {
        [(id)self.dataSource willDisplayObjectAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = [self.dataSource objectAtIndexPath:indexPath];
    
    NSString *objectClassName = NSStringFromClass([object class]);
    
    if (!self.registeredCellsForIdentifier[objectClassName]) {
        self.registeredCellsForIdentifier[objectClassName] = self.defaultCellClass;
        [tableView registerClass:self.defaultCellClass forCellReuseIdentifier:objectClassName];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:objectClassName forIndexPath:indexPath];
    
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

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.dataSource objectAtIndexPath:indexPath];
    
    if ([object isKindOfClass:[ICLoadingPlaceholder class]]
        && [_cellConfigurationDelegate respondsToSelector:@selector(configureLoadingCell:)]) {
        [_cellConfigurationDelegate configureLoadingCell:(ICLoadingTableViewCell*)cell];
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

- (void)performConfigurationSelectorWithObjectNames:(NSArray*)objectNames onCell:(UITableViewCell*)cell withObject:(id)object {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.dataSource objectAtIndexPath:indexPath];
    NSArray *objectNames = [self objectNamesForObject:object];
    [self performSelectionSelectorWithObjectNames:objectNames withObject:object];
}

- (void)performSelectionSelectorWithObjectNames:(NSArray*)objectNames withObject:(id)object {
    SEL selectionSelector = NULL;
    for (NSString *objectName in objectNames) {
        if (!selectionSelector || ![_cellConfigurationDelegate respondsToSelector:selectionSelector]) {
            selectionSelector = [[ICInflector sharedInflector] selectorWithPrefix:@"tableView:didSelect" propertyName:objectName suffix:@":"];
        }
    }
    
    if (selectionSelector && [_cellConfigurationDelegate respondsToSelector:selectionSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_cellConfigurationDelegate performSelector:selectionSelector withObject:self.tableView withObject:object];
#pragma clang diagnostic pop
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.dataSource objectAtIndexPath:indexPath];
    NSArray *objectNames = [self objectNamesForObject:object];
    return [self performHeightSelectorWithObjectNames:objectNames withObject:object];
}

- (CGFloat)performHeightSelectorWithObjectNames:(NSArray*)objectNames withObject:(id)object {
    SEL heightSelector = NULL;
    for (NSString *objectName in objectNames) {
        if (!heightSelector || ![_cellConfigurationDelegate respondsToSelector:heightSelector]) {
            heightSelector = [[ICInflector sharedInflector] selectorWithPrefix:@"tableView:heightFor" propertyName:objectName suffix:@":"];
        }
    }
    
    float returnValue = self.tableView.rowHeight;
    if (heightSelector && [_cellConfigurationDelegate respondsToSelector:heightSelector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: [[_cellConfigurationDelegate class] instanceMethodSignatureForSelector:heightSelector]];
        [invocation setSelector:heightSelector];
        [invocation setTarget:_cellConfigurationDelegate];
        
        __unsafe_unretained UITableView *tableView = self.tableView;
        __unsafe_unretained id unsafe_object = object;
        [invocation setArgument:&tableView atIndex:2];
        [invocation setArgument:&unsafe_object atIndex:3];
        [invocation invoke];
        [invocation getReturnValue:&returnValue];
    }
    
    return returnValue;
}


@end
