//
//  NSString+PathNormalization.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/4/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "NSString+PathNormalization.h"

@implementation NSString (PathNormalization)

- (NSString*)normalizedPath {
    
    if (self.length == 0) {
        return self;
    }
    
    NSMutableString *normalizedPath = [[NSString pathWithComponents:[self pathComponents]] mutableCopy];
    if ([normalizedPath characterAtIndex:0] != '/') {
        [normalizedPath insertString:@"/" atIndex:0];
    }
    if ([normalizedPath characterAtIndex:normalizedPath.length-1] != '/') {
        [normalizedPath appendString:@"/"];
    }

    return normalizedPath;
}

@end
