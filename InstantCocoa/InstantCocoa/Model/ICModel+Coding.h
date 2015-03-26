//
//  ICModel+Coding.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/15/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICModel.h"

typedef enum : NSUInteger {
    MTLModelEncodingBehaviorExcluded = 0,
    MTLModelEncodingBehaviorUnconditional,
    MTLModelEncodingBehaviorConditional,
} MTLModelEncodingBehavior;

@interface ICModel (Coding) <NSCoding>

+ (NSDictionary *)encodingBehaviorsByPropertyKey;
+ (NSDictionary *)allowedSecureCodingClassesByPropertyKey;
- (id)decodeValueForKey:(NSString *)key withCoder:(NSCoder *)coder modelVersion:(NSUInteger)modelVersion;
+ (NSUInteger)modelVersion;

@end
