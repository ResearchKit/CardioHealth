//
//  APHHeartAgeSink.m
//  CardioHealth
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

#import "APHHeartRateSink.h"

@interface APHHeartRateSink()

@property (nonatomic, strong)   NSDate* activeApplicationDate;
@property (nonatomic, assign)   double  intervalSinceLastUpdate;

@end

@implementation APHHeartRateSink

- (void)didReceiveUpdatedHealthkitSamplesFromCollector:(id)results withUnit:(HKUnit *)unit
{
    //  Expecting to get an array of updates.
    if ([results isKindOfClass:[NSArray class]])
    {
        NSArray*    arrayResult     = (NSArray*)results;
        NSDate*     targetDate      = [self applicationActiveDate];
        
        NSUInteger  ndx = [arrayResult indexOfObjectPassingTest:^(HKQuantitySample* qtySample, NSUInteger __unused ndx, BOOL* __unused stop)
        {
            return [qtySample.startDate isLaterThanDate:targetDate];
        }];
        
        if (ndx != NSNotFound)
        {
            self.lastUpdate         = ((HKQuantitySample*)[arrayResult lastObject]).startDate;
            self.numberOfUpdates    = arrayResult.count - ndx;
        }
    }
    [super didReceiveUpdatedHealthkitSamplesFromCollector:results withUnit:unit];
}

- (instancetype)initWithQuantityIdentifier:(NSString*)identifier
                               columnNames:(NSArray*)columnNames
                        operationQueueName:(NSString*)operationQueueName
                             dataProcessor:(APCQuantityCSVSerializer)transformer
                         fileProtectionKey:(NSString*)fileProtectionKey
                              andAppLaunch:(ForegroundLaunchDate)foregroundLaunchDate
{
    self = [super initWithQuantityIdentifier:identifier columnNames:columnNames operationQueueName:operationQueueName dataProcessor:transformer fileProtectionKey:fileProtectionKey];
    
    if (self)
    {
        _launchDate                 = foregroundLaunchDate;
        _numberOfUpdates            = 0;
        _lastUpdate                 = nil;
        _intervalSinceLastUpdate    = -1;
    }
    
    return self;
}

- (NSInteger)numberOfUpdatesSinceAppLaunch
{
    return self.numberOfUpdates;
}

- (double)intervalSinceLastHeartRateUpdate
{
    self.intervalSinceLastUpdate = -1;
    
    if (self.lastUpdate)
    {
        self.intervalSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:self.lastUpdate];
    }
    
    return self.intervalSinceLastUpdate;
}

- (NSDate*)applicationActiveDate
{
    return self.launchDate();
}

@end
