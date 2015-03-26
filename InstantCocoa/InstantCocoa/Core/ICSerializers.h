//
//  ICDateSerializer.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/23/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ICSerializer <NSObject>

- (NSString*)serializedObject:(id)object;
- (id)deserializedObjectFromString:(NSString*)stringRepresentation;

@end

@interface ICDateSerializer : NSObject <ICSerializer>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@interface ICURLSerializer : NSObject <ICSerializer>

@end
