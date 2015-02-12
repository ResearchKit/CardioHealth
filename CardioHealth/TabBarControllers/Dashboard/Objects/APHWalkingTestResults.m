//
//  APHWalkingTestResults.m
//  CardioHealth
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHWalkingTestResults.h"

static NSString*  const kFitnessTestTaskId                      = @"APHFitnessTest-00000000-1111-1111-1111-F810BE28D995";
static NSString*  const kAPCTaskAttributeUpdatedAt              = @"updatedAt";
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
    APHTableViewDashboardWalkingTestItem *item = [APHTableViewDashboardWalkingTestItem new];
    
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
        
        resultSummary = [taskResult resultSummary];
        
        if (resultSummary) {
            NSData *resultData = [resultSummary dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            result = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                APCLogError2(error);
            }
        }
        
        
        if ([result objectForKey:kFitTestTotalDistDataSourceKey]) {
            item.distanceWalked = [[result objectForKey:kFitTestTotalDistDataSourceKey] integerValue] * kMetersToYardConversion;
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
