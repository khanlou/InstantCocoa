//
//  ICTinyType.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 6/8/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ICValueObject <NSObject, NSCopying>

- (instancetype)initWithBackingObject:(id)backingObject;

@property (nonatomic, readonly) id backingObject;

@optional
- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithNumber:(NSNumber *)number;

@end


@interface ICValueObject : NSObject <ICValueObject, NSCopying>

- (instancetype)initWithBackingObject:(id)backingObject;
- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithNumber:(NSNumber *)number;

@property (nonatomic, readonly) id backingObject;

@end
