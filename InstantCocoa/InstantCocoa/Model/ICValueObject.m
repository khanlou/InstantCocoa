//
//  ICTinyType.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 6/8/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICValueObject.h"

@implementation ICValueObject

- (instancetype)initWithBackingObject:(id)backingObject {
    self = [super init];
    if (!self) return nil;
    
    _backingObject = backingObject;
    
    return self;
}

- (instancetype)initWithString:(NSString *)string {
    return [self initWithBackingObject:string];
}

- (instancetype)initWithNumber:(NSNumber *)number {
    return [self initWithBackingObject:number];
}

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (![other isKindOfClass:[self class]]) return NO;
    return [self isEqualToValueObject:other];
}

- (BOOL)isEqualToValueObject:(ICValueObject*)otherValueObject {
    return [self.backingObject isEqual:otherValueObject.backingObject];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p: %@> { Value: %@ }", self, self.class, self.backingObject];
}

- (NSComparisonResult)compare:(ICValueObject*)otherValueObject {
    return [self.backingObject compare:otherValueObject.backingObject];
}

- (NSUInteger)hash {
    return [self.backingObject hash]; //might want to mix in something else specfic to this class
}

- (id)copyWithZone:(NSZone *)zone {
    return [[self.class alloc] initWithBackingObject:self.backingObject];
}

@end
