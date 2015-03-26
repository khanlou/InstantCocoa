//
//  SKPost.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/22/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICModel.h"

@interface SKPost : ICModel

@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate *publishingDate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSURL *canonicalURL;
@property (nonatomic, assign, getter = isPublished) BOOL published;

@end
