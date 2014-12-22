//
//  APHFitnessAllocation.m
//  MyHeartCounts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import "APHFitnessAllocation.h"
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>
#import "APHTheme.h"

static NSInteger kIntervalByHour = 1;
static NSDateFormatter *dateFormatter = nil;

NSString *const kDatasetDateKey         = @"datasetDateKey";
NSString *const kDatasetValueKey        = @"datasetValueKey";
NSString *const kDatasetSegmentNameKey  = @"datasetSegmentNameKey";
NSString *const kDatasetSegmentColorKey = @"datasetSegmentColorKey";

NSString *const kDatasetSegmentKey      = @"segmentKey";
NSString *const kDatasetDateHourKey     = @"dateHourKey";
NSString *const kSegmentSumKey          = @"segmentSumKey";

NSString *const kSevenDayFitnessStartDateKey  = @"sevenDayFitnessStartDateKey";

NSString *const APHSevenDayAllocationDataIsReadyNotification = @"APHSevenDayAllocationDataIsReadyNotification";

NSString *const kDatasetDateKeyFormat   = @"YYYY-MM-dd-hh";

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

@property (nonatomic, strong) NSArray *datasetNormalized;

@property (nonatomic, strong) NSMutableArray *motionDatasetForToday;
@property (nonatomic, strong) NSMutableArray *motionDatasetForTheWeek;

@property (nonatomic, strong) NSDate *allocationStartDate;

@property (nonatomic, strong) NSString *segmentInactive;
@property (nonatomic, strong) NSString *segmentSedentary;
@property (nonatomic, strong) NSString *segmentModerate;
@property (nonatomic, strong) NSString *segmentVigorous;

@end

@implementation APHFitnessAllocation

- (instancetype)initWithAllocationStartDate:(NSDate *)startDate
{
    self = [super init];
    
    if (self) {
        if (startDate) {
            if (startDate) {
                _allocationStartDate = startDate;
            } else {
                _allocationStartDate = [NSDate date];
            }
            
            if (!dateFormatter) {
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                [dateFormatter setDateFormat:kDatasetDateKeyFormat];
            }
            
            _datasetForToday = [NSMutableArray array];
            _datasetForTheWeek = [NSMutableArray array];
            
            _motionDatasetForToday = [NSMutableArray array];
            _motionDatasetForTheWeek = [NSMutableArray array];
            
            _datasetNormalized = nil;
            
            _segmentInactive = NSLocalizedString(@"Inactive", @"Inactive");
            _segmentSedentary = NSLocalizedString(@"Sedentary", @"Sedentary");
            _segmentModerate = NSLocalizedString(@"Moderate", @"Moderate");
            _segmentVigorous = NSLocalizedString(@"Vigorous", @"Vigorous");
            
            if ([HKHealthStore isHealthDataAvailable]) {
                _healthStore = [[HKHealthStore alloc] init];
                
                NSSet *readDataTypes = [self healthKitDataTypesToRead];
                
                [_healthStore requestAuthorizationToShareTypes:nil
                                                         readTypes:readDataTypes
                                                        completion:^(BOOL success, NSError *error) {
                                                            if (!success) {
                                                                return;
                                                            }
                                                            
                                                            [self runStatsCollectionQueryForKind:SevenDayFitnessDatasetKindToday];
                                                            [self retrieveDataFromCoreMotionForDays:SevenDayFitnessDatasetKindToday];
                                                            [self runStatsCollectionQueryForKind:SevenDayFitnessDatasetKindWeek];
                                                            [self retrieveDataFromCoreMotionForDays:SevenDayFitnessDatasetKindWeek];
                                                        }];
            }
        }
    }
    
    return self;
}

- (void)allocationForDays:(NSInteger)days
{
    if (days == SevenDayFitnessDatasetKindToday) {
        [self groupDataFromMotion:self.motionDatasetForToday andHealthKit:self.datasetForToday];
    } else {
        [self groupDataFromMotion:self.motionDatasetForTheWeek andHealthKit:self.datasetForTheWeek];
    }
    
    if ([self.delegate respondsToSelector:@selector(datasetDidUpdate:forKind:)]) {
        [self.delegate datasetDidUpdate:self.datasetNormalized forKind:days];
    }
}

- (NSNumber *)totalDistanceForDays:(NSInteger)days
{
    NSNumber *totalDistance = nil;
    
    if (days == 0) {
        totalDistance = [self.datasetForToday valueForKeyPath:@"@sum.datasetValueKey"];
    } else {
        totalDistance = [self.datasetForTheWeek valueForKeyPath:@"@sum.datasetValueKey"];
    }
    
    return totalDistance;
}

- (void)reloadAllocationDatasets
{
    [self runStatsCollectionQueryForKind:SevenDayFitnessDatasetKindToday];
    [self runStatsCollectionQueryForKind:SevenDayFitnessDatasetKindWeek];
    
    [self retrieveDataFromCoreMotionForDays:SevenDayFitnessDatasetKindToday];
    [self retrieveDataFromCoreMotionForDays:SevenDayFitnessDatasetKindWeek];
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
- (void)groupDataFromMotion:(NSArray *)motionDataset andHealthKit:(NSArray *)healthkitDataset
{
    // At this point all datasets (from HealthKit and Core Motion) should be
    // available, since the queries to build these datasets gets fired at -initWithAllocationStartDate.
    
    NSMutableArray *normalDataset = [NSMutableArray array];
    NSArray *segments = @[self.segmentInactive, self.segmentSedentary, self.segmentModerate, self.segmentVigorous];
    
    for (NSString *segmentId in segments) {
        NSMutableDictionary *entry = [NSMutableDictionary new];
        [entry setObject:segmentId forKey:kDatasetSegmentKey];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", kDatasetSegmentKey, segmentId];
        NSArray *groupSegments = [motionDataset filteredArrayUsingPredicate:predicate];
        double segmentSum = 0;
        
        for (int i = 0; i < groupSegments.count; i++) {
            NSString *dateHour = [[groupSegments objectAtIndex:i] objectForKey:kDatasetDateHourKey];
            NSNumber *value = [self retrieveDataFromDataset:healthkitDataset forDateHour:dateHour];
            
            segmentSum += [value doubleValue];
            
            [entry setObject:value forKey:dateHour];
        }
        
        entry[kSegmentSumKey] = @(segmentSum);
        
        UIColor *segmentColor = nil;
        
        if ([segmentId isEqualToString:self.segmentInactive]) {
            segmentColor = [APHTheme colorForActivityInactive];
        } else if ([segmentId isEqualToString:self.segmentSedentary]) {
            segmentColor = [APHTheme colorForActivitySedentary];
        } else if ([segmentId isEqualToString:self.segmentModerate]) {
            segmentColor = [APHTheme colorForActivityModerate];
        } else {
            segmentColor = [APHTheme colorForActivityVigorous];
        }
        
        entry[kDatasetSegmentColorKey] = segmentColor;
        
        [normalDataset addObject:entry];
    }
    
    self.datasetNormalized = normalDataset;
}

- (void)normalizeMotionData:(NSArray *)dataset forKind:(SevenDayFitnessDatasetKinds)kind
{
    // The way we are corrolating the Core Motion data is as that each of the
    // activity type is mapped to our categories. That association is:
    //
    //   Core Motion       Confidence        Our Map
    //   ============================================
    //   Stationary        Any               Inactive
    //   Walking           Low               Sedentary
    //   Walking           Medium/High       Moderate
    //   Running           Low               Moderate
    //   Running           Medium/High       Vigorous
    //   Cycling           Medium/High       Vigorous
    //

    for (CMMotionActivity *activity in dataset) {
        BOOL isValidActivityType = YES;
        NSString *dateHour = [dateFormatter stringFromDate:activity.startDate];
        NSString *activityType = nil;
        
        if (activity.stationary) {
            activityType = self.segmentInactive;
        } else if (activity.walking) {
            if (activity.confidence == CMMotionActivityConfidenceLow) {
                activityType = self.segmentSedentary;
            } else {
                activityType = self.segmentModerate;
            }
        } else if (activity.running) {
            if (activity.confidence == CMMotionActivityConfidenceLow) {
                activityType = self.segmentModerate;
            } else {
                activityType = self.segmentVigorous;
            }
        } else if (activity.cycling) {
            if (activity.confidence == CMMotionActivityConfidenceLow) {
                activityType = self.segmentModerate;
            } else {
                activityType = self.segmentVigorous;
            }
        } else {
            isValidActivityType = NO;
        }
        
        if (isValidActivityType) {
            NSArray *filteredSegments = nil;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) AND (%K = %@)",
                                      kDatasetSegmentKey,
                                      activityType,
                                      kDatasetDateHourKey,
                                      dateHour];
            
            NSDictionary *segment = @{kDatasetSegmentKey: activityType, kDatasetDateHourKey: dateHour};
            
            if (kind == SevenDayFitnessDatasetKindToday) {
                filteredSegments = [self.motionDatasetForToday filteredArrayUsingPredicate:predicate];
                
                if ([filteredSegments count] == 0) {
                    [self.motionDatasetForToday addObject:segment];
                }
            } else {
                filteredSegments = [self.motionDatasetForTheWeek filteredArrayUsingPredicate:predicate];
                
                if ([filteredSegments count] == 0) {
                    [self.motionDatasetForTheWeek addObject:segment];
                }
            }
        }
    }
}

- (NSNumber *)retrieveDataFromDataset:(NSArray *)dataset forDateHour:(NSString *)dateHour
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", kDatasetDateHourKey, dateHour];
    NSArray *filteredDataset = nil;
    NSNumber *dataValue = @(0);
    
    filteredDataset = [dataset filteredArrayUsingPredicate:predicate];
    
    if ([filteredDataset count] > 0) {
        dataValue = [[filteredDataset firstObject] valueForKey:kDatasetValueKey];
    }
    
    return dataValue;
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
                                                          [self normalizeMotionData:activities forKind:kind];
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
                                               
                                               NSDictionary *dataPoint = @{
                                                                           kDatasetDateHourKey: [dateFormatter stringFromDate:date],
                                                                           kDatasetValueKey: [NSNumber numberWithDouble:value]
                                                                           };
                                               
                                               if (kind == SevenDayFitnessDatasetKindToday) {
                                                   [self.datasetForToday addObject:dataPoint];
                                               } else {
                                                   [self.datasetForTheWeek addObject:dataPoint];
                                               }
                                           }
                                       }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:APHSevenDayAllocationDataIsReadyNotification
                                                                    object:nil];
            });
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
