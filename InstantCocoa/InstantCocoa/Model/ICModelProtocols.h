//
//  ICModelProtocols.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 6/8/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ICKeyValueCodable <NSObject>

- (id)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;
- (id)valueForKeyPath:(NSString *)keyPath;
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;
- (NSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys;
- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

@end

@protocol ICInspectable <NSObject>

+ (NSDictionary*)properties;

@end


@protocol ICMappable <ICKeyValueCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, copy, readonly) NSDictionary *dictionaryRepresentation;

@end


@protocol ICJSONMappable <ICMappable>

+ (NSDictionary*)JSONMapping;

- (instancetype)initWithJSONDictionary:(NSDictionary*)JSONDictionary;

@property (nonatomic, copy, readonly) NSDictionary *JSONRepresentation;

@optional
- (void)transformJSONRepresentationBeforeMapping:(NSDictionary**)JSONRepresentation;

@end


@protocol ICRemoteObject <NSObject>

+ (NSString *)resourceEndpoint;
- (NSString *)resourceEndpoint;

@optional
+ (NSString *)remoteKeyPath;

@end


@protocol ICRoutable <NSObject>

- (instancetype)initWithRoutingInfo:(NSDictionary *)routingInfo;

@end