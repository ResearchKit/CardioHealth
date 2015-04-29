// 
//  APHWalkingTestResults.m 
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
 
#import "APHWalkingTestResults.h"

static NSString*  const kFitnessTestTaskId                      = @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995";
static NSString*  const kAPCTaskAttributeUpdatedAt              = @"updatedAt";
static NSString*  const kFitTestPedometerDistDataSourceKey      = @"pedometerDistance";
static NSString*  const kFitTestTotalDistDataSourceKey          = @"totalDistance";
static NSString*  const kFitTestpeakHeartRateDataSourceKey      = @"peakHeartRate";
static NSString*  const kFitTestlastHeartRateDataSourceKey      = @"lastHeartRate";

static CGFloat    const kMetersToYardConversion                 = 1.093f;

@implementation APHWalkingTestResults

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self fetchResults];
    }
    return self;
}

- (void)fetchResults
{
    NSMutableArray *finalResults = [NSMutableArray new];
    
    
    NSString *taskId = kFitnessTestTaskId;
    APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kAPCTaskAttributeUpdatedAt
                                                                          ascending:NO];
    NSFetchRequest *request = [APCScheduledTask request];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(task.taskID == %@) AND (completed == 1)", taskId];
    request.predicate = predicate;
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *tasks = [appDelegate.dataSubstrate.mainContext executeFetchRequest:request error:&error];
    
    if (error) {
        APCLogError2(error);
    }
    
    
    APCScheduledTask *task = [tasks firstObject];
    NSDictionary *result = nil;
    NSArray *schedTaskResult = [task.results allObjects];
    NSSortDescriptor *sorDescrip = [[NSSortDescriptor alloc] initWithKey:kAPCTaskAttributeUpdatedAt
                                                                          ascending:NO];
    
    NSArray *taskResults = [schedTaskResult sortedArrayUsingDescriptors:@[sorDescrip]];
    NSString *resultSummary = nil;
    
    for (APCResult* taskResult in taskResults) {
        APHTableViewDashboardWalkingTestItem *item = [APHTableViewDashboardWalkingTestItem new];
        resultSummary = [taskResult resultSummary];
        
        if (resultSummary) {
            NSData *resultData = [resultSummary dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            result = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                APCLogError2(error);
            }
        }
        
        //  The condition below supports older users who have distance data using CLLocation and users with CMPedometer
        if ([result objectForKey:kFitTestPedometerDistDataSourceKey] || [result objectForKey:kFitTestTotalDistDataSourceKey])
        {
            NSInteger totalDistance = 0;
            
            if ([result objectForKey:kFitTestPedometerDistDataSourceKey])
            {
                totalDistance = [[result objectForKey:kFitTestPedometerDistDataSourceKey] integerValue];
            }
            else if ([result objectForKey:kFitTestTotalDistDataSourceKey])
            {
                totalDistance = [[result objectForKey:kFitTestTotalDistDataSourceKey] integerValue];
            }
            else
            {
                APCLogDebug(@"This should not happen. Displacement may not have occurred.");
            }
            
            item.distanceWalked = totalDistance * kMetersToYardConversion;
        }
        
        if ([result objectForKey:kFitTestpeakHeartRateDataSourceKey]) {
            item.peakHeartRate = [[result objectForKey:kFitTestpeakHeartRateDataSourceKey] integerValue];
        }
        
        if ([result objectForKey:kFitTestlastHeartRateDataSourceKey]) {
            item.finalHeartRate = [[result objectForKey:kFitTestlastHeartRateDataSourceKey] integerValue];
        }
        
        if (taskResult.updatedAt) {
            item.activityDate = taskResult.updatedAt;
        }
        
        [finalResults addObject:item];
    }
    
    self.results = [NSArray arrayWithArray:finalResults];
    
}
@end
