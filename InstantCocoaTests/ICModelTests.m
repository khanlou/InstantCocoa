//
//  ICModelTests.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/22/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ICTestingPost.h"
#import "ICPropertyAttributes.h"
#import <NSArray+FunctionalMethods.h>
#import "ICJSONMapper.h"

@interface ICModelTests : XCTestCase

@end

@implementation ICModelTests

- (void)testPropertyAttributes {
    NSDictionary *propertyNames = [ICPropertyTester properties];
    
    ICPropertyAttributes *weakAttributes = propertyNames[@"weakProperty"];
    XCTAssert(weakAttributes.weak == YES, @"Weak properties should have the weak flag set to `YES`.");
    
    ICPropertyAttributes *dynamicAttributes = propertyNames[@"dynamicProperty"];
    XCTAssert(dynamicAttributes.dynamic == YES, @"Dynamic properties should have the dynamic flag set to `YES`.");
    
    ICPropertyAttributes *readonlyAttributes = propertyNames[@"readonlyProperty"];
    XCTAssert(readonlyAttributes.readOnly == YES, @"Readonly properties should have the readOnly flag set to `YES`.");
    
    ICPropertyAttributes *propertyWithCustomAccessorsAttributes = propertyNames[@"propertyWithCustomAccessors"];
    XCTAssert(propertyWithCustomAccessorsAttributes.setter == @selector(weirdSetter:), @"Properties with custom setters should present the correct setter.");
    XCTAssert(propertyWithCustomAccessorsAttributes.getter == @selector(someGetter), @"Properties with custom getters should present the correct getters.");
    
    ICPropertyAttributes *copyAttributes = propertyNames[@"copiedProperty"];
    XCTAssert(copyAttributes.memoryManagementPolicy == ICMemoryManagmentPolicyCopy, @"Copied properties should have the `copy` memory management policy.");
    
    
    ICPropertyAttributes *attributeWithTwoProtocols = propertyNames[@"propertyWithTwoProtocols"];
    XCTAssert([attributeWithTwoProtocols.protocols containsObject:@"NSCopying"], @"The protocols on the `propertyWithTwoProtocols` key should include the NSCopying protocol");
    XCTAssert([attributeWithTwoProtocols.protocols containsObject:@"NSObject"], @"The protocols on the `propertyWithTwoProtocols` key should include the NSObject protocol");
}

- (void)testDictionaryMapping {
    NSDictionary *postAsDictionary = @{@"author": @{@"authorName": @"soroush"},
                                       @"content": @"Here's a test post from Soroush",
                                       @"published": @NO, };
    ICTestingPost *aPost = [[ICTestingPost alloc] initWithDictionary:postAsDictionary];
    
    XCTAssert([aPost.author.authorName isEqual:postAsDictionary[@"author"][@"authorName"]], @"Mapping from dictionary key to property key should work");
    XCTAssert([aPost.author isKindOfClass:[ICTestingAuthor class]], @"Mapping from dictionary to local object should map child objects");
    XCTAssert([aPost.content isEqual:postAsDictionary[@"content"]], @"Mapping from dictionary key to property key should work");
    XCTAssert(aPost.published == [postAsDictionary[@"published"] boolValue], @"Mapping from dictionary key to primitive property key should work");
    
    NSDictionary *dictionaryRepresentation = [aPost dictionaryRepresentation];
    
    XCTAssertEqualObjects(postAsDictionary[@"author"][@"authorName"], dictionaryRepresentation[@"author"][@"authorName"], @"Converting an object from a dictionary and back to a dictionary should work");
    XCTAssertEqualObjects(postAsDictionary[@"published"], dictionaryRepresentation[@"published"], @"Converting an object from JSON and back to JSON should work for primitive keys");
    XCTAssertEqualObjects(postAsDictionary[@"canonical_url"], dictionaryRepresentation[@"canonical_url"], @"Converting an object from JSON and back to JSON should work");

}

- (void)testEqualityAndHashing {
    NSDictionary *postAsDictionary = @{@"author": @{@"authorName": @"soroush"},
                                       @"content": @"Here's a test post from Soroush",
                                       @"published": @NO, };
    ICTestingPost *aPost = [[ICTestingPost alloc] initWithDictionary:postAsDictionary];
    ICTestingPost *aSecondPost = [[ICTestingPost alloc] initWithDictionary:postAsDictionary];
    
    XCTAssert([aPost isEqual:aSecondPost], @"Two model objects generated from the same dictionary should be equal");
    XCTAssert(aPost.hash == aSecondPost.hash, @"Two model objects built from the same dictionary should generate the same hash");
}

- (void)testJSONMapping {
    
    XCTAssertNil([[ICTestingPost class] JSONMapping][@"published"], @"ICTestingPost should not include a key for published, and mapping to that key should work regardless of its extistence in the `JSONMapping`");

    NSDictionary *JSONPost = @{@"author": @{@"name": @"soroush"},
                               @"published": @YES,
                               @"publishing_date": @"2011-07-14 19:43:37 +0100",
                               @"post_title": @"A post with a title",
                               @"urls": @{ @"canonical": @"http://khanlou.com/2013/12/objective-shorthand/" },
                               @"post_text": [NSNull null],
                               };
    
    ICTestingPost *aPost = [[ICTestingPost alloc] initWithJSONDictionary:JSONPost];
    XCTAssert([aPost.author.authorName isEqual:JSONPost[@"author"][@"name"]], @"Mapping a relationship to another ICModel should work");
    XCTAssertNil(aPost.content, @"Mapping from a JSON `null` object should be nil");
    XCTAssert([aPost.publishingDate isKindOfClass:[NSDate class]], @"Using ICSerializer to deserialize from a string to a date should work");
    XCTAssertTrue(aPost.published, @"Mapping a key that is not specified in the JSONMapping should work");
    XCTAssert([aPost.canonicalURL isKindOfClass:[NSURL class]], @"Using ICSerializer to deserialize from a string to a URL should work");
    XCTAssert([aPost.canonicalURL.absoluteString isEqual:JSONPost[@"urls"][@"canonical"]], @"Mapping from nested JSON key to property key should work");
    

    
    NSDictionary *JSONRepresentation = [aPost JSONRepresentation];
    
    XCTAssertEqualObjects(JSONPost[@"author"][@"name"], JSONRepresentation[@"author"][@"name"], @"Converting an object from JSON and back to JSON should work");
    XCTAssertNil(JSONRepresentation[@"author"][@"objectID"], @"should be nil");
    XCTAssertEqualObjects(JSONPost[@"published"], JSONRepresentation[@"published"], @"Converting an object from JSON and back to JSON should work for primitive keys");
    XCTAssertEqualObjects(JSONPost[@"canonical_url"], JSONRepresentation[@"canonical_url"], @"Converting an object from JSON and back to JSON should work");
    
    
    NSDictionary *dictionaryRepresentation = [aPost dictionaryRepresentation];
    
    XCTAssertEqualObjects(aPost.author.authorName, dictionaryRepresentation[@"author"][@"authorName"], @"Converting an object to a dictionary should child objects to dictionaries also");
    XCTAssertEqualObjects(aPost.title.backingObject, dictionaryRepresentation[@"title"], @"Converting an object to a dictionary should convert value objects to Foundation types");
    XCTAssertEqualObjects(aPost.canonicalURL.absoluteString , dictionaryRepresentation[@"canonicalURL"], @"Converting an object to a dictionary should use the deserializer to convert to a Foundation type");

    NSDictionary *updatedJSONPost = @{@"author": @{@"name": @"kourosh"}, };
    
    ICTestingAuthor *oldAuthor = aPost.author;
    [[ICJSONMapper new] mapFromJSONDictionary:updatedJSONPost toObject:aPost];

    XCTAssertEqualObjects(aPost.author.authorName, @"kourosh", @"Using the JSON mapper to update an object should word.");
    XCTAssertEqual(aPost.author, oldAuthor, @"Updating an object using the JSON mapper should not replace the object's reference.");
}

- (void)testCollectableMapping {
    NSDictionary *postAsDictionary = @{@"authors": @[
                                               @{ @"name": @"soroush"},
                                               @{ @"name": @"kourosh"},
                                               ],
                                       @"content": @"Here's a test post from Soroush",
                                       @"published": @NO, };
    
    ICTestingPost *aPost = [[ICTestingPost alloc] initWithJSONDictionary:postAsDictionary];
    
    XCTAssert(aPost.authors.count == 2, @"Mapping JSON arrays to native arrays should work");
    
    XCTAssert([aPost.authors[0] isKindOfClass:[ICTestingAuthor class]], @"Mapping JSON arrays to native arrays should also map each object in the collection to an ICTestingAuthor");
    XCTAssert([aPost.authors[1] isKindOfClass:[ICTestingAuthor class]], @"Mapping JSON arrays to native arrays should also map each object in the collection to an ICTestingAuthor");
    
    XCTAssertEqual([aPost.authors[0] authorName], @"soroush", @"mapping an author name should work correctly");
    XCTAssertEqual([aPost.authors[1] authorName], @"kourosh", @"mapping an author name should work correctly");
    XCTAssertNil(aPost.title, @"Mapping should return nil for values not in the dictionary.");
    
    NSDictionary *JSONRepresenation = [aPost JSONRepresentation];
    
    NSArray *authors = JSONRepresenation[@"authors"];
    
    [authors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssert([obj isKindOfClass:[NSDictionary class]], @"When mapping a native array back to a JSON array, all objects inside should be dictionaries");
    }];
}

- (void)testSetMapping {
    NSDictionary *postAsDictionary = @{@"likes": @[
                                               @"soroush",
                                               @"kourosh",
                                               ],
                                       };
    
    ICTestingPost *aPost = [[ICTestingPost alloc] initWithJSONDictionary:postAsDictionary];
    
    XCTAssert([aPost.likes isKindOfClass:[NSSet class]], @"Mapping JSON arrays to native sets should work");
    
    XCTAssert(aPost.likes.count == 2, @"Mapping JSON arrays to native sets should work");
    
    
    XCTAssert([aPost.likes containsObject:@"soroush"], @"Mapping JSON arrays to native sets should contain all objects in the array");
    XCTAssert([aPost.likes containsObject:@"kourosh"], @"Mapping JSON arrays to native sets should contain all objects in the array");
    
    
    NSDictionary *JSONRepresenation = [aPost JSONRepresentation];
    
    NSArray *authors = JSONRepresenation[@"likes"];
    
    XCTAssert([authors isKindOfClass:[NSArray class]], @"Mapping native sets back to JSON create arrays");
}

- (void)testValueObjectMapping {
    NSDictionary *postAsDictionary = @{
                                       @"post_title": @"A post title!",
                                       @"content": @"Here's a test post from Soroush",
                                       };
    
    ICTestingPost *aPost = [[ICTestingPost alloc] initWithJSONDictionary:postAsDictionary];
    
    XCTAssert([aPost.title isKindOfClass:[ICPostTitle class]], @"Mapping a value object should work");
    XCTAssertEqualObjects(aPost.title.backingObject, @"A post title!", @"Mapping a value object should contain the correct value");
    XCTAssertNil(aPost.author, @"Mapping should return nil for values not in the dictionary.");
    XCTAssertNil(aPost.likes, @"Mapping should return nil for values not in the dictionary.");

    NSDictionary *JSONRepresenation = [aPost JSONRepresentation];
    
    NSString *JSONTitle = JSONRepresenation[@"post_title"];
    XCTAssert([JSONTitle isKindOfClass:[NSString class]], @"Mapping a value object back to JSON should use the original JSON type");
    XCTAssertEqualObjects(JSONTitle, @"A post title!", @"Mapping a value object back to JSON should contain the correct value");
}

- (void)testDictionaryMappingFailure {
    NSDictionary *garbagePost = @{@"garbage in": @"garbage out"};
    XCTAssertNoThrow([[ICTestingPost alloc] initWithDictionary:garbagePost], @"Mapping to a dictionary with a key that doesn't exist should throw an exception");
}

- (void)testJSONTransformation {
    NSDictionary *postAsDictionary = @{
                                       @"transformed_property": @123,
                                       };
    
    ICTestingPost *aPost = [[ICTestingPost alloc] initWithJSONDictionary:postAsDictionary];
    
    XCTAssert([aPost.transformedProperty isKindOfClass:[NSString class]], @"JSON mapping should be transformed if the model requires it.");
}

- (void)testObjectCoding {
    NSDictionary *postAsDictionary = @{@"author": @{@"authorName": @"Soroush"},
                                       @"content": @"Here's a test post from Soroush",
                                       @"published": @NO,
                                       };
    ICTestingPost *preCodingPost = [[ICTestingPost alloc] initWithDictionary:postAsDictionary];
    
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:preCodingPost];
    
    ICTestingPost *aPost = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    
    XCTAssert([preCodingPost isEqual:aPost], @"An object archived and unarchived should be equal to the original object");
    XCTAssert([preCodingPost.author isEqual:aPost.author], @"An object archived and unarchived should be equal to the original object");
    XCTAssert([preCodingPost.content isEqual:aPost.content], @"An object archived and unarchived should be equal to the original object");
    XCTAssert(preCodingPost.published == aPost.published, @"An object archived and unarchived should be equal to the original object");

}



@end
