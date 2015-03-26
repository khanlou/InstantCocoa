//
//  SKHerokuConfiguration.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 9/9/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "SKHerokuConfiguration.h"

@implementation SKHerokuConfiguration

- (NSURL *)baseURL {
    return [NSURL URLWithString:@"http://gentle-chamber-8756.herokuapp.com"];
}

@end
