//
//  SKTestingPost.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/28/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICModel.h"
#import "ICValueObject.h"

@interface ICPropertyTester : ICModel

@property (nonatomic, strong, readonly) NSString *readonlyProperty;
@property (nonatomic, strong) NSString *dynamicProperty;
@property (nonatomic, copy) NSString *copiedProperty;
@property (nonatomic, weak) NSString *weakProperty;
@property (nonatomic, strong, setter = weirdSetter:, getter = someGetter) NSString *propertyWithCustomAccessors;
@property (nonatomic, strong) id<NSObject, NSCopying> propertyWithTwoProtocols;


@end

@interface ICTestingAuthor : ICModel

@property (nonatomic, strong) NSString *authorName;

@end

@interface ICPostTitle : ICValueObject

@end


@interface ICTestingPost : ICModel

@property (nonatomic, strong) ICTestingAuthor *author;
@property (nonatomic, strong) NSDate *publishingDate;
@property (nonatomic, strong) ICPostTitle *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSURL *canonicalURL;
@property (nonatomic, strong) NSString *nonMappedProperty;
@property (nonatomic, strong) NSArray *authors;
@property (nonatomic, strong) NSSet *likes;
@property (nonatomic, strong) NSString *transformedProperty;

@property (nonatomic, assign, getter = isPublished) BOOL published;

@end
