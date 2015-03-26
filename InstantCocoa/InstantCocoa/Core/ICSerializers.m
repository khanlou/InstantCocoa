//
//  ICDateSerializer.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/23/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import "ICSerializers.h"

@implementation ICDateSerializer

+ (NSDateFormatter*)defaultDateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    return dateFormatter;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        return self.class.defaultDateFormatter;
    }
    return _dateFormatter;
}

- (id) deserializedObjectFromString:(NSString *)stringRepresentation {
    return [self.dateFormatter dateFromString:stringRepresentation];
}

- (NSString*) serializedObject:(id)object {
    return [self.dateFormatter stringFromDate:object];
}

@end


@implementation ICURLSerializer

- (id)deserializedObjectFromString:(NSString *)stringRepresentation {
    return [NSURL URLWithString:stringRepresentation];
}

- (NSString*)serializedObject:(id)object {
    NSURL *urlToSerialize = object;
    return urlToSerialize.absoluteString;
}

@end
