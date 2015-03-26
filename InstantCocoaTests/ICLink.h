//
//  ICLink.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 9/6/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICModel.h"

@interface ICLink : ICModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *link;
@property (nonatomic, strong) NSString *category;

@end
