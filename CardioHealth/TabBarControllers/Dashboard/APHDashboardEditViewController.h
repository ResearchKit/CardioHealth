// 
//  APHDashboardEditViewController.h 
//  MyHeart Counts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
@import APCAppCore;

typedef NS_ENUM(APCTableViewItemType, APHDashboardItemType) {
    kAPHDashboardItemTypeDistance,
    kAPHDashboardItemTypeHeartRate,
    kAPHDashboardItemTypeSevenDayFitness,
    kAPHDashboardItemTypeAlerts,
    kAPHDashboardItemTypeInsights,
    kAPHDashboardItemTypeWalkingTest
};

@interface APHDashboardEditViewController : APCDashboardEditViewController

@end
