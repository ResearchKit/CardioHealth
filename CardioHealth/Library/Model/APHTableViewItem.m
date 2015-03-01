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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _distanceWalked = 0;
        _peakHeartRate = 0;
        _finalHeartRate = 0;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\
            DistanceWalked : %ld\n\
            PeakHearRate : %ld\n\
            FinalHearRate : %ld\n\
            Date : %@\n", (long)self.distanceWalked, (long)self.peakHeartRate, (long)self.finalHeartRate, self.activityDate];
}
@end

@implementation APHTableViewDashboardSevenDayFitnessItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _activeMinutesString = @"";
        _numberOfDaysString = @"";
        _totalStepsString = @"";
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\
            numberOfDaysString : %@\n\
            activeMinutesString : %@\n\
            totalStepsString: %@", self.numberOfDaysString, self.activeMinutesString, self.totalStepsString];
    
    
    
    
}
@end