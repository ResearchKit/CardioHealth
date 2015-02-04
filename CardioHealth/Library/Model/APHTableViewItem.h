//
//  APHTableViewItem.h
//  CardioHealth
//
//  Created by Ramsundar Shandilya on 2/4/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <APCAppCore/APCAppCore.h>

@interface APHTableViewItem : APCTableViewItem

@end

@interface APHTableViewDashboardFitnessControlItem : APCTableViewDashboardItem

@end

@interface APHTableViewDashboardWalkingTestItem : APCTableViewDashboardItem

@property (nonatomic) NSInteger distanceWalked;
@property (nonatomic) NSInteger peakHeartRate;
@property (nonatomic) NSInteger finalHeartRate;
@property (nonatomic, strong) NSDate *lastPerformedDate;

@end