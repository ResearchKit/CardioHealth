//
//  APHFitnessAllocation.m
//  MyHeart Counts
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reporterDone:)
                                                 name:APCMotionHistoryReporterDoneNotification
                                               object:nil];

    
    return self;
}

- (void) startDataCollection {
    
    
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
    NSLog(@"numberOfDaysFromStartDate.day %ld",(long)numberOfDaysFromStartDate.day);
    
    APCMotionHistoryReporter *reporter = [APCMotionHistoryReporter sharedInstance];
    [reporter startMotionCoProcessorDataFrom:[NSDate dateWithTimeIntervalSinceNow:-24 * 60 * 60] andEndDate:[NSDate new] andNumberOfDays:numberOfDaysFromStartDate.day];


    //This call is replaced by   [reporter startMotionCoProcessorDataFrom:startDate andEndDate:[NSDate new] andNumberOfDays:numberOfDaysFromStartDate.day];
    /*
    [self getRangeOfDataPointsFrom:self.userDayStart
                        andEndDate:self.userDayEnd
                   andNumberOfDays:numberOfDaysFromStartDate.day
                     withQueryType:SevenDayFitnessQueryTypeWake];
     */
}

- (void)reporterDone:(NSNotification *)notification {
    
    APCMotionHistoryReporter *reporter = [APCMotionHistoryReporter sharedInstance];
    

    NSArray * theMotionData = reporter.retrieveMotionReport;
    //The count will be the number of days in the array, each element represents a day
    if(theMotionData.count > 0)
    {
        for (NSArray *dayArray in theMotionData)
        {
            // Now that you have a “day" you can get the APCMotionHistoryData out of them
            NSLog(@"**********************************");
            for(APCMotionHistoryData * theData in dayArray) {
                NSLog(@"activityType: %ld , timeInterval: %f",theData.activityType,theData.timeInterval);
                /*
                [self.wakeDataset addObject:@{
                                              self.segmentInactive: @(inactiveCounter),
                                              self.segmentSedentary: @(sedentaryCounter),
                                              self.segmentModerate: @(moderateCounter),
                                              self.segmentVigorous: @(vigorousCounter)
                                              }];
                 */
                
                /*
                [self.sleepDataset addObject:@{
                                               self.segmentSleep: @(sleepForStationaryCounter)
                                               }];
                 */
                
            }
        }
    }
    
   
    
    
    //Not sure if this is needed
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:APHSevenDayAllocationSleepDataIsReadyNotification object:nil];
    });
    
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:APHSevenDayAllocationDataIsReadyNotification
                                                            object:nil];
    });
     */
    
    /*
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
     */
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

//- (NSNumber *)totalDistanceForDays:(NSInteger)days
//{
//    NSNumber *totalDistance = nil;
//    
//    if (days == 0) {
//        totalDistance = [self.datasetForTheWeek lastObject];
//    } else if (days == -7) {
//        totalDistance = [self.datasetForTheWeek valueForKeyPath:@"@sum.datasetValueKey"];
//    } else {
//        totalDistance = [self.datasetForYesterday valueForKeyPath:@"@sum.datasetValueKey"];
//    }
//    
//    return totalDistance;
//}

#pragma mark - Helpers

- (NSArray *)buildSegmentArrayForData:(NSDictionary *)data
{
    NSMutableArray *allocationData = [NSMutableArray new];
    NSArray *segments = @[self.segmentSleep, self.segmentSedentary, self.segmentInactive, self.segmentModerate, self.segmentVigorous];
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


#pragma mark - Queries



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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APCMotionHistoryReporterDoneNotification object:nil];
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
