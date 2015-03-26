//
//  ICModel2.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/15/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICModelProtocols.h"
#import "ICResourceGateway.h"

@class ICResourceGateway;

@interface ICModel : NSObject <ICJSONMappable, ICInspectable, ICRemoteObject>

+ (NSString *)modelName;

@property (nonatomic, strong) id<NSCopying, NSObject> objectID;

+ (ICResourceGateway *)gateway;

@property (nonatomic, strong, readonly) ICResourceGateway *gateway;

@end

