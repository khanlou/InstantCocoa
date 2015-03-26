//
//  ICPlaceholders.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 2/10/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICPlaceholders.h"

@implementation ICLoadingPlaceholder

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

@end

@implementation ICNoResultsPlaceholder

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

@end
