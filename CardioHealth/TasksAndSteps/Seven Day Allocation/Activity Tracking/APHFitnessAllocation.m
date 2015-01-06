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
    SevenDayFitnessDatasetKindWeek,
    SevenDayFitnessDatasetKindYesterday
};

@interface APHFitnessAllocation()

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;

@property (nonatomic, strong) NSMutableArray *datasetForToday;
@property (nonatomic, strong) NSMutableArray *datasetForTheWeek;
@property (nonatomic, strong) NSMutableArray *datasetForYesterday;

@property (nonatomic, strong) NSArray *datasetNormalized;

@property (nonatomic, strong) NSMutableArray *motionDatasetForToday;
@property (nonatomic, strong) NSMutableArray *motionDatasetForTheWeek;
@property (nonatomic, strong) NSMutableArray *motionDatasetForYesterday;

@property (nonatomic, strong) NSDate *allocationStartDate;

@property (nonatomic, strong) NSString *segmentInactive;
@property (nonatomic, strong) NSString *segmentSedentary;
@property (nonatomic, strong) NSString *segmentModerate;
@property (nonatomic, strong) NSString *segmentVigorous;
@property (nonatomic, strong) NSString *segmentSleep;

@property (nonatomic, strong) NSDate *userWakeTime;
@property (nonatomic, strong) NSDate *userSleepTime;

@property (nonatomic, strong) NSDate *periodStartDate;
@property (nonatomic, strong) NSDate *periodEndDate;

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
            _datasetForYesterday = [NSMutableArray array];
            
            _motionDatasetForToday = [NSMutableArray array];
            _motionDatasetForTheWeek = [NSMutableArray array];
            _motionDatasetForYesterday = [NSMutableArray array];
            
            _datasetNormalized = nil;
            
            _segmentInactive = NSLocalizedString(@"Inactive", @"Inactive");
            _segmentSedentary = NSLocalizedString(@"Sedentary", @"Sedentary");
            _segmentModerate = NSLocalizedString(@"Moderate", @"Moderate");
            _segmentVigorous = NSLocalizedString(@"Vigorous", @"Vigorous");
            _segmentSleep = NSLocalizedString(@"Sleep", @"Sleep");
            
            APCAppDelegate *apcDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!apcDelegate.dataSubstrate.currentUser.sleepTime) {
                _userSleepTime = [[NSCalendar currentCalendar] dateBySettingHour:7
                                                                          minute:0
                                                                          second:0
                                                                          ofDate:[NSDate date]
                                                                         options:0];
            } else  {
                _userSleepTime = apcDelegate.dataSubstrate.currentUser.sleepTime;
            }
            
            if (!apcDelegate.dataSubstrate.currentUser.wakeUpTime) {
                _userWakeTime = [[NSCalendar currentCalendar] dateBySettingHour:21
                                                                         minute:30
                                                                         second:0
                                                                         ofDate:[NSDate date]
                                                                        options:0];
            } else {
                _userWakeTime = apcDelegate.dataSubstrate.currentUser.wakeUpTime;
            }
            
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
                                                            
                                                            NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
                                                            NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:units
                                                                                                                                fromDate:[NSDate date]];
                                                            NSDateComponents *fitnessStartDate = [[NSCalendar currentCalendar] components:units
                                                                                                                                 fromDate:_allocationStartDate];
                                                            NSDate *today = [[NSCalendar currentCalendar] dateFromComponents:todayComponents];
                                                            NSDate *fitnessDate = [[NSCalendar currentCalendar] dateFromComponents:fitnessStartDate];
                                                            
                                                            if ([today compare:fitnessDate] == NSOrderedDescending) {
                                                                [self runStatsCollectionQueryForKind:SevenDayFitnessDatasetKindYesterday];
                                                                [self retrieveDataFromCoreMotionForDays:SevenDayFitnessDatasetKindYesterday];
                                                            }
                                                            
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
    } else if (days == SevenDayFitnessDatasetKindWeek) {
        [self groupDataFromMotion:self.motionDatasetForTheWeek andHealthKit:self.datasetForTheWeek];
    } else {
        [self groupDataFromMotion:self.motionDatasetForYesterday andHealthKit:self.datasetForYesterday];
    }
    
    if ([self.delegate respondsToSelector:@selector(datasetDidUpdate:forKind:)]) {
        [self.delegate datasetDidUpdate:self.datasetNormalized forKind:days];
    }
}

- (NSNumber *)totalDistanceForDays:(NSInteger)days
{
    NSNumber *totalDistance = nil;
    
    if (days == SevenDayFitnessDatasetKindToday) {
        totalDistance = [self.datasetForToday valueForKeyPath:@"@sum.datasetValueKey"];
    } else if (days == SevenDayFitnessDatasetKindWeek) {
        totalDistance = [self.datasetForTheWeek valueForKeyPath:@"@sum.datasetValueKey"];
    } else {
        totalDistance = [self.datasetForYesterday valueForKeyPath:@"@sum.datasetValueKey"];
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
    NSArray *segments = @[self.segmentSleep, self.segmentInactive, self.segmentSedentary, self.segmentModerate, self.segmentVigorous];
    
    for (NSString *segmentId in segments) {
        NSMutableDictionary *entry = [NSMutableDictionary new];
        [entry setObject:segmentId forKey:kDatasetSegmentKey];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", kDatasetSegmentKey, segmentId];
        NSArray *groupSegments = [motionDataset filteredArrayUsingPredicate:predicate];
        double segmentSum = 0;
        
        for (int i = 0; i < groupSegments.count; i++) {
            NSString *dateHour = [[groupSegments objectAtIndex:i] objectForKey:kDatasetDateHourKey];
            
            if ([segmentId isEqualToString:self.segmentSleep]) {
                segmentSum += 1;
            } else {
                NSNumber *value = [self retrieveDataFromDataset:healthkitDataset forDateHour:dateHour];
                segmentSum += [value doubleValue];
            }
            
            //[entry setObject:value forKey:dateHour];
        }
        
        entry[kSegmentSumKey] = @(segmentSum);
        
        UIColor *segmentColor = nil;
        
        if ([segmentId isEqualToString:self.segmentSleep]) {
            segmentColor = [APHTheme colorForActivitySleep];
        } else if ([segmentId isEqualToString:self.segmentInactive]) {
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
        
        // When the time is between the user sleep time and wake time, we will
        // treat it as part of the sleep.
        NSCalendarUnit units = NSCalendarUnitHour | NSCalendarUnitMinute;
        NSDateComponents *sleepComponents = [[NSCalendar currentCalendar] components:units
                                                                            fromDate:self.userSleepTime];
        NSDateComponents *wakeComponents = [[NSCalendar currentCalendar] components:units
                                                                           fromDate:self.userWakeTime];
        
        NSDate *sleepStartTime = [[NSCalendar currentCalendar] dateBySettingHour:sleepComponents.hour
                                                                          minute:sleepComponents.minute
                                                                          second:0
                                                                          ofDate:activity.startDate
                                                                         options:0];
        NSDate *sleepEndTime = [[NSCalendar currentCalendar] dateBySettingHour:wakeComponents.hour
                                                                        minute:wakeComponents.minute
                                                                        second:0
                                                                        ofDate:activity.startDate
                                                                       options:0];
        
        // If the wake date hour is less than the sleep date hour we can infer that the user's
        // sleep time overlaps two days.
        if (wakeComponents.hour == 24 || sleepComponents.hour > wakeComponents.hour) {
            
            NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
            [dateComponent setDay:-1];
            sleepStartTime = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponent
                                                                     toDate:sleepStartTime
                                                                    options:0];
        }
        
        
        if (activity.stationary) {
            if (([sleepStartTime compare:activity.startDate] == NSOrderedAscending || [sleepStartTime compare:activity.startDate] == NSOrderedSame) &&
                ([sleepEndTime compare:activity.startDate] == NSOrderedDescending || [sleepEndTime compare:activity.startDate] == NSOrderedSame)) {
                NSLog(@"Sleep Activity: %@", activity);
                activityType = self.segmentSleep;
            } else {
                activityType = self.segmentInactive;
            }
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
            } else if (kind == SevenDayFitnessDatasetKindWeek){
                filteredSegments = [self.motionDatasetForTheWeek filteredArrayUsingPredicate:predicate];
                
                if ([filteredSegments count] == 0) {
                    [self.motionDatasetForTheWeek addObject:segment];
                }
            } else {
                filteredSegments = [self.motionDatasetForYesterday filteredArrayUsingPredicate:predicate];
                
                if ([filteredSegments count] == 0) {
                    [self.motionDatasetForYesterday addObject:segment];
                }
            }
        }
    }
}

- (void)normalizeDatePeriod:(NSInteger)period
{
    NSCalendarUnit units = NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *sleepComponents = [[NSCalendar currentCalendar] components:units fromDate:self.userSleepTime];
    NSDateComponents *wakeComponents = [[NSCalendar currentCalendar] components:units fromDate:self.userWakeTime];
    NSDate *dayStart = nil;
    NSDate *dayEnd = nil;
    
    dayStart = [[NSCalendar currentCalendar] dateBySettingHour:wakeComponents.hour
                                                        minute:wakeComponents.minute
                                                        second:0
                                                        ofDate:[NSDate date]
                                                       options:0];
    dayEnd = [[NSCalendar currentCalendar] dateBySettingHour:wakeComponents.hour - 1
                                                      minute:59
                                                      second:59
                                                      ofDate:[NSDate date]
                                                     options:0];
    
    // If the wake date hour is less than the sleep date hour we can infer that the user's
    // wake time overlaps two days.
    if (wakeComponents.hour == 24 || sleepComponents.hour > wakeComponents.hour) {
        
        NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
        [dateComponent setDay:-1];
        dayStart = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponent
                                                                 toDate:dayStart
                                                                options:0];
    }
    
    dayStart = [self anchorDateByDays:period toDate:dayStart];
    
    self.periodStartDate = dayStart;
    self.periodEndDate = dayEnd;
}

- (NSDate *)anchorDateByDays:(NSInteger)days toDate:(NSDate *)toDate
{
    NSDateComponents *components =  [[NSDateComponents alloc] init];
    [components setDay:days];
    
    NSDate *anchorDate = [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                                       toDate:toDate
                                                                      options:0];
    
    if (anchorDate < self.allocationStartDate) {
        // The allocation start date is the lower boundary.
        // When a date is before the allocation start date,
        // we will return the allocation start date.
        anchorDate = self.allocationStartDate;
    }
    
    return anchorDate;
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

        [self normalizeDatePeriod:kind];

        [self.motionActivityManager queryActivityStartingFromDate:self.periodStartDate
                                                           toDate:self.periodEndDate
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
                                               } else if (kind == SevenDayFitnessDatasetKindWeek){
                                                   [self.datasetForTheWeek addObject:dataPoint];
                                               } else {
                                                   [self.datasetForYesterday addObject:dataPoint];
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
