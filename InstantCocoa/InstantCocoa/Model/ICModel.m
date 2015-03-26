//
//  ICModel.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/15/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICModel.h"
#import "ICInflector.h"
#import "NSDictionary+FunctionalMethods.h"
#import "ICPropertyAttributes.h"
#import "ICJSONMapper.h"
#import "ICModelInspector.h"
#import <NSSet+FunctionalMethods.h>
#import "ICRemoteConfiguration.h"

@interface ICModel ()

@property (nonatomic, strong, readwrite) ICResourceGateway *gateway;

@end

@implementation ICModel

+ (NSDictionary *)JSONMapping { return @{}; }

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue {
	self = [self init];
	if (!self) return nil;
    
    [[ICJSONMapper new] mapFromDictionary:dictionaryValue toObject:self];
    
	return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return [[ICJSONMapper new] dictionaryRepresentationOfObject:self];
}

- (instancetype)initWithJSONDictionary:(NSDictionary*)JSONDictionary {
    
    if (![self.class respondsToSelector:@selector(JSONMapping)]) return [self initWithDictionary:JSONDictionary];
    
    self = [super init];
    if (!self) return nil;
    
    return [[ICJSONMapper new] mapFromJSONDictionary:JSONDictionary toObject:self];
}

- (NSDictionary*)JSONRepresentation {
    return [[ICJSONMapper new] JSONRepresentationOfObject:self];
}

+ (NSDictionary *)properties {
    return [[[ICModelInspector new] initWithClass:self] properties];
}

+ (NSString *)modelName {
    return [[ICInflector sharedInflector] modelNameFromClass:self];
}

+ (NSString *)resourceEndpoint {
    return [[[self modelName] pluralizedString] lowercaseString];
}

- (NSString *)resourceEndpoint {
    return [[self.class resourceEndpoint] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.objectID]];
}

- (NSString *)remoteKeyPath {
    return @"";
}

+ (NSMutableDictionary *)gatewaysByClass {
    static NSMutableDictionary *gatewaysByClass;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gatewaysByClass = [[NSMutableDictionary alloc] init];
    });
    return gatewaysByClass;
}

+ (ICResourceGateway *)gateway {
    if (self.gatewaysByClass[[self modelName]]) {
        return self.gatewaysByClass[[self modelName]];
    }
    ICResourceGateway *gateway = [[ICResourceGateway alloc] initWithClass:self modelObject:nil];
    self.gatewaysByClass[[self modelName]] = gateway;
    return gateway;
}

- (ICResourceGateway *)gateway {
    if (!_gateway) {
        self.gateway = [[ICResourceGateway alloc] initWithClass:self.class modelObject:self];
    }
    return _gateway;
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
	return [[self.class allocWithZone:zone] initWithDictionary:self.dictionaryRepresentation];
}

#pragma mark NSObject

- (NSString *)description {
    NSSet *valueClasses = [NSSet setWithObjects:
                           [NSString class],
                           [NSNumber class],
                           [NSDate class],
                           [NSValue class],
                           [NSURL class],
                           [UIColor class],
                           [NSData class],
                           nil];
    NSMutableString *descriptionString = [@"{\n" mutableCopy];
    NSDictionary *properties = self.class.properties;
	for (NSString *key in properties) {
        id value = [self valueForKey:key];
        if ([valueClasses anyObjectsPassTest:^BOOL(id object) { return [value isKindOfClass:object]; }]) {
            [descriptionString appendFormat:@"  %@: %@\n", key, value];
        } else {
            [descriptionString appendFormat:@"  %@: <%@: %p>\n", key, [value class], value];
        }
	}
    [descriptionString appendString:@"}"];
	return [NSString stringWithFormat:@"<%@: %p> %@", self.class, self, descriptionString];
}

- (NSUInteger)hash {
	NSUInteger value = 0;
    
    NSDictionary *properties = self.class.properties;
	for (NSString *key in properties) {
        ICPropertyAttributes *attributes = properties[key];
        if (!attributes.readOnly && !attributes.weak) {
            value ^= [[self valueForKey:key] hash];
        }
	}
    
	return value;
}

- (BOOL)isEqual:(id)model {
	if (self == model) return YES;
	if (![model isMemberOfClass:self.class]) return NO;
    
	for (NSString *key in self.class.properties.allKeys) {
		id selfValue = [self valueForKey:key];
		id modelValue = [model valueForKey:key];
        
		BOOL valuesEqual = ((selfValue == nil && modelValue == nil) || [selfValue isEqual:modelValue]);
		if (!valuesEqual) return NO;
	}
    
	return YES;
}

@end
