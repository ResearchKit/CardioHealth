//
//  YMLScoring.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 10/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@import APCAppCore;

typedef NS_ENUM(NSUInteger, YMLScoreDataKinds)
{
    APHDataKindNone = 0,
    APHDataKindSystolicBloodPressure,
    APHDataKindTotalCholesterol,
    APHDataKindHDL,
    APHDataKindHeartRate,
    APHDataKindWalk
};

@interface APHScoring : NSEnumerator <APCLineGraphViewDataSource>

- (instancetype)initWithKind:(NSUInteger)kind numberOfDays:(NSUInteger)numberOfDays correlateWithKind:(NSUInteger)correlateKind;
- (NSNumber *)minimumDataPoint;
- (NSNumber *)maximumDataPoint;
- (NSNumber *)averageDataPoint;
- (id)nextObject;

@end
