//
//  NPRCrustChartTests.m
//  PubCharts
//
//  Created by Michael Seifollahi on 1/6/14.
//  Copyright (c) 2014 NPR. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NPRCrustChart_NPRCrustChartTests.h"

@interface NPRCrustChartTests : XCTestCase

@property (nonatomic, strong) NPRCrustChart *ccLessThan100;
@property (nonatomic, strong) NPRCrustChart *ccGreaterThan100;
@property (nonatomic, strong) NPRCrustChart *ccEqualTo100;

@end

@implementation NPRCrustChartTests

- (void)setUp
{
    [super setUp];
    
    self.ccLessThan100 =
        [[NPRCrustChart alloc] initWithFrame:CGRectMake(20.0f, 64.0f, 280.0f, 280.0f)
                              withValues:@[@25.0f, @27.0f, @13.0f]
                                   withColors:@[[UIColor redColor], [UIColor lightGrayColor], [UIColor blueColor]]];
    self.ccGreaterThan100 =
        [[NPRCrustChart alloc] initWithFrame:CGRectMake(20.0f, 64.0f, 280.0f, 280.0f)
                              withValues:@[@25.0f, @27.0f, @13.0f, @47.0f]
                                   withColors:@[[UIColor redColor], [UIColor lightGrayColor], [UIColor blueColor], [UIColor blackColor]]];
    
    self.ccEqualTo100 =
        [[NPRCrustChart alloc] initWithFrame:CGRectMake(20.0f, 64.0f, 280.0f, 280.0f)
                              withValues:@[@25.0f, @27.0f, @13.0f, @35.0f]
                                   withColors:@[[UIColor redColor], [UIColor lightGrayColor], [UIColor blueColor], [UIColor yellowColor]]];
    
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    
    self.ccLessThan100 = nil;
    self.ccGreaterThan100 = nil;
    self.ccEqualTo100 = nil;
    
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testPublicInterface
{
    XCTAssertTrue([self.ccEqualTo100 percentageForSegment:@0] == 25.0f,
                  @"percentage for segment 0 should be equal to 25.0f");
    XCTAssertTrue([self.ccEqualTo100 percentageForSegment:@1] == 27.0f,
                  @"percentage for segment 1 should be equal to 27.0f");
    XCTAssertTrue([self.ccEqualTo100 percentageForSegment:@2] == 13.0f,
                  @"percentage for segment 2 should be equal to 13.0f");
    XCTAssertTrue([self.ccEqualTo100 percentageForSegment:@3] == 35.0f,
                  @"percentage for segment 3 should be equal to 35.0f");
    
    XCTAssertTrue([self.ccEqualTo100 percentageForSegment:@4] == 0.0f,
                  @"percentage for an invalid segment should be equal to 0.0f");
    XCTAssertTrue([self.ccEqualTo100 percentageForSegment:@8] == 0.0f,
                  @"percentage for an invalid segment should be equal to 0.0f");
}

- (void)testExample
{
    NSArray *result =
        [NPRCrustChart convertArrayToPercentages:@[@33.0f, @27.0f, @22.0f]];
    XCTAssertNotNil(result, @"Resulting array should not be nil");
}

@end
