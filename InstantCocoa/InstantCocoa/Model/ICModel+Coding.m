//
//  ICModel+Coding.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/15/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICModel+Coding.h"
#import "ICInflector.h"
#import "ICPropertyAttributes.h"

// Used in archives to store the modelVersion of the archived instance.
static NSString * const MTLModelVersionKey = @"MTLModelVersion";

// Used to cache the reflection performed in +allowedSecureCodingClassesByPropertyKey.
static void *MTLModelCachedAllowedClassesKey = &MTLModelCachedAllowedClassesKey;

// Returns whether the given NSCoder requires secure coding.
static BOOL coderRequiresSecureCoding(NSCoder *coder) {
	SEL requiresSecureCodingSelector = @selector(requiresSecureCoding);
    
	// Only invoke the method if it's implemented (i.e., only on OS X 10.8+ and
	// iOS 6+).
	if (![coder respondsToSelector:requiresSecureCodingSelector]) return NO;
    
	BOOL (*requiresSecureCodingIMP)(NSCoder *, SEL) = (__typeof__(requiresSecureCodingIMP))[coder methodForSelector:requiresSecureCodingSelector];
	if (requiresSecureCodingIMP == NULL) return NO;
    
	return requiresSecureCodingIMP(coder, requiresSecureCodingSelector);
}

// Returns all of the given class' encodable property keys (those that will not
// be excluded from archives).
static NSSet *encodablePropertyKeysForClass(Class modelClass) {
	return [[modelClass encodingBehaviorsByPropertyKey] keysOfEntriesPassingTest:^ BOOL (NSString *propertyKey, NSNumber *behavior, BOOL *stop) {
		return behavior.unsignedIntegerValue != MTLModelEncodingBehaviorExcluded;
	}];
}

// Verifies that all of the specified class' encodable property keys are present
// in +allowedSecureCodingClassesByPropertyKey, and throws an exception if not.
static void verifyAllowedClassesByPropertyKey(Class modelClass) {
	NSDictionary *allowedClasses = [modelClass allowedSecureCodingClassesByPropertyKey];
    
	NSMutableSet *specifiedPropertyKeys = [[NSMutableSet alloc] initWithArray:allowedClasses.allKeys];
    NSSet *encodablePropertyKeys = encodablePropertyKeysForClass(modelClass);
	[specifiedPropertyKeys minusSet:encodablePropertyKeys];
    
	if (specifiedPropertyKeys.count > 0) {
		[NSException raise:NSInvalidArgumentException format:@"Cannot encode %@ securely, because keys are missing from +allowedSecureCodingClassesByPropertyKey: %@", modelClass, specifiedPropertyKeys];
	}
}

@implementation ICModel (NSCoding)

#pragma mark Versioning

+ (NSUInteger)modelVersion {
	return 0;
}

#pragma mark Encoding Behaviors

+ (NSDictionary *)encodingBehaviorsByPropertyKey {
	NSDictionary *properties = self.properties;
	NSMutableDictionary *behaviors = [[NSMutableDictionary alloc] initWithCapacity:properties.count];
    
    [properties enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, ICPropertyAttributes *attributes, BOOL *stop) {
        
		MTLModelEncodingBehavior behavior = (attributes.weak ? MTLModelEncodingBehaviorConditional : MTLModelEncodingBehaviorUnconditional);
		behaviors[propertyName] = @(behavior);
	}];
    
	return behaviors;
}

+ (NSDictionary *)allowedSecureCodingClassesByPropertyKey {
	NSDictionary *cachedClasses = objc_getAssociatedObject(self, MTLModelCachedAllowedClassesKey);
	if (cachedClasses != nil) return cachedClasses;
    
	// Get all property keys that could potentially be encoded.
	NSSet *propertyKeys = [self.encodingBehaviorsByPropertyKey keysOfEntriesPassingTest:^ BOOL (NSString *propertyKey, NSNumber *behavior, BOOL *stop) {
		return behavior.unsignedIntegerValue != MTLModelEncodingBehaviorExcluded;
	}];
    
	NSMutableDictionary *allowedClasses = [[NSMutableDictionary alloc] initWithCapacity:propertyKeys.count];
    
    NSDictionary *properties = self.properties;
    [properties enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, ICPropertyAttributes *attributes, BOOL *stop) {
        
		// If the property is not of object or class type, assume that it's
		// a primitive which would be boxed into an NSValue.
		if (![attributes.type isEqualToString:@"object"]) {
			allowedClasses[propertyName] = @[NSValue.class];
			return;
		}
        
		// Omit this property from the dictionary if its class isn't known.
		if (attributes.className != nil) {
			allowedClasses[propertyName] = @[attributes.className];
		}
	}];
    
	// It doesn't really matter if we replace another thread's work, since we do
	// it atomically and the result should be the same.
	objc_setAssociatedObject(self, MTLModelCachedAllowedClassesKey, allowedClasses, OBJC_ASSOCIATION_COPY);
    
	return allowedClasses;
}

- (id)decodeValueForKey:(NSString *)key withCoder:(NSCoder *)coder modelVersion:(NSUInteger)modelVersion {
	NSParameterAssert(key != nil);
	NSParameterAssert(coder != nil);
    
	SEL selector = [[ICInflector sharedInflector] selectorWithPrefix:@"decode" propertyName:key suffix:@"WithCoder:modelVersion:"];
	if ([self respondsToSelector:selector]) {
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
		invocation.target = self;
		invocation.selector = selector;
		[invocation setArgument:&coder atIndex:2];
		[invocation setArgument:&modelVersion atIndex:3];
		[invocation invoke];
        
		__unsafe_unretained id result = nil;
		[invocation getReturnValue:&result];
		return result;
	}
    
	if (coderRequiresSecureCoding(coder)) {
		NSArray *allowedClasses = self.class.allowedSecureCodingClassesByPropertyKey[key];
		NSAssert(allowedClasses != nil, @"No allowed classes specified for securely decoding key \"%@\" on %@", key, self.class);
		
		return [coder decodeObjectOfClasses:[NSSet setWithArray:allowedClasses] forKey:key];
	} else {
		return [coder decodeObjectForKey:key];
	}
}

#pragma mark NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
	BOOL requiresSecureCoding = coderRequiresSecureCoding(coder);
	NSNumber *version = nil;
	if (requiresSecureCoding) {
		version = [coder decodeObjectOfClass:NSNumber.class forKey:MTLModelVersionKey];
	} else {
		version = [coder decodeObjectForKey:MTLModelVersionKey];
	}
	
	if (version == nil) {
		NSLog(@"Warning: decoding an archive of %@ without a version, assuming 0", self.class);
	} else if (version.unsignedIntegerValue > self.class.modelVersion) {
		// Don't try to decode newer versions.
		return nil;
	}
    
    verifyAllowedClassesByPropertyKey(self.class);
    
	NSDictionary *properties = self.class.properties;
	NSMutableDictionary *dictionaryValue = [[NSMutableDictionary alloc] initWithCapacity:properties.count];
    
    [properties enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, ICPropertyAttributes *attributes, BOOL *stop) {
        id value = [self decodeValueForKey:propertyName withCoder:coder modelVersion:version.unsignedIntegerValue];
		if (value == nil) return;
        
		dictionaryValue[propertyName] = value;
	}];
     
	self = [self initWithDictionary:dictionaryValue];
	if (self == nil) NSLog(@"*** Could not unarchive %@", self.class);
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	if (coderRequiresSecureCoding(coder)) verifyAllowedClassesByPropertyKey(self.class);
    
	[coder encodeObject:@(self.class.modelVersion) forKey:MTLModelVersionKey];
    
	NSDictionary *encodingBehaviors = self.class.encodingBehaviorsByPropertyKey;
	[self.dictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
		// Skip nil values.
		if ([value isEqual:NSNull.null]) return;
        
		switch ([encodingBehaviors[key] unsignedIntegerValue]) {
                // This will also match a nil behavior.
			case MTLModelEncodingBehaviorExcluded:
				break;
                
			case MTLModelEncodingBehaviorUnconditional:
				[coder encodeObject:value forKey:key];
				break;
                
			case MTLModelEncodingBehaviorConditional:
				[coder encodeConditionalObject:value forKey:key];
				break;
                
			default:
				NSAssert(NO, @"Unrecognized encoding behavior %@ for key \"%@\"", encodingBehaviors[key], key);
		}
	}];
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding {
	// Disable secure coding support by default, so subclasses are forced to
	// opt-in by conforming to the protocol and overriding this method.
	//
	// We only implement this method because XPC complains if a subclass tries
	// to implement it but does not override -initWithCoder:. See
	// https://github.com/github/Mantle/issues/74.
	return NO;
}

@end
