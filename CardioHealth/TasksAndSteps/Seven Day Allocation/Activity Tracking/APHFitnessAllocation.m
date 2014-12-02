//
//  APHFitnessAllocation.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 12/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessAllocation.h"
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>
#import "APHTheme.h"

static NSInteger kIntervalByHour = 1;

NSString *const kDatasetDateKey         = @"datasetDateKey";
NSString *const kDatasetValueKey        = @"datasetValueKey";
NSString *const kDatasetSegmentNameKey  = @"datasetSegmentNameKey";
NSString *const kDatasetSegmentColorKey = @"datasetSegmentColorKey";

typedef NS_ENUM(NSUInteger, SevenDayFitnessDatasetKinds)
{
    SevenDayFitnessDatasetKindToday = 0,
    SevenDayFitnessDatasetKindWeek
};

@interface APHFitnessAllocation()

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;

@property (nonatomic, strong) NSMutableArray *datasetForToday;
@property (nonatomic, strong) NSMutableArray *datasetForTheWeek;
@property (nonatomic, strong) NSMutableArray *datasetNormalized;
@property (nonatomic, strong) NSDate *allocationStartDate;

@end

@implementation APHFitnessAllocation

- (instancetype)initWithAllocationStartDate:(NSDate *)startDate
{
    self = [super init];
    
    if (self) {
        if (startDate) {
            self.allocationStartDate = startDate;
            self.datasetForToday = [NSMutableArray array];
            self.datasetForTheWeek = [NSMutableArray array];
            
            if ([HKHealthStore isHealthDataAvailable]) {
                self.healthStore = [[HKHealthStore alloc] init];
                
                NSSet *readDataTypes = [self healthKitDataTypesToRead];
                
                [self.healthStore requestAuthorizationToShareTypes:nil
                                                         readTypes:readDataTypes
                                                        completion:^(BOOL success, NSError *error) {
                                                            if (!success) {
                                                                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                                                                
                                                                return;
                                                            }
                                                            
                                                            [self runStatsCollectionQueryForKind:SevenDayFitnessDatasetKindToday];
                                                            [self runStatsCollectionQueryForKind:SevenDayFitnessDatasetKindWeek];
                                                        }];
            }
        }
    }
    
    return self;
}

- (void)allocationForDays:(NSInteger)days
{
    if (days == SevenDayFitnessDatasetKindToday) {
        [self normalizeData:self.datasetForToday];
    } else {
        [self normalizeData:self.datasetForTheWeek];
    }
    
    if ([self.delegate respondsToSelector:@selector(datasetDidUpdate:forKind:)]) {
        [self.delegate datasetDidUpdate:self.datasetNormalized forKind:days];
    }
}

- (void)reloadAllocationDatasets
{
    [self runStatsCollectionQueryForKind:SevenDayFitnessDatasetKindToday];
    [self runStatsCollectionQueryForKind:SevenDayFitnessDatasetKindWeek];
}

#pragma mark - Allocation Algorithm
/**
 * @brief Since there is no corrolation between the data that is provided by Core Motion
 *        and the data that is pulled from HealthKit, we have to hypothesize that the
 *        time that is associated with data points from both sources are the same points.
 *        Given that, we will use the data from Core Motion as the container using the Activity type
 *        and Confidence that are provided by Core Motion to relate data from HealthKit.
 *
 *        Therefore if the data point from Core Motion has medium to high confidence and the
 *        timestamp is within the same hour as the HealthKit data, the data from HealthKit
 *        will be organized according to the Activity type that is provided by Core Motion.
 */

- (void)normalizeData:(NSArray *)dataset
{
    NSRange inactiveRange = NSMakeRange(0, 402);
    NSRange sedentaryRange = NSMakeRange(0, 804);
    NSRange moderateRange = NSMakeRange(0, 1207); // a number beyond this is considered vigorous
    
    self.datasetNormalized = [NSMutableArray arrayWithArray:@[
                                                            @{kDatasetSegmentNameKey: NSLocalizedString(@"Inactive", @"Inactive"),
                                                              kDatasetValueKey: @0,
                                                              kDatasetSegmentColorKey: [APHTheme colorForActivityInactive]},
                                                            @{kDatasetSegmentNameKey: NSLocalizedString(@"Sedentary", @"Sedentary"),
                                                              kDatasetValueKey: @0,
                                                              kDatasetSegmentColorKey: [APHTheme colorForActivitySedentary]},
                                                            @{kDatasetSegmentNameKey: NSLocalizedString(@"Moderate", @"Moderate"),
                                                              kDatasetValueKey: @0,
                                                              kDatasetSegmentColorKey: [APHTheme colorForActivityModerate]},
                                                            @{kDatasetSegmentNameKey: NSLocalizedString(@"Vigorous", @"Vigorous"),
                                                              kDatasetValueKey: @0,
                                                              kDatasetSegmentColorKey: [APHTheme colorForActivityVigorous]}
                                                            ]];
    
    for (NSDictionary *data in dataset) {
        NSUInteger segment = 0;
        NSUInteger value = [data[kDatasetValueKey] integerValue];
        
        if (NSLocationInRange(value, inactiveRange)) {
            segment = 0;
        } else if (NSLocationInRange(value, sedentaryRange)) {
            segment = 1;
        } else if (NSLocationInRange(value, moderateRange)) {
            segment = 2;
        } else {
            segment = 3;
        }
        
        NSMutableDictionary *normalSegment = [[self.datasetNormalized objectAtIndex:segment] mutableCopy];
        NSNumber *currentValue = normalSegment[kDatasetValueKey];
        
        normalSegment[kDatasetValueKey] = [NSNumber numberWithInteger:[currentValue integerValue] + value];
        
        [self.datasetNormalized replaceObjectAtIndex:segment withObject:normalSegment];
    }
}

#pragma mark - Queries

- (void)retrieveDataFromCoreMotionForDays:(SevenDayFitnessDatasetKinds)kind
{
    if ([CMMotionActivityManager isActivityAvailable ]) {
        self.motionActivityManager = [[CMMotionActivityManager alloc] init];

        NSDate *startDate = nil;
        NSDate *endDate = nil;
        
        if (kind == SevenDayFitnessDatasetKindToday) {
            startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                 minute:0
                                                                 second:0
                                                                 ofDate:[NSDate date]
                                                                options:0];
            endDate = [[NSCalendar currentCalendar] dateBySettingHour:23
                                                               minute:59
                                                               second:59
                                                               ofDate:[NSDate date]
                                                              options:0];
        } else {
            startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                 minute:0
                                                                 second:0
                                                                 ofDate:self.allocationStartDate
                                                                options:0];
            endDate = [[NSCalendar currentCalendar] dateBySettingHour:23
                                                               minute:59
                                                               second:59
                                                               ofDate:[NSDate date]
                                                              options:0];
        }

        [self.motionActivityManager queryActivityStartingFromDate:startDate
                                                           toDate:endDate
                                                          toQueue:[NSOperationQueue new]
                                                      withHandler:^(NSArray *activities, NSError *error) {
                                                          for (CMMotionActivity *activity in activities) {
                                                              NSString *kind = nil;
                                                              NSString *confidence = nil;

                                                              if (activity.stationary) {
                                                                  kind = @"Stationary";
                                                              } else if (activity.walking) {
                                                                  kind = @"Walking";
                                                              } else if (activity.running) {
                                                                  kind = @"Running";
                                                              } else if (activity.cycling) {
                                                                  kind = @"Cycling";
                                                              }

                                                              if (activity.confidence == CMMotionActivityConfidenceLow) {
                                                                  confidence = @"Low";
                                                              } else if (activity.confidence == CMMotionActivityConfidenceMedium) {
                                                                  confidence = @"Medium";
                                                              } else if (activity.confidence == CMMotionActivityConfidenceHigh) {
                                                                  confidence = @"High";
                                                              }

                                                              NSLog(@"%@ (%@) -- %@", activity, kind, confidence);
                                                          }
                                                      }];
    } else {
        NSLog(@"Core Motion is not available for this device.");
    }
}

- (void)runStatsCollectionQueryForKind:(SevenDayFitnessDatasetKinds)kind
{
    NSDate *startDate = nil;
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    
    if (kind == SevenDayFitnessDatasetKindToday) {
        startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                             minute:0
                                                             second:0
                                                             ofDate:[NSDate date]
                                                            options:0];
        NSLog(@"Today Start/End: %@/%@", startDate, [NSDate date]);
    } else {
        startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                             minute:0
                                                             second:0
                                                             ofDate:self.allocationStartDate
                                                            options:0];
//        interval.day = kIntervalByDay;
        NSLog(@"Week Start/End: %@/%@", startDate, [NSDate date]);
    }
    
    interval.hour = kIntervalByHour;
    
    HKQuantityType *distanceType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:[NSDate date] options:HKQueryOptionStrictStartDate];
    
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:distanceType
                                                                           quantitySamplePredicate:predicate
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:startDate
                                                                                intervalComponents:interval];
    // set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSDate *endDate = [[NSCalendar currentCalendar] dateBySettingHour:23
                                                                       minute:59
                                                                       second:59
                                                                       ofDate:[NSDate date]
                                                                      options:0];
            NSDate *beginDate = startDate;
            
            [results enumerateStatisticsFromDate:beginDate
                                          toDate:endDate
                                       withBlock:^(HKStatistics *result, BOOL *stop) {
                                           HKQuantity *quantity = result.sumQuantity;
                                           
                                           if (quantity) {
                                               NSDate *date = result.startDate;
                                               double value = [quantity doubleValueForUnit:[HKUnit meterUnit]];
                                               
                                               if (kind == SevenDayFitnessDatasetKindToday) {
                                                   [self.datasetForToday addObject:@{
                                                                                     kDatasetDateKey: date,
                                                                                     kDatasetValueKey: [NSNumber numberWithDouble:value]
                                                                                     }];
                                               } else {
                                                   [self.datasetForTheWeek addObject:@{
                                                                                       kDatasetDateKey: date,
                                                                                       kDatasetValueKey: [NSNumber numberWithDouble:value]
                                                                                       }];
                                               }
                                               
                                               NSLog(@"%@: %f", date, value);
                                           }
                                       }];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self allocationForDays:kind];
//            });
        }
    };
    
    [self.healthStore executeQuery:query];
}

#pragma mark - Helpers

- (NSSet *)healthKitDataTypesToRead {
    HKQuantityType *steps = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distance = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    return [NSSet setWithObjects:steps, distance, nil];
}

@end
