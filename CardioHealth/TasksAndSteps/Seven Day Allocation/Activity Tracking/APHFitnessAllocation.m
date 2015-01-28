//
//  APHFitnessAllocation.m
//  MyHeartCounts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import "APHFitnessAllocation.h"
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
NSString *const APHSevenDayAllocationSleepDataIsReadyNotification = @"APHSevenDayAllocationSleepDataIsReadyNotification";
NSString *const APHSevenDayAllocationHealthKitDataIsReadyNotification = @"APHSevenDayAllocationHealthKitIsReadyNotification";

NSString *const kDatasetDateKeyFormat   = @"YYYY-MM-dd-hh";

typedef NS_ENUM(NSUInteger, SevenDayFitnessDatasetKinds)
{
    SevenDayFitnessDatasetKindToday = 0,
    SevenDayFitnessDatasetKindWeek,
    SevenDayFitnessDataSetKindYesterday
};

typedef NS_ENUM(NSUInteger, SevenDayFitnessQueryType)
{
    SevenDayFitnessQueryTypeWake = 0,
    SevenDayFitnessQueryTypeSleep,
    SevenDayFitnessQueryTypeTotal
};

@interface APHFitnessAllocation()

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;

@property (nonatomic, strong) NSMutableArray *datasetForToday;
@property (nonatomic, strong) __block NSMutableArray *datasetForTheWeek;
@property (nonatomic, strong) NSMutableArray *datasetForYesterday;

@property (nonatomic, strong) NSMutableArray *datasetNormalized;

@property (nonatomic, strong) NSMutableArray *motionDatasetForToday;
@property (nonatomic, strong) __block NSMutableArray *motionDatasetForTheWeek;

@property (nonatomic, strong) __block NSMutableArray *sleepDataset;
@property (nonatomic, strong) __block NSMutableArray *wakeDataset;

@property (nonatomic, strong) NSDate *allocationStartDate;

@property (nonatomic, strong) NSString *segmentInactive;
@property (nonatomic, strong) NSString *segmentSedentary;
@property (nonatomic, strong) NSString *segmentModerate;
@property (nonatomic, strong) NSString *segmentVigorous;
@property (nonatomic, strong) NSString *segmentSleep;

@property (nonatomic, strong) __block NSMutableArray *motionData;

@property (nonatomic,strong) NSDate *userDayStart;
@property (nonatomic,strong) NSDate *userDayEnd;

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
            
            
            //Set the users start and end of day
            [self setMostRecentSleepRangeStartDateAndEndDate];
            
            _datasetForToday = [NSMutableArray array];
            _datasetForTheWeek = [NSMutableArray array];
            _datasetForYesterday = [NSMutableArray array];
            
            _motionDatasetForToday = [NSMutableArray array];
            _motionDatasetForTheWeek = [NSMutableArray array];
            
            _sleepDataset = [NSMutableArray array];
            _wakeDataset = [NSMutableArray array];
            
            _motionData = [NSMutableArray new];
            _datasetNormalized = [NSMutableArray new];
            
            _segmentSleep = NSLocalizedString(@"Sleep", @"Sleep");
            _segmentInactive = NSLocalizedString(@"Light", @"Light");
            _segmentSedentary = NSLocalizedString(@"Sedentary", @"Sedentary");
            _segmentModerate = NSLocalizedString(@"Moderate", @"Moderate");
            _segmentVigorous = NSLocalizedString(@"Vigorous", @"Vigorous");
            
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(motionDataGatheringComplete)
                                                 name:APHSevenDayAllocationSleepDataIsReadyNotification
                                               object:nil];
    
    return self;
}

- (void) startDataCollection {
    
    [self setMostRecentSleepRangeStartDateAndEndDate];
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                         minute:0
                                                         second:0
                                                         ofDate:self.allocationStartDate
                                                        options:0];
    
    NSDateComponents *numberOfDaysFromStartDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                                  fromDate:startDate
                                                                                    toDate:[NSDate date]
                                                                                   options:NSCalendarWrapComponents];
    
    
    
    // if today number of days will be zero.
    

    // numberOfDaysFromStartDate provides the difference of days from now to start
    // of task and therefore if there is no difference we are only getting data for one day.
    numberOfDaysFromStartDate.day += 1;

    [self getRangeOfDataPointsFrom:self.userDayStart
                        andEndDate:self.userDayEnd
                   andNumberOfDays:numberOfDaysFromStartDate.day
                     withQueryType:SevenDayFitnessQueryTypeWake];
}

- (HKHealthStore *) healthStore {
    APCAppDelegate *delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    
    return delegate.dataSubstrate.healthStore;
}

#pragma mark - Public Interface

- (NSArray *)todaysAllocation
{
    NSArray *allocationForToday = nil;
    NSDictionary *todaysData = [self.datasetNormalized lastObject];
    
    allocationForToday = [self buildSegmentArrayForData:todaysData];
    
    return allocationForToday;
}

- (NSArray *)yesterdaysAllocation
{
    NSArray *allcationForYesterday = nil;
    if ([self.datasetNormalized count] > 1) {
        NSUInteger yesterdayIndex = [self.datasetNormalized indexOfObject:[self.datasetNormalized lastObject]] - 1;
        NSDictionary *yesterdaysData = [self.datasetNormalized objectAtIndex:yesterdayIndex];
        
        allcationForYesterday = [self buildSegmentArrayForData:yesterdaysData];
    }
    
    return allcationForYesterday;
}

- (NSArray *)weeksAllocation
{
    NSArray *allocationForTheWeek = nil;
    
    NSUInteger weekInactiveCounter = 0;
    NSUInteger weekSedentaryCounter = 0;
    NSUInteger weekModerateCounter = 0;
    NSUInteger weekVigorousCounter = 0;
    NSUInteger weekSleepCounter = 0;
    
    for (NSDictionary *day in self.datasetNormalized) {
        
        weekInactiveCounter += [day[self.segmentInactive] integerValue];
        weekSedentaryCounter += [day[self.segmentSedentary] integerValue];
        weekModerateCounter += [day[self.segmentModerate] integerValue];
        weekVigorousCounter += [day[self.segmentVigorous] integerValue];
        weekSleepCounter += [day[self.segmentSleep] integerValue];
    }
    
    NSDictionary *weekData = @{
                               self.segmentInactive: @(weekInactiveCounter),
                               self.segmentSedentary: @(weekSedentaryCounter),
                               self.segmentModerate: @(weekModerateCounter),
                               self.segmentVigorous: @(weekVigorousCounter),
                               self.segmentSleep: @(weekSleepCounter)
                              };
    
    allocationForTheWeek = [self buildSegmentArrayForData:weekData];
    
    return allocationForTheWeek;
}

- (NSNumber *)totalDistanceForDays:(NSInteger)days
{
    NSNumber *totalDistance = nil;
    
    if (days == 0) {
        totalDistance = [self.datasetForTheWeek lastObject];
    } else if (days == -7) {
        totalDistance = [self.datasetForTheWeek valueForKeyPath:@"@sum.datasetValueKey"];
    } else {
        totalDistance = [self.datasetForYesterday valueForKeyPath:@"@sum.datasetValueKey"];
    }
    
    return totalDistance;
}

#pragma mark - Helpers

- (NSArray *)buildSegmentArrayForData:(NSDictionary *)data
{
    NSMutableArray *allocationData = [NSMutableArray new];
    NSArray *segments = @[self.segmentSleep, self.segmentInactive, self.segmentSedentary, self.segmentModerate, self.segmentVigorous];
    UIColor *segmentColor = nil;
    
    for (NSString *segmentId in segments) {
        if ([segmentId isEqualToString:self.segmentSleep]) {
            segmentColor =[APHTheme colorForActivitySleep];
        } else if ([segmentId isEqualToString:self.segmentInactive]) {
            segmentColor = [APHTheme colorForActivityInactive];
        } else if ([segmentId isEqualToString:self.segmentSedentary]) {
            segmentColor = [APHTheme colorForActivitySedentary];
        } else if ([segmentId isEqualToString:self.segmentModerate]) {
            segmentColor = [APHTheme colorForActivityModerate];
        } else {
            segmentColor = [APHTheme colorForActivityVigorous];
        }
        
        [allocationData addObject:@{
                                    kSegmentSumKey: (data[segmentId]) ?: @(0),
                                    kDatasetSegmentKey: segmentId,
                                    kDatasetSegmentColorKey: segmentColor
                                    }];
    }
    
    return allocationData;
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
    NSArray *segments = @[self.segmentSleep , self.segmentInactive, self.segmentSedentary, self.segmentModerate, self.segmentVigorous];
    
    for (NSString *segmentId in segments) {
        NSMutableDictionary *entry = [NSMutableDictionary new];
        [entry setObject:segmentId forKey:kDatasetSegmentKey];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", kDatasetSegmentKey, segmentId];
        NSArray *groupSegments = [motionDataset filteredArrayUsingPredicate:predicate];
        double segmentSum = 0;
        
        for (int i = 0; i < groupSegments.count; i++) {
            if (![segmentId isEqualToString:self.segmentSleep]) {
                segmentSum += 1;
            } else {
                segmentSum += [[[groupSegments objectAtIndex:i] objectForKey:kSegmentSumKey] integerValue];
            }
        }
        
        entry[kSegmentSumKey] = @(segmentSum);
        
        UIColor *segmentColor = nil;
        
        if ([segmentId isEqualToString:self.segmentSleep]) {
            segmentColor =[APHTheme colorForActivitySleep];
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

- (void)normalizeMotionData:(NSArray *)dataset
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
            NSDictionary *segment = @{kDatasetSegmentKey: activityType, kDatasetDateHourKey: dateHour};
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) AND (%K = %@)",
                                      kDatasetSegmentKey,
                                      activityType,
                                      kDatasetDateHourKey,
                                      dateHour];
            
            
            filteredSegments = [self.motionDatasetForTheWeek filteredArrayUsingPredicate:predicate];
            [self.motionDatasetForTheWeek addObject:segment];
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

- (void)setMostRecentSleepRangeStartDateAndEndDate {
    
    APCAppDelegate*         delegate        =   (APCAppDelegate *)[UIApplication sharedApplication].delegate;
            NSDate*         userSleepTime   =                   delegate.dataSubstrate.currentUser.sleepTime;
            NSDate*         userWakeTime    =                  delegate.dataSubstrate.currentUser.wakeUpTime;
    

    #warning To avoid the bug with sleep/wake time, we will default to the 7 AM wake time and 9:30 PM sleep time.
    if (!userSleepTime)
    {
        userSleepTime                       = [[NSCalendar currentCalendar] dateBySettingHour:21
                                                                                       minute:30
                                                                                       second:0
                                                                                       ofDate:[NSDate date]
                                                                                      options:0];
    }
    
    if (!userWakeTime)
    {
        userWakeTime                        = [[NSCalendar currentCalendar] dateBySettingHour:7
                                                                                       minute:0
                                                                                       second:0
                                                                                       ofDate:[NSDate date]
                                                                                      options:0];
    }
    
            NSCalendar*         cal         =   [[NSCalendar alloc] initWithCalendarIdentifier:[NSCalendar currentCalendar].calendarIdentifier];
        NSCalendarUnit          units       =   (NSCalendarUnitHour | NSCalendarUnitMinute);
      NSDateComponents*         sleepTime   =   [cal components:units fromDate: userSleepTime];
      NSDateComponents*         wakeTime    =   [cal components:units  fromDate: userWakeTime];
                NSDate*         newEndDate  =   [cal dateBySettingHour:  sleepTime.hour
                                                                minute:  sleepTime.minute
                                                                second:  0
                                                                ofDate:  [NSDate date]
                                                               options:  0];
    
                NSDate*         newStartDate =  [cal dateBySettingHour: wakeTime.hour
                                                                minute: wakeTime.minute
                                                                second: 0
                                                                ofDate: [NSDate date]
                                                               options: 0];
    
    
    if (sleepTime.hour < wakeTime.hour) {
        
        NSDateComponents*    dateComponent  = [[NSDateComponents alloc] init];
                                                    [dateComponent setDay:1];
        
        newEndDate                          = [[NSCalendar currentCalendar] dateByAddingComponents:  dateComponent
                                                                                           toDate:  newEndDate
                                                                                          options:  0];
    }

    self.userDayStart                       = newStartDate;
    self.userDayEnd                         =   newEndDate;
}


- (void) getRangeOfDataPointsFrom:(NSDate *)startDate andEndDate:(NSDate *)endDate andNumberOfDays:(NSInteger)numberOfDays withQueryType:(SevenDayFitnessQueryType)queryType{
    
    self.motionActivityManager = [[CMMotionActivityManager alloc] init];
    
    NSInteger               numberOfDaysBack = numberOfDays * -1;
    NSDateComponents        *components = [[NSDateComponents alloc] init];
    [components setDay:numberOfDaysBack];
    
    NSDate                  *newStartDate = [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                                                          toDate:startDate
                                                                                         options:0];
    
    NSInteger               numberOfDaysBackForEndDate = numberOfDays * -1;
    
    NSDateComponents        *endDateComponent = [[NSDateComponents alloc] init];
    [endDateComponent setDay:numberOfDaysBackForEndDate];
    
    NSDate                  *newEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:endDateComponent
                                                                                         toDate:endDate
                                                                                        options:0];
    
    [self.motionActivityManager queryActivityStartingFromDate:newStartDate
                                                       toDate:newEndDate
                                                      toQueue:[NSOperationQueue new]
                                                  withHandler:^(NSArray *activities, NSError *error) {
                                                      

                                                      if (numberOfDays > 0) {
                                                          
                                                          if ( queryType == SevenDayFitnessQueryTypeSleep) {
                                                              NSInteger sleepForStationaryCounter = 0;
                                                          
                                                              for (CMMotionActivity *activity in activities) {
                                                                  BOOL noActivity = (
                                                                                     !activity.stationary &&
                                                                                     !activity.unknown &&
                                                                                     !activity.walking &&
                                                                                     !activity.running &&
                                                                                     !activity.cycling &&
                                                                                     !activity.automotive
                                                                                     );
                                                                  
                                                                  if (activity.stationary || noActivity) {
                                                                      sleepForStationaryCounter++;
                                                                  }
                                                              }
                                                              
                                                              [self.sleepDataset addObject:@{
                                                                                             self.segmentSleep: @(sleepForStationaryCounter)
                                                                                            }];
                                                          } else if ( queryType == SevenDayFitnessQueryTypeWake) {
                                                              
                                                              NSUInteger inactiveCounter    = 0;
                                                              NSUInteger sedentaryCounter   = 0;
                                                              NSUInteger moderateCounter    = 0;
                                                              NSUInteger vigorousCounter    = 0;
                                                              
                                                              for (CMMotionActivity *activity in activities) {
                                                                  if (activity.stationary) {
                                                                      inactiveCounter++;
                                                                  } else if (activity.walking) {
                                                                      if (activity.confidence == CMMotionActivityConfidenceLow) {
                                                                          sedentaryCounter++;
                                                                      } else {
                                                                          moderateCounter++;
                                                                      }
                                                                  } else if (activity.running) {
                                                                      if (activity.confidence == CMMotionActivityConfidenceLow) {
                                                                          moderateCounter++;
                                                                      } else {
                                                                          vigorousCounter++;
                                                                      }
                                                                  } else if (activity.cycling) {
                                                                      if (activity.confidence == CMMotionActivityConfidenceLow) {
                                                                          moderateCounter++;
                                                                      } else {
                                                                          vigorousCounter++;
                                                                      }
                                                                  }
                                                              }
                                                              
                                                              [self.wakeDataset addObject:@{
                                                                                            self.segmentInactive: @(inactiveCounter),
                                                                                            self.segmentSedentary: @(sedentaryCounter),
                                                                                            self.segmentModerate: @(moderateCounter),
                                                                                            self.segmentVigorous: @(vigorousCounter)
                                                                                           }];
                                                          }
            
                                                          
                                                        [self getRangeOfDataPointsFrom:startDate
                                                                            andEndDate:endDate
                                                                       andNumberOfDays:numberOfDays - 1
                                                                         withQueryType:queryType];
                                                      } else {
                                                          
                                                          
                                                          
                                                          if (queryType == SevenDayFitnessQueryTypeWake) {
                                                              
                                                              NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                                                                           minute:0
                                                                                                                           second:0
                                                                                                                           ofDate:self.allocationStartDate
                                                                                                                          options:0];
                                                              
                                                              //Different start date and end date
                                                              NSDateComponents *numberOfDaysFromStartDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                                                                                            fromDate:startDate
                                                                                                                                              toDate:[NSDate date]
                                                                                                                                             options:NSCalendarWrapComponents];
                                                              
                                                              //numberOfDaysFromStartDate provides the difference of days from now to start of task and therefore if there is no difference we are only getting data for one day.
                                                              numberOfDaysFromStartDate.day += 1;
                                                              
                                                              NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
                                                              [dateComponent setDay:-1];
                                                              NSDate *newStartDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponent
                                                                                                                                   toDate:self.userDayEnd
                                                                                                                                  options:0];
                                                              
                                                              [self getRangeOfDataPointsFrom:newStartDate andEndDate:self.userDayStart andNumberOfDays:numberOfDaysFromStartDate.day withQueryType:SevenDayFitnessQueryTypeSleep];

                                                          
                                                          }
                                                          
                                                          
                                                          if (queryType == SevenDayFitnessQueryTypeSleep) {
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:APHSevenDayAllocationSleepDataIsReadyNotification object:nil];
                                                              });
                                                          }
                                                      }
                                                  }];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APHSevenDayAllocationSleepDataIsReadyNotification object:nil];
}

- (void)motionDataGatheringComplete
{
    for (NSDictionary *day in self.sleepDataset) {
        NSUInteger dayIndex = [self.sleepDataset indexOfObject:day];
        
        NSMutableDictionary *wakeData = [[self.wakeDataset objectAtIndex:dayIndex] mutableCopy];
        
        [wakeData setObject:day[self.segmentSleep] forKey:self.segmentSleep];
        
        [self.wakeDataset replaceObjectAtIndex:dayIndex withObject:wakeData];
    }
    
    self.datasetNormalized = self.wakeDataset;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:APHSevenDayAllocationDataIsReadyNotification
                                                            object:nil];
    });
    

}

- (void)runStatsCollectionQueryfromStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate
{
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = kIntervalByHour;
    
    HKQuantityType *distanceType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate
                                                               endDate:endDate
                                                               options:HKQueryOptionStrictStartDate];
    
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:distanceType
                                                                           quantitySamplePredicate:predicate
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:startDate
                                                                                intervalComponents:interval];
    // set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            APCLogError(@"Error: %@", error.localizedDescription);
        } else {
            
            __block NSDictionary *dataPoint = nil;
            __block double totalValue;
            NSDate *beginDate = startDate;
            
            [results enumerateStatisticsFromDate:beginDate
                                          toDate:endDate
                                       withBlock:^(HKStatistics *result, BOOL *stop) {
                                           HKQuantity *quantity = result.sumQuantity;

                                           if (quantity) {
                                               NSDate *date = result.startDate;
                                               double value = [quantity doubleValueForUnit:[HKUnit meterUnit]];
                                               
                                               totalValue += value;
                                               
                                               dataPoint = @{
                                                               kDatasetDateHourKey: [dateFormatter stringFromDate:date],
                                                               kDatasetValueKey: [NSNumber numberWithDouble:totalValue]
                                                               };
                                           }
                                       }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:APHSevenDayAllocationHealthKitDataIsReadyNotification object:nil userInfo:dataPoint];
            });

        }
    };
    
    [self.healthStore executeQuery:query];
}

@end
