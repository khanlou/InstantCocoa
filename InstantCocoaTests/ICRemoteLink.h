//
//  ICRemoteLink.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 9/6/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICModel.h"

@interface ICRemoteLink : ICModel

@property (nonatomic, strong) NSURL *link;
@property (nonatomic, assign) NSInteger upvoteCount;

@end
