//
//  ICJSONMapper.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 3/10/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICJSONMapper.h"
#import "ICValueObject.h"
#import "ICPropertyAttributes.h"
#import "ICSerializers.h"
#import "ICInflector.h"
#import <NSArray+FunctionalMethods.h>
#import "ICModelProtocols.h"
#import <NSDictionary+FunctionalMethods.h>

@implementation ICJSONMapper

- (id)mapFromJSONDictionary:(NSDictionary*)JSONDictionary toObject:(id<ICJSONMappable>)object {
    if ([JSONDictionary isKindOfClass:[NSNull class]]) {
        return object;
    }
    if ([object respondsToSelector:@selector(transformJSONRepresentationBeforeMapping:)]) {
        [object transformJSONRepresentationBeforeMapping:&JSONDictionary];
    }
    NSDictionary *newDictionaryRepresentation = [self dictionaryForJSONDictionary:JSONDictionary ontoClass:object.class];
    
    return [self mapFromDictionary:newDictionaryRepresentation toObject:object];
}

- (NSDictionary *)dictionaryForJSONDictionary:(NSDictionary *)JSONDictionary ontoClass:(Class)class {
    NSDictionary *JSONMapping = [class JSONMapping];
    NSDictionary *properties = [class properties];
    
    NSDictionary *newDictionaryRepresentation = [properties dictionaryByTransformingValuesUsingBlock:^id(id key, ICPropertyAttributes *attributes) {
        id valueFromJSONDictionary;
        
        NSString *JSONKeyPath = JSONMapping[key];
        if (JSONKeyPath) {
            valueFromJSONDictionary = [JSONDictionary valueForKeyPath:JSONKeyPath];
        }
        
        if ((!valueFromJSONDictionary || [valueFromJSONDictionary isKindOfClass:[NSNull class]]) && JSONDictionary[key]) {
            valueFromJSONDictionary = JSONDictionary[key];
        }
        
        if (!valueFromJSONDictionary || [valueFromJSONDictionary isKindOfClass:[NSNull class]]) {
            return [NSNull null];
        }
        Class mappingClass = NSClassFromString(attributes.className);
        if (mappingClass
            && [mappingClass conformsToProtocol:@protocol(ICJSONMappable)]
            && [valueFromJSONDictionary isKindOfClass:[NSDictionary class]]) {
            valueFromJSONDictionary = [self dictionaryForJSONDictionary:valueFromJSONDictionary ontoClass:mappingClass];
        }
        
        return valueFromJSONDictionary;
    }];
    newDictionaryRepresentation = [newDictionaryRepresentation dictionaryByRejectingKeysAndValuesPassingTest:^BOOL(id key, id value) {
        return [value isKindOfClass:[NSNull class]];
    }];
    return newDictionaryRepresentation;
}

- (BOOL)classIsMappableCollection:(Class)collectionClass {
    return [collectionClass isSubclassOfClass:[NSArray class]] ||
    [collectionClass isSubclassOfClass:[NSSet class]] ||
    [collectionClass isSubclassOfClass:[NSOrderedSet class]];
}

- (id)valueObjectWithClass:(Class)mappingClass value:(id)value {
    if (![mappingClass conformsToProtocol:@protocol(ICValueObject)]) {
        return nil;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [self valueObjectWithClass:mappingClass string:value];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return [self valueObjectWithClass:mappingClass number:value];
    }
    return nil;
}

- (id)valueObjectWithClass:(Class)class string:(NSString *)string {
    id valueObject = [class alloc];
    if ([valueObject respondsToSelector:@selector(initWithString:)]) {
        return [valueObject initWithString:string];
    }
    if ([valueObject respondsToSelector:@selector(initWithBackingObject:)]) {
        return [valueObject initWithBackingObject:string];
    }
    return string;
}

- (id)valueObjectWithClass:(Class)class number:(NSNumber *)number {
    id valueObject = [class alloc];
    if ([valueObject respondsToSelector:@selector(initWithNumber:)]) {
        return [valueObject initWithNumber:number];
    }
    if ([valueObject respondsToSelector:@selector(initWithBackingObject:)]) {
        return [valueObject initWithBackingObject:number];
    }
    return number;
}

- (id)collectionWithClass:(Class)collectionClass mappingClass:(Class)mappingClass fromValue:valueFromArray {
    
    id localDomainObjects;
    if ([self classIsMappableCollection:collectionClass]) {
        localDomainObjects = [[[collectionClass alloc] init] mutableCopy];
    }
    
    for (id collectedValue in valueFromArray) {
        id localDomainObject = [self mapObject:collectedValue toDomainObjectOfClass:mappingClass];
        if (localDomainObject) {
            [localDomainObjects addObject:localDomainObject];
        } else {
            [localDomainObjects addObject:collectedValue];
        }
    }
    return localDomainObjects;
}

- (id)mapObject:(NSDictionary*)object toDomainObjectOfClass:(Class)mappingClass {
    id localDomainObject = [mappingClass alloc];
    if ([localDomainObject conformsToProtocol:@protocol(ICJSONMappable)]) {
        return [localDomainObject initWithJSONDictionary:object];
    } else if ([localDomainObject conformsToProtocol:@protocol(ICMappable)]) {
        return [localDomainObject initWithDictionary:object];
    }
    
    return nil;
}



- (Class)mappingClassForProperty:(ICPropertyAttributes*)attributes onClass:(Class)modelClass {
    SEL mappingClassSelector = [[ICInflector sharedInflector] selectorWithPrefix:@"mappingClassFor" propertyName:attributes.name suffix:@""];
    if (![modelClass respondsToSelector:mappingClassSelector]) {
        return Nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    Class mappingClass = [modelClass performSelector:mappingClassSelector];
#pragma clang diagnostic pop

    return mappingClass;
}

- (BOOL)objectIsValueType:(id)value {
    return ([value isKindOfClass:[NSNumber class]] ||
            [value isKindOfClass:[NSString class]]);
}

- (id)mapFromDictionary:(NSDictionary*)dictionary toObject:(id<ICMappable>)object {
    NSDictionary *properties = [object.class properties];
    
    for (id key in properties) {
        id valueForKey = dictionary[key];
        if (!valueForKey) {
            continue;
        }
    
        ICPropertyAttributes *attributes = properties[key];
        
        if ([valueForKey isKindOfClass:[NSArray class]]) {
            Class collectionClass = NSClassFromString(attributes.className);
            Class mappingClass = [self mappingClassForProperty:attributes onClass:object.class];
            valueForKey = [self collectionWithClass:collectionClass mappingClass:mappingClass fromValue:valueForKey];
        }
        
        if ([self objectIsValueType:valueForKey]) {
            Class valueObjectClass = NSClassFromString(attributes.className);
            id valueObject = [self valueObjectWithClass:valueObjectClass value:valueForKey];
            if (valueObject) {
                valueForKey = valueObject;
            }
        }
        
        Class mappingClass = NSClassFromString(attributes.className);
        if (mappingClass && [mappingClass conformsToProtocol:@protocol(ICMappable)]) {
            id childObject;
            if ([object valueForKey:key]) {
                childObject = [object valueForKey:key];
            } else {
                childObject = [[mappingClass alloc] init];
            }
            valueForKey = [self mapFromDictionary:valueForKey toObject:childObject];
        }
        
        if ([self objectIsValueType:valueForKey]) {
            id<ICSerializer> serializer = [self serializerForProperty:attributes ofObject:object];
            id deserializedValue = [serializer deserializedObjectFromString:valueForKey];
            if (deserializedValue) {
                valueForKey = deserializedValue;
            }
        }
        
        if (valueForKey == [NSNull null]) {
            continue;
        };

        if (valueForKey) {
            [object setValue:valueForKey forKey:key];
        }
    }
    return object;
}

- (NSDictionary *)dictionaryRepresentationOfObject:(id<ICMappable>)object {
    
    NSDictionary *properties = [object.class properties];
	NSDictionary *dictionaryRepresentation = [object dictionaryWithValuesForKeys:properties.allKeys];
    dictionaryRepresentation = [dictionaryRepresentation dictionaryByRejectingKeysAndValuesPassingTest:^BOOL(id key, id value) {
        return [value isKindOfClass:[NSNull class]];
    }];
    dictionaryRepresentation = [dictionaryRepresentation dictionaryByTransformingValuesUsingBlock:^id(id propertyName, id value) {
        if ([value conformsToProtocol:@protocol(ICValueObject)]) {
            return [value backingObject];
        }
        if ([self classIsMappableCollection:[value class]]) {
            return [self normalizedCollectionOfDictionaryRepresentations:value];
        }
        id<ICSerializer> serializer = [self serializerForProperty:properties[propertyName] ofObject:object];
        if (serializer) {
            id serializedValue = [serializer serializedObject:value];
            if (serializedValue) {
                return serializedValue;
            }
        }
        if ([value conformsToProtocol:@protocol(ICMappable)]) {
            id<ICMappable> mappableValue = (id<ICMappable>)value;
            return [mappableValue dictionaryRepresentation];
        }
        return value;
    }];
    return dictionaryRepresentation;
}

- (NSDictionary*)JSONRepresentationOfObject:(id<ICJSONMappable>)object {
    if (![object.class conformsToProtocol:@protocol(ICJSONMappable)]) return object.dictionaryRepresentation;

    NSDictionary *JSONMapping = [object.class JSONMapping];
    NSDictionary *properties = [object.class properties];
    
    NSMutableDictionary *JSONRepresentation = [NSMutableDictionary dictionary];
    
    for (id key in properties.allKeys) {
        id internalValue = [object valueForKey:key];
        
        if (!internalValue || [internalValue isKindOfClass:[NSNull class]]) {
            continue;
        }
        
        if ([internalValue conformsToProtocol:@protocol(ICJSONMappable)]) {
            internalValue = [internalValue JSONRepresentation];
        }
        
        if ([self classIsMappableCollection:[internalValue class]]) {
            internalValue = [self normalizedCollectionOfJSONRepresentations:internalValue];
        }
        
        if ([internalValue conformsToProtocol:@protocol(ICValueObject)]) {
            internalValue = [internalValue backingObject];
        }
        
        id<ICSerializer> serializer = [self serializerForProperty:properties[key] ofObject:object];
        id serializedValue = [serializer serializedObject:internalValue];
        
        if (serializedValue) {
            internalValue = serializedValue;
        }
        
        NSString *keyPath = JSONMapping[key] ?: key;
        
        if (![key isEqual:JSONMapping[key]]) {
            [self createIntermediateDictionariesInDictionary:JSONRepresentation forKeyPath:keyPath];
        }
        
        [JSONRepresentation setValue:internalValue forKeyPath:keyPath];
    }
    return JSONRepresentation;
}

- (NSArray*)normalizedCollectionOfJSONRepresentations:(id)collection {
    return [[collection allObjects] arrayByTransformingObjectsUsingBlock:^id(id object) {
        if ([object conformsToProtocol:@protocol(ICJSONMappable)]) {
            return [object JSONRepresentation];
        }
        return object;
    }];
}

- (NSArray*)normalizedCollectionOfDictionaryRepresentations:(id)collection {
    return [[collection allObjects] arrayByTransformingObjectsUsingBlock:^id(id object) {
        if ([object conformsToProtocol:@protocol(ICMappable)]) {
            return [object JSONRepresentation];
        }
        return object;
    }];
}

- (void)createIntermediateDictionariesInDictionary:(NSMutableDictionary *)dictionary forKeyPath:(NSString *)keyPath {
    NSArray *keyPathComponents = [keyPath componentsSeparatedByString:@"."];
    
    // Set up dictionaries at each step of the key path.
    id obj = dictionary;
    for (NSString *component in keyPathComponents) {
        if ([obj valueForKey:component] == nil) {
            // Insert an empty mutable dictionary at this spot so that we
            // can set the whole key path afterward.
            [obj setValue:[NSMutableDictionary dictionary] forKey:component];
        }
        
        obj = [obj valueForKey:component];
    }
}


- (id<ICSerializer>)serializerForProperty:(ICPropertyAttributes*)property ofObject:(id)object {
    id<ICSerializer> serializer;
    SEL selectorForSerializerForCurrentKey = [[ICInflector sharedInflector] serializerForPropertyName:property.name];
    if ([object respondsToSelector:selectorForSerializerForCurrentKey]) {
        IMP imp = [object methodForSelector:selectorForSerializerForCurrentKey];
        id<ICSerializer> (*func)(id, SEL) = (void *)imp;
        serializer = func(object, selectorForSerializerForCurrentKey);
    }
    
    if (!serializer) {
        Class serializerClass = [[ICInflector sharedInflector] serializerClassForKeyOfClass:NSClassFromString(property.className)];
        
        if (serializerClass) {
            serializer = [[serializerClass alloc] init];
        }
    }
    return serializer;
}


@end
