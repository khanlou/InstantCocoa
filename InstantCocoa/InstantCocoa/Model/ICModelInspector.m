//
//  ICModelInspector.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 6/8/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICModelInspector.h"
#import "ICPropertyAttributes.h"
#import "ICModel.h"

@interface ICModelInspector ()

@property (nonatomic, strong) Class classToInspect;
@property (nonatomic, strong) NSDictionary *cachedProperties;
@property (nonatomic, readonly) NSString *cachingKey;

@end

@implementation ICModelInspector

+ (NSCache *)propertyCache {
    static NSCache *propertyCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        propertyCache = [NSCache new];
    });
    return propertyCache;
}

- (instancetype)initWithClass:(Class)class {
    self = [super init];
    if (!self) return nil;
    
    _classToInspect = class;
    
    return self;
}

- (NSDictionary*)properties {
    if (self.cachedProperties) {
        return self.cachedProperties;
    }
    
	NSMutableDictionary *mutablePropertyKeys = [NSMutableDictionary dictionary];
    
	[self enumeratePropertiesWithBlock:^(ICPropertyAttributes *property, BOOL *stop) {
        
		if (property.readOnly && property.instanceVariable == nil) return;
        
        mutablePropertyKeys[property.name] = property;
	}];
    
    self.cachedProperties = [mutablePropertyKeys copy];
    
	return self.cachedProperties;
}

- (NSString *)cachingKey {
    return NSStringFromClass(self.classToInspect);
}

- (void)setCachedProperties:(NSDictionary *)cachedProperties {
    [[self.class propertyCache] setObject:cachedProperties forKey:self.cachingKey];
}

- (NSDictionary *)cachedProperties {
    return [[self.class propertyCache] objectForKey:self.cachingKey];
}

- (void)enumeratePropertiesWithBlock:(void (^)(ICPropertyAttributes *property, BOOL *stop))block {
	BOOL stop = NO;
    
    Class currentClass = self.classToInspect;
    
	while (!stop && ![currentClass isEqual:NSObject.class]) {
		unsigned count = 0;
		objc_property_t *properties = class_copyPropertyList(currentClass, &count);
        
		for (unsigned i = 0; i < count; i++) {
            ICPropertyAttributes *propertyAttributes = [ICPropertyAttributes propertyAttributesFromObjectiveCProperty:properties[i]];
            if (![currentClass isEqual:[ICModel class]] || [propertyAttributes.name isEqualToString:@"objectID"]) {
                block(propertyAttributes, &stop);
                if (stop) break;
            }
		}
        
        currentClass = currentClass.superclass;
		if (properties != NULL) {
            free(properties);
        }
	}
}



@end
