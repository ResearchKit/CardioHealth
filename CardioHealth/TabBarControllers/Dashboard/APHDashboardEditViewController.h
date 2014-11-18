//
//  APHDashboardEditViewController.h
//  CardioHealth
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import APCAppleCore;

typedef NS_ENUM(APCTableViewItemType, APHDashboardItemType) {
    kAPHDashboardItemTypeDistance,
    kAPHDashboardItemTypeHeartRate,
    kAPHDashboardItemTypeAlerts,
    kAPHDashboardItemTypeInsights,
};

@interface APHDashboardEditViewController : APCDashboardEditViewController

@end
