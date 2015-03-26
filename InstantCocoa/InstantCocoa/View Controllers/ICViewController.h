//
//  ICViewController.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/11/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICModelProtocols.h"

@protocol ICDataSource;

@interface ICViewController : UIViewController <ICRoutable>

@property (nonatomic, strong) id<ICDataSource> dataSource;


@end
