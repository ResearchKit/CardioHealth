// 
//  APHTableViewItem.m 
//  MyHeart Counts 
// 
// Copyright (c) 2015, Stanford Medical. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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

@implementation APHTableViewDashboardWalkingTestComparisonItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _distanceWalked = 0;
        _comparisonObject = [APHWalkingTestComparison new];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\
            DistanceWalked : %ld\n", (long)self.distanceWalked];
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

@implementation APHTableViewDashboardDailyInsightItem

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _insightTitle = nil;
        _insightAttributedTitle = nil;
        _insightSubtitle = nil;
        _insightImage = nil;
    }
    
    return self;
}

@end







