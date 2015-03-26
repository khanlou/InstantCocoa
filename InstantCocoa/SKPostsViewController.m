//
//  SKMasterViewController.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/15/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "SKPostsViewController.h"

#import "SKDetailViewController.h"
#import "SKPost.h"
#import "ICRemoteDataSource.h"
#import "SKHerokuConfiguration.h"

@interface SKPostsViewController ()

@end

@implementation SKPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Posts";
    
    ICRemoteDataSource *remoteDataSource = [[ICRemoteDataSource alloc] init];
    remoteDataSource.apiPath = @"posts.json";
    remoteDataSource.delegate = self;
    remoteDataSource.mappingClass = [SKPost class];
    remoteDataSource.remoteConfiguration = [SKHerokuConfiguration new];
    self.dataSource = remoteDataSource;
    
    [self.dataSource fetchData];
}

- (void)configureCell:(UITableViewCell *)cell withSKPost:(SKPost*)post {
    cell.textLabel.text = post.title;
}



- (void)tableView:(UITableView *)tableView didSelectPost:(id)object {
    //handle pushing a new view controller
}

@end
