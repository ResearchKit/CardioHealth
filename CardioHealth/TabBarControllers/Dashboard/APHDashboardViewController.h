// 
//  APHDashboardViewController.h 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
@import APCAppCore;

@interface APHDashboardViewController : APCDashboardViewController


@end

@interface APHTableViewDashboardFitnessControlItem : APCTableViewDashboardItem

@end

@interface APHTableViewDashboardWalkingTestItem : APCTableViewDashboardItem

@property (nonatomic) NSInteger distanceWalked;
@property (nonatomic) NSInteger peakHeartRate;
@property (nonatomic) NSInteger finalHeartRate;
@property (nonatomic, strong) NSDate *lastPerformedDate;

@end