//
//  ICRoute.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/31/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICRoute.h"
#import "NSString+Regex.h"
#import "NSString+PathNormalization.h"

@interface ICSimpleRouteMatcher ()

@property (nonatomic, strong) NSString *regexForPath;
@property (nonatomic, strong) NSDictionary *parameterByMatchIndex;

@end

@implementation ICSimpleRouteMatcher

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (!self) {
        return nil;
    }
    _path = [path normalizedPath];
    [self generateRegexAndLookupDictionary];
    
    return self;
}

- (void)generateRegexAndLookupDictionary {
    NSMutableString *mutableRegexForPath = [_path mutableCopy];
    
    NSError *regexError;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\{(.*?)\\}" options:0 error:&regexError];
    
    if (regexError) {
        NSLog(@"error building path regex %@", regexError);
    }
    NSMutableDictionary *mutableParametersByMatchIndex = [NSMutableDictionary dictionary];
    
    NSArray *matches = [regularExpression matchesInString:_path options:0 range:NSMakeRange(0, _path.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult* result, NSUInteger idx, BOOL *stop) {
        
        NSString *parameterName = [_path substringWithRange:NSMakeRange(result.range.location+1, result.range.length-2)];
        if (parameterName.length != 0) {
            mutableParametersByMatchIndex[@(idx)] = parameterName;
        }
        
        [mutableRegexForPath replaceCharactersInRange:result.range withString:@"(.*?)"];
    }];
    [mutableRegexForPath appendString:@"$"];
    
    self.regexForPath = mutableRegexForPath;
    self.parameterByMatchIndex = mutableParametersByMatchIndex;
}

- (BOOL)canHandlePath:(NSString*)incomingPath {
    return [[incomingPath normalizedPath] matchesRegex:_regexForPath];
}

- (NSDictionary*)parametersForPath:(NSString*)incomingPath {
    NSString *pathToMatch = [incomingPath normalizedPath];
    
    NSMutableDictionary *mutableParameterDictionary = [NSMutableDictionary dictionary];
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:_regexForPath options:0 error:nil];
    
    NSTextCheckingResult *match = [regularExpression firstMatchInString:pathToMatch options:0 range:NSMakeRange(0, pathToMatch.length)];
    for (NSInteger captureGroupIndex = 1 /*ignore the first match*/; captureGroupIndex < match.numberOfRanges; captureGroupIndex++) {
        id parameterValue = [pathToMatch substringWithRange:[match rangeAtIndex:captureGroupIndex]];
        
        if ([parameterValue matchesRegex:@"^\\d+$"]) {
            parameterValue = [NSNumber numberWithInteger:[parameterValue integerValue]];
        }
        
        NSString *parameterKey = _parameterByMatchIndex[@(captureGroupIndex-1)];
        if (parameterKey) {
            mutableParameterDictionary[parameterKey] = parameterValue;
        }
    }
    
    return mutableParameterDictionary;
}

@end


@interface ICRoute ()

@property (nonatomic, strong) id<ICRouteMatcher> matcher;

@end

@implementation ICRoute

+ (instancetype)routeWithPath:(NSString *)path {
    return [[self alloc] initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {
    ICSimpleRouteMatcher *simpleMatcher = [[ICSimpleRouteMatcher alloc] initWithPath:path];
    return [self initWithMatcher:simpleMatcher];
}

- (instancetype)initWithMatcher:(id<ICRouteMatcher>)matcher {
    self = [super init];
    if (!self) {
        return nil;
    }
    _matcher = matcher;
    
    return self;
}

- (BOOL)canHandlePath:(NSString *)incomingPath {
    return [self.matcher canHandlePath:incomingPath];
}

- (NSDictionary *)parametersForPath:(NSString *)incomingPath {
    return [self.matcher parametersForPath:incomingPath];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, path=%@>", self.class, self, self.matcher];
}

@end
