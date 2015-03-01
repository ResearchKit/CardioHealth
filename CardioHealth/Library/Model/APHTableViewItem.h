//
//  APHTableViewItem.h
//  CardioHealth
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <APCAppCore/APCAppCore.h>

@interface APHTableViewItem : APCTableViewItem

@end

@interface APHTableViewDashboardFitnessControlItem : APCTableViewDashboardItem

@end

typedef NS_ENUM(NSUInteger, APHWalkingTestRowType) {
    kAPHWalkingTestRowTypeDistanceWalked,
    kAPHWalkingTestRowTypePeakHeartRate,
    kAPHWalkingTestRowTypeFinalHeartRate,
};

@interface APHTableViewDashboardWalkingTestItem : APCTableViewDashboardItem

@property (nonatomic) NSInteger distanceWalked;
@property (nonatomic) NSInteger peakHeartRate;
@property (nonatomic) NSInteger finalHeartRate;
@property (nonatomic, strong) NSDate *activityDate;

@end

@interface APHTableViewDashboardSevenDayFitnessItem : APCTableViewDashboardItem

@property (nonatomic) NSString *numberOfDaysString;
@property (nonatomic) NSString *activeMinutesString;
@property (nonatomic) NSString *totalStepsString;

@end