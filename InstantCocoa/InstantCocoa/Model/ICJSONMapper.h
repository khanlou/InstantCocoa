//
//  ICJSONMapper.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 3/10/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICModelProtocols.h"

@class ICModel;

@interface ICJSONMapper : NSObject

- (id)mapFromDictionary:(NSDictionary*)dictionary toObject:(id<ICMappable>)object;
- (id)mapFromJSONDictionary:(NSDictionary*)JSONDictionary toObject:(id<ICJSONMappable>)object;

- (NSDictionary*)JSONRepresentationOfObject:(id<ICJSONMappable>)object;
- (NSDictionary *)dictionaryRepresentationOfObject:(id<ICMappable>)object;

@end
