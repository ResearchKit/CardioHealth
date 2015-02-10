//
//  APHTableViewItem.m
//  CardioHealth
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHTableViewItem.h"

@implementation APHTableViewItem

@end

@implementation APHTableViewDashboardFitnessControlItem

@end

@implementation APHTableViewDashboardWalkingTestItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"\
            DistanceWalked : %ld\n\
            PeakHearRate : %ld\n\
            FinalHearRate : %ld\n\
            Date : %@\n", (long)self.distanceWalked, (long)self.peakHeartRate, (long)self.finalHeartRate, self.activityDate];
}
@end