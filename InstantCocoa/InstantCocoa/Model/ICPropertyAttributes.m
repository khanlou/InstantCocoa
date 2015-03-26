//
//  ICPropertyAttributes
//  InstantCoca
//
//  Created by Soroush Khanlou 12/26/2013.
//  Copyright (C) 2012 Soroush Khanlou.
//  Released under the MIT license.
//

#import "ICPropertyAttributes.h"
#import "ICInflector.h"

@interface ICPropertyAttributes ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong) NSString *attributesString;

@end

@implementation ICPropertyAttributes

@synthesize setter = _setter, getter = _getter;

+ (instancetype) propertyAttributesFromObjectiveCProperty:(objc_property_t)property {
    
    ICPropertyAttributes *propertyAttributes = [self new];
    propertyAttributes.name = @(property_getName(property));
    propertyAttributes.attributesString = @(property_getAttributes(property));
    
    return propertyAttributes;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    return self;
}

- (void) setAttributesString:(NSString *)attributesString {
    _attributesString = attributesString;
    
    NSArray *attributes = [attributesString componentsSeparatedByString:@","];
    for (NSString *attribute in attributes) {
        if ([attribute hasPrefix:@"T"]) {
            NSString *encodingType = [attribute substringFromIndex:1];
            if ([encodingType hasPrefix:@"@"]) {
                _type = @"object";
                _className = [encodingType substringWithRange:NSMakeRange(2, [encodingType length]-3)];  //turns @"NSDate" into NSDate
                NSRange lessThanRange = [encodingType rangeOfString:@"<"];
                if (lessThanRange.location != NSNotFound) {
                    lessThanRange.location = lessThanRange.location - 2;
                    _className = [_className stringByReplacingCharactersInRange:NSMakeRange(lessThanRange.location, _className.length - lessThanRange.location) withString:@""];
                }
            }
            if ([encodingType isEqualToString:[NSString stringWithUTF8String:@encode(int)]]) {
                _type = @"int";
            }
            if ([encodingType isEqualToString:[NSString stringWithUTF8String:@encode(float)]]) {
                _type = @"float";
            }
            if ([encodingType isEqualToString:[NSString stringWithUTF8String:@encode(float*)]]) {
                _type = @"float*";
            }
            if ([encodingType isEqualToString:[NSString stringWithUTF8String:@encode(char)]]) {
                _type = @"char";
            }
            if ([encodingType isEqualToString:[NSString stringWithUTF8String:@encode(char*)]]) {
                _type = @"char*";
            }
            if ([encodingType isEqualToString:[NSString stringWithUTF8String:@encode(void)]]) {
                _type = @"void";
            }
            if ([encodingType isEqualToString:[NSString stringWithUTF8String:@encode(void*)]]) {
                _type = @"void*";
            }
            NSRange lessThanRange = [encodingType rangeOfString:@"<"];
            NSRange greaterThanRange = [encodingType rangeOfString:@">" options:NSBackwardsSearch];
            if (lessThanRange.location != NSNotFound && greaterThanRange.location != NSNotFound) {
                NSRange protocolStringRange = NSMakeRange(lessThanRange.location + 1, greaterThanRange.location - lessThanRange.location - 1);
                NSString *protocolString = [encodingType substringWithRange:protocolStringRange];
                _protocols = [NSSet setWithArray:[protocolString componentsSeparatedByString:@"><"]];
            }
        }
        if ([attribute isEqualToString:@"N"]) {
            _nonatomic = YES;
        }
        if ([attribute isEqualToString:@"R"]) {
            _readOnly = YES;;
        }
        if ([attribute isEqualToString:@"&"]) {
            _memoryManagementPolicy = ICMemoryManagmentPolicyStrong;
        }
        if ([attribute isEqualToString:@"C"]) {
            _memoryManagementPolicy = ICMemoryManagmentPolicyCopy;
        }
        if ([attribute isEqualToString:@"W"]) {
            _weak = YES;
        }
        if ([attribute isEqualToString:@"D"]) {
            _dynamic = YES;
        }
        if ([attribute hasPrefix:@"V"]) {
            _instanceVariable = [attribute substringFromIndex:1];
        }
        if ([attribute hasPrefix:@"G"]) {
            _getter = NSSelectorFromString([attribute substringFromIndex:1]);
        }
        if ([attribute hasPrefix:@"S"]) {
            _setter = NSSelectorFromString([attribute substringFromIndex:1]);
        }
    }
}

- (SEL)getter {
    if (_getter) {
        return _getter;
    }
    return NSSelectorFromString(self.name);
}

- (SEL)setter {
    if (_setter) {
        return _setter;
    }
    return [[ICInflector sharedInflector] setterForProperty:self.name];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p; name=%@, type=%@, class=%@, nonatomic=%d, readOnly=%d, weak=%d, dynamic=%d, instanceVariable=%@, getter=%@, setter=%@>", self.class, self,
            self.name,
            self.type,
            self.className,
            self.nonatomic,
            self.readOnly,
            self.weak,
            self.dynamic,
            self.instanceVariable,
            NSStringFromSelector(self.getter),
            NSStringFromSelector(self.setter)];
}

@end
