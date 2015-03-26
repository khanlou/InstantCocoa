//
//  ICInflector.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/22/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+InflectorKit.h"

@interface ICInflector : NSObject

+ (instancetype)sharedInflector;

- (void)addPrefixes:(NSSet*)newPrefixes;

- (NSString*)modelNameFromClass:(Class)modelClass;

- (Class)serializerClassForKeyOfClass:(Class)keyClass;
- (SEL)serializerForPropertyName:(NSString*)propertyName;
- (SEL)setterForProperty:(NSString*)propertyName;
- (SEL)selectorWithPrefix:(NSString*)prefix propertyName:(NSString*)propertyName suffix:(NSString*)suffix;

- (NSString *)camelCasedString:(NSString*)string;
- (NSString *)llamaCasedString:(NSString*)string;
- (NSString *)trainCasedString:(NSString*)string;
- (NSString *)snakeCasedString:(NSString*)string;
- (NSString *)displayString:(NSString *)string;

@end

@interface NSString (Inflections)

- (NSString *)camelCasedString;
- (NSString *)llamaCasedString;
- (NSString *)trainCasedString;
- (NSString *)snakeCasedString;
- (NSString *)displayString;

@end