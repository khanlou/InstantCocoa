//
//  SKPost.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/22/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "SKPost.h"
#import "ICSerializers.h"

@implementation SKPost

+ (NSDictionary*)JSONMapping {
    return @{@"objectID": @"id",
             @"author": @"author",
             @"published": @"published",
             @"title": @"title",
             @"content": @"content",
             @"publishingDate": @"updated_at",
             @"canonicalURL": @"canonical_url",
             };
}

- (id<ICSerializer>) serializerForPublishingDate {
    ICDateSerializer *dateSerializer = [ICDateSerializer new];
    dateSerializer.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ"; //2011-07-14 19:43:37 +0100
    return dateSerializer;
}

+ (NSString*) endpointTemplateForSingleObject {
    return @"posts/@{objectID}.json";
}

- (void)transformJSONRepresentationBeforeMapping:(NSDictionary *__autoreleasing *)JSONRepresentation{
    NSMutableDictionary *mutableJSONRepresentation = [(*JSONRepresentation) mutableCopy];
    NSString *oldPublishedValue = mutableJSONRepresentation[@"published"];
    if ([oldPublishedValue isKindOfClass:[NSString class]]) {
        mutableJSONRepresentation[@"published"] = @([oldPublishedValue intValue]);
    }
    *JSONRepresentation = mutableJSONRepresentation;
}

@end
