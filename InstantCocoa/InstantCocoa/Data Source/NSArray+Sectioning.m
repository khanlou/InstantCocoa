//
//  NSArray+Sectioning.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/5/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "NSArray+Sectioning.h"

@implementation NSString (FirstCharacter)

- (NSString *)firstCharacter {
    __block NSString *firstSubstring;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        firstSubstring = substring;
        *stop = YES;
    }];
    return firstSubstring;
}

@end

@implementation NSArray (Sectioning)

- (NSArray*)sectionedArrayWithKey:(NSString*)sectioningKey {
    if (sectioningKey.length == 0) {
        return @[self];
    }
    
    NSMutableArray *sectionedArray = [NSMutableArray array];
    NSMutableArray *currentSection = nil;
    
    for (id object in self) {
        id sectioningValueForCurrentSection = [[currentSection lastObject] valueForKeyPath:sectioningKey];
        id sectioningValueForNewObject = [object valueForKeyPath:sectioningKey];
        
        if (![sectioningValueForCurrentSection isEqual:sectioningValueForNewObject]) {
            currentSection = [NSMutableArray array];
            [sectionedArray addObject:currentSection];
        }
        [currentSection addObject:object];
        
    }
    
    return sectionedArray;
    
}
@end
