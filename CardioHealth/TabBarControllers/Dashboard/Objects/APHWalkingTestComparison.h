//
//  APHWalkingTestComparison.h
//  CardioHealth
//
//  Created by Ramsundar Shandilya on 5/14/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

@import APCAppCore;

@interface APHWalkingTestComparison : NSObject <APCLineGraphViewDataSource>

- (CGFloat)zScoreForDistanceWalked:(CGFloat)distanceWalked;
- (CGFloat)distancePercentForZScore:(CGFloat)zScore;

@end
