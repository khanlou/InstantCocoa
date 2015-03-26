//
//  SKTestingPost.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/28/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICTestingPost.h"
#import "ICSerializers.h"
#import <objc/runtime.h>

@implementation ICPropertyTester

@dynamic dynamicProperty;

@end

@implementation ICPostTitle @end

@implementation ICTestingAuthor

+ (NSDictionary *)JSONMapping {
    return @{ @"authorName": @"name" };
}

@end

@implementation ICTestingPost


+ (NSDictionary*)JSONMapping {
    return @{@"author": @"author",
             @"title": @"post_title",
             @"content": @"post_text",
             @"publishingDate": @"publishing_date",
             @"canonicalURL": @"urls.canonical",
             @"garbageKey": @"garbage_key",
             @"transformedProperty": @"transformed_property"
             };
}

- (id<ICSerializer>) serializerForPublishingDate {
    ICDateSerializer *dateSerializer = [ICDateSerializer new];
    dateSerializer.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ"; //2011-07-14 19:43:37 +0100
    return dateSerializer;
}

- (void)transformJSONRepresentationBeforeMapping:(NSDictionary *__autoreleasing *)JSONRepresentation{
    NSMutableDictionary *mutableJSONRepresentation = [(*JSONRepresentation) mutableCopy];
    NSString *preTransformedValue = mutableJSONRepresentation[@"transformed_property"];
    if ([preTransformedValue isKindOfClass:[NSNumber class]]) {
        mutableJSONRepresentation[@"transformed_property"] = [NSString stringWithFormat:@"%@", preTransformedValue];
    }
    *JSONRepresentation = mutableJSONRepresentation;
}

+ (NSString *)APIEndpoint {
    return @"posts.json";
}

+ (Class)mappingClassForAuthors {
    return [ICTestingAuthor class];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(dynamicProperty)) {
        IMP implementation  = imp_implementationWithBlock((id) ^(id self) {
            return @"";
        });
        
        class_addMethod(self, sel, implementation, "@@:");
        return YES;
    } else if (sel == @selector(setDynamicProperty:)) {
        IMP implementation  = imp_implementationWithBlock((id) ^(id self, id arg1) {

        });
        class_addMethod(self, sel, implementation, "v@:@");

        return YES;
    }
    return [super resolveInstanceMethod:sel];
}



@end
