//
//  ICInflectorTests.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/26/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ICInflector.h"

@interface ICInflectorTests : XCTestCase

@property (nonatomic, strong) NSString *camelCasedString;
@property (nonatomic, strong) NSString *snakeCasedString;
@property (nonatomic, strong) NSString *trainCasedString;
@property (nonatomic, strong) NSString *llamaCasedString;
@property (nonatomic, strong) NSString *displayCasedString;

@end


@implementation ICInflectorTests

- (void)setUp
{
    [super setUp];
    
    self.camelCasedString = @"LongPropertyName";
    self.snakeCasedString = @"long_property_name";
    self.trainCasedString = @"long-property-name";
    self.llamaCasedString = @"longPropertyName";
    self.displayCasedString = @"Long Property Name";
}

- (void)testAcronyms {
    XCTAssertEqualObjects([@"URLString" snakeCasedString], @"url_string", @"Breaking up words with acronyms in them should work properly");
    XCTAssertEqualObjects([@"aURLString" snakeCasedString], @"a_url_string", @"Breaking up words with acronyms in them should work properly");
    XCTAssertEqualObjects([@"someURLProperty" snakeCasedString], @"some_url_property", @"Breaking up words with acronyms in them should work properly");
    XCTAssertEqualObjects([@"canonicalURL" snakeCasedString], @"canonical_url", @"Words with acronyms at the end of them should work properly");
}


- (void)testSnakeCasing
{
    
    XCTAssertEqualObjects([_camelCasedString snakeCasedString], _snakeCasedString, @"Camel-cased objects should be able to return as snake cased");
    XCTAssertEqualObjects([_snakeCasedString snakeCasedString], _snakeCasedString, @"Snake-cased objects should be able to return as snake cased");
    XCTAssertEqualObjects([_llamaCasedString snakeCasedString], _snakeCasedString, @"Llama-cased objects should be able to return as snake cased");
    XCTAssertEqualObjects([_trainCasedString snakeCasedString], _snakeCasedString, @"Train-cased objects should be able to return as snake cased");
}

- (void)testLlamaCasing
{
    XCTAssertEqualObjects([_camelCasedString llamaCasedString], _llamaCasedString, @"Camel-cased objects should be able to return as llama cased");
    XCTAssertEqualObjects([_snakeCasedString llamaCasedString], _llamaCasedString, @"Snake-cased objects should be able to return as llama cased");
    XCTAssertEqualObjects([_llamaCasedString llamaCasedString], _llamaCasedString, @"Llama-cased objects should be able to return as llama cased");
    XCTAssertEqualObjects([_trainCasedString llamaCasedString], _llamaCasedString, @"Train-cased objects should be able to return as llama cased");
}

- (void)testDisplayCasing {
    XCTAssertEqualObjects([_camelCasedString displayString], _displayCasedString, @"Camel-cased objects should be able to return as display cased");
    XCTAssertEqualObjects([_snakeCasedString displayString], _displayCasedString, @"Snake-cased objects should be able to return as display cased");
    XCTAssertEqualObjects([_llamaCasedString displayString], _displayCasedString, @"Llama-cased objects should be able to return as display cased");
    XCTAssertEqualObjects([_trainCasedString displayString], _displayCasedString, @"Train-cased objects should be able to return as display cased");
}

- (void)testCamelCasing
{
    XCTAssertEqualObjects([_camelCasedString camelCasedString], _camelCasedString, @"Camel-cased objects should be able to return as camel cased");
    XCTAssertEqualObjects([_snakeCasedString camelCasedString], _camelCasedString, @"Snake-cased objects should be able to return as camel cased");
    XCTAssertEqualObjects([_llamaCasedString camelCasedString], _camelCasedString, @"Llama-cased objects should be able to return as camel cased");
    XCTAssertEqualObjects([_trainCasedString camelCasedString], _camelCasedString, @"Train-cased objects should be able to return as camel cased");
}

- (void)testTrainCasing
{
    XCTAssertEqualObjects([_camelCasedString trainCasedString], _trainCasedString, @"Camel-cased objects should be able to return as train cased");
    XCTAssertEqualObjects([_snakeCasedString trainCasedString], _trainCasedString, @"Snake-cased objects should be able to return as train cased");
    XCTAssertEqualObjects([_llamaCasedString trainCasedString], _trainCasedString, @"Llama-cased objects should be able to return as train cased");
    XCTAssertEqualObjects([_trainCasedString trainCasedString], _trainCasedString, @"Train-cased objects should be able to return as train cased");
}

- (void)testSelectorBuilding {
    SEL selectorWithNilPrefix = [[ICInflector sharedInflector] selectorWithPrefix:nil propertyName:@"someProperty" suffix:@"withSuffix:"];
    XCTAssertEqualObjects(NSStringFromSelector(selectorWithNilPrefix), @"somePropertyWithSuffix:", @"Creating a selector with a nil prefix should llama case as expected");
    
    SEL selectorWithNilSuffix = [[ICInflector sharedInflector] selectorWithPrefix:@"validate" propertyName:@"someProperty" suffix:nil];
    XCTAssertEqualObjects(NSStringFromSelector(selectorWithNilSuffix), @"validateSomeProperty", @"Creating a selector with a nil suffix should llama case as expected");
    
    SEL selectorWithPropertyName = [[ICInflector sharedInflector] selectorWithPrefix:@"prefixingWith" propertyName:nil suffix:@"someSuffix:"];
    XCTAssertEqualObjects(NSStringFromSelector(selectorWithPropertyName), @"prefixingWithSomeSuffix:", @"Creating a selector with a property name should llama case as expected");
    
    SEL selectorWithColons = [[ICInflector sharedInflector] selectorWithPrefix:@"doThing:" propertyName:@"name:" suffix:@"otherParameter:"];
    XCTAssertEqualObjects(NSStringFromSelector(selectorWithColons), @"doThing:name:otherParameter:", @"Creating a selector with multiple colons should llama case as expected");
    
    SEL selectorWithNoTrailingColon = [[ICInflector sharedInflector] selectorWithPrefix:@"doThing:" propertyName:@"name:" suffix:@"otherParameter"];
    XCTAssertEqualObjects(NSStringFromSelector(selectorWithNoTrailingColon), @"doThing:name:otherParameter", @"Creating a selector with multiple colons should llama case as expected");

}

@end
