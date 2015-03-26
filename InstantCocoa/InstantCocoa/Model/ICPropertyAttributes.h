//
//  ICPropertyAttributes
//  InstantCoca
//
//  Created by Soroush Khanlou 12/26/2013.
//  Copyright (C) 2012 Soroush Khanlou.
//  Released under the MIT license.
//

#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, ICMemoryManagmentPolicy) {
    ICMemoryManagmentPolicyAssign = 0,
    ICMemoryManagmentPolicyStrong,
    ICMemoryManagmentPolicyCopy,
};

@interface ICPropertyAttributes : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL readOnly;
@property (nonatomic, assign, readonly) BOOL nonatomic;
@property (nonatomic, assign, readonly) BOOL weak;
@property (nonatomic, assign, readonly) BOOL dynamic;
@property (nonatomic, assign, readonly) ICMemoryManagmentPolicy memoryManagementPolicy;
@property (nonatomic, strong, readonly) NSSet *protocols;


@property (nonatomic, strong, readonly) NSString *instanceVariable;
@property (nonatomic, strong, readonly) NSString *type;
@property (nonatomic, strong, readonly) NSString *className;
@property (nonatomic, assign, readonly) SEL getter;
@property (nonatomic, assign, readonly) SEL setter;

+ (instancetype) propertyAttributesFromObjectiveCProperty:(objc_property_t)property;

@end