//
//  ICModelInspector.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 6/8/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICModelInspector : NSObject

- (instancetype)initWithClass:(Class)class;

- (NSDictionary*)properties;

@end
