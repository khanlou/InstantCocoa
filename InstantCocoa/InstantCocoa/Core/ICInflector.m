//
//  ICInflector.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/22/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//


#import "ICInflector.h"
#import "NSArray+FunctionalMethods.h"

@interface ICInflector ()

@property (nonatomic, strong) NSSet *prefixes;

@end

@implementation ICInflector

+ (instancetype)sharedInflector {
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _prefixes = [NSSet setWithObjects:@"NS", @"IC", nil];
    
    return self;
}

- (void)addPrefixes:(NSSet *)newPrefixes {
    self.prefixes = [_prefixes setByAddingObjectsFromSet:newPrefixes];
}

#pragma mark - Casing adjustments

- (NSArray *)componentsFromString:(NSString*)string {
    if (string.length == 0) return @[];
    
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -_"];
    NSArray *components = [string componentsSeparatedByCharactersInSet:separatorSet];
    
    NSMutableArray *allComponents = [NSMutableArray array];
    for (NSString *component in components) {
        [allComponents addObjectsFromArray:[self componentsSplitOnUppercase:component]];
    }
    
    return [allComponents arrayByRejectingObjectsPassingTest:^BOOL(NSString *component) {
        return component.length == 0;
    }];
}

- (NSArray *)componentsSplitOnUppercase:(NSString *)string {
    NSMutableString *mutableString = [string mutableCopy];
    
    NSArray *lowercaseComponents = [string componentsSeparatedByCharactersInSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    
    NSMutableArray *allComponents = [NSMutableArray array];
    for (NSString *incompleteComponent in lowercaseComponents) {
        if (incompleteComponent.length == 0) continue;
        
        NSRange rangeOfIncompleteComponent = [mutableString rangeOfString:incompleteComponent];
        
        if (rangeOfIncompleteComponent.location > 1) {
            NSRange rangeOfUppercaseComponent = NSMakeRange(0, rangeOfIncompleteComponent.location-1);
            NSString *uppercaseComponent = [mutableString substringWithRange:rangeOfUppercaseComponent];
            
            [mutableString deleteCharactersInRange:rangeOfUppercaseComponent];
            
            [allComponents addObject:[uppercaseComponent lowercaseString]];
            rangeOfIncompleteComponent = [mutableString rangeOfString:incompleteComponent];
        }
        NSRange rangeOfFullComponent = NSMakeRange(0, rangeOfIncompleteComponent.length + rangeOfIncompleteComponent.location);
        NSString *fullComponent = [mutableString substringWithRange:rangeOfFullComponent];
        
        [mutableString deleteCharactersInRange:rangeOfFullComponent];
        
        [allComponents addObject:[fullComponent lowercaseString]];
    }
    
    if (mutableString.length != 0) {
        [allComponents addObject:[mutableString lowercaseString]];
    }
    
    return allComponents;
}

- (NSString*)camelCasedString:(NSString*)string {
    NSArray *components = [self componentsFromString:string];

    components = [components arrayByTransformingObjectsUsingBlock:^id(NSString *component) {
        return [component capitalizedString];
    }];
    
    return [components componentsJoinedByString:@""];
}

- (NSString*)llamaCasedString:(NSString*)string {
    NSArray *components = [self componentsFromString:string];
    
    __block BOOL firstItem = YES;
    
    components = [components arrayByTransformingObjectsUsingBlock:^id(NSString *component) {
        if (!firstItem) {
            return [component capitalizedString];
        } else {
            firstItem = NO;
            return component;
        }
    }];
    
    return [components componentsJoinedByString:@""];
}

- (NSString*)trainCasedString:(NSString *)string {
    NSArray *components = [self componentsFromString:string];
    
    return [components componentsJoinedByString:@"-"];
}

- (NSString*)snakeCasedString:(NSString *)string {
    NSArray *components = [self componentsFromString:string];
    
    return [components componentsJoinedByString:@"_"];
}

- (NSString *)displayString:(NSString *)string {
    NSArray *components = [self componentsFromString:string];
    
    components = [components arrayByTransformingObjectsUsingBlock:^id(NSString *component) {
        return [component capitalizedString];
    }];
    
    return [components componentsJoinedByString:@" "];
}

#pragma mark - custom selectors

- (SEL)selectorWithPrefix:(NSString*)prefix propertyName:(NSString*)propertyName suffix:(NSString*)suffix {
    //if the prefix is empty, then the first letter should be lowercased
    prefix = [self camelCasedString:prefix];
    propertyName = [self camelCasedString:propertyName];
    suffix = [self camelCasedString:suffix];
    NSString *selectorName = [NSString stringWithFormat:@"%@%@%@", prefix, propertyName, suffix];
    
    NSArray *selectorComponents = [selectorName componentsSeparatedByString:@":"];
    
    NSArray *components = [selectorComponents arrayByTransformingObjectsUsingBlock:^id(NSString *selectorComponent) {
        return [selectorComponent llamaCasedString];
    }];

    selectorName = [components componentsJoinedByString:@":"];
    
    return NSSelectorFromString(selectorName);
}

- (SEL)setterForProperty:(NSString*)propertyName {
    return [self selectorWithPrefix:@"set" propertyName:propertyName suffix:nil];
}

- (SEL)serializerForPropertyName:(NSString*)propertyName {
    return [self selectorWithPrefix:@"serializerFor" propertyName:propertyName suffix:nil];
}

- (NSString*)modelNameFromClass:(Class)modelClass {
    NSString *className = NSStringFromClass(modelClass);
    NSSet *prefixes = _prefixes;
    for (NSString *prefix in prefixes) {
        if ([className hasPrefix:prefix]) {
            className = [className stringByReplacingOccurrencesOfString:prefix withString:@""];
        }
    }
    return className;
}

- (Class)serializerClassForKeyOfClass:(Class)keyClass {
    NSString *serializerType = [self modelNameFromClass:keyClass];
    
    NSSet *prefixes = _prefixes;
    Class serializerClass;
    for (NSString *prefix in prefixes) {
        NSString *possibleClassName = [NSString stringWithFormat:@"%@%@%@", prefix, serializerType, @"Serializer"];
        serializerClass = NSClassFromString(possibleClassName);
        if (serializerClass) {
            break;
        }
    }
    return serializerClass;
}

@end


@implementation NSString (Inflections)

- (NSString*) camelCasedString {
    return [[ICInflector sharedInflector] camelCasedString:self];
}

- (NSString*) llamaCasedString {
    return [[ICInflector sharedInflector] llamaCasedString:self];
}

- (NSString*) trainCasedString {
    return [[ICInflector sharedInflector] trainCasedString:self];
}

- (NSString*) snakeCasedString {
    return [[ICInflector sharedInflector] snakeCasedString:self];
}

- (NSString *)displayString {
    return [[ICInflector sharedInflector] displayString:self];
}

@end
