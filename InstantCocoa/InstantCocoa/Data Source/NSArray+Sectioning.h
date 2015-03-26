//
//  NSArray+Sectioning.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 1/5/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FirstCharacter)

@property (nonatomic, readonly) NSString *firstCharacter;

@end


@interface NSArray (Sectioning)

- (NSArray*)sectionedArrayWithKey:(NSString*)sectioningKey;

@end
