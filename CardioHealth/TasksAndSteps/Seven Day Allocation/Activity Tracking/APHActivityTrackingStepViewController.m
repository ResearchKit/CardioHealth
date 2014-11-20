//
//  APHActivityTrackingStepViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHActivityTrackingStepViewController.h"
#import "APHStackedCircleView.h"
#import "APHTheme.h"

static NSInteger kIntervalByHour = 1;
static NSInteger kIntervalByDay = 1;

static NSString *kSevenDayFitnessStartDateKey = @"sevenDayFitnessStartDateKey";

typedef NS_ENUM(NSUInteger, SevenDayFitnessDatasetKinds)
{
    SevenDayFitnessDatasetKindToday = 0,
    SevenDayFitnessDatasetKindWeek
};

@interface APHActivityTrackingStepViewController ()

@property (weak, nonatomic) IBOutlet UILabel *daysRemaining;
@property (weak, nonatomic) IBOutlet APHStackedCircleView *chartView;

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) NSMutableArray *datasetForToday;
@property (nonatomic, strong) NSMutableArray *datasetForTheWeek;
@property (nonatomic, strong) NSMutableArray *normalizedSegmentValues;

@property (nonatomic) BOOL showTodaysDataAtViewLoad;
@property (nonatomic) NSInteger numberOfDaysOfFitnessWeek;

@end

@implementation APHActivityTrackingStepViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.daysRemaining.text = [self fitnessDaysRemaining];
    
    self.showTodaysDataAtViewLoad = YES;
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Activity Tracking", @"Activity Tracking");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(handleClose:)];
    self.view.layer.backgroundColor = [UIColor colorWithWhite:0.973 alpha:1.000].CGColor;
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)handleToday:(UIButton *)sender
{
    [self showDataForKind:SevenDayFitnessDatasetKindToday];
}

- (IBAction)handleWeek:(UIButton *)sender
{
    [self showDataForKind:SevenDayFitnessDatasetKindWeek];
}

- (void)showDataForKind:(SevenDayFitnessDatasetKinds)kind
{
    if (kind == SevenDayFitnessDatasetKindToday) {
        [self normalizeData:self.datasetForToday];
    } else {
        [self normalizeData:self.datasetForTheWeek];
    }
    
    self.chartView.hideAllLabels = NO;
    self.chartView.insideCaptionText = NSLocalizedString(@"Distance", @"Distance");
    self.chartView.scale = @[
                             [NSValue valueWithRange:NSMakeRange(0, 402)],
                             [NSValue valueWithRange:NSMakeRange(0, 804)],
                             [NSValue valueWithRange:NSMakeRange(0, 1207)]
                             ];
    [self.chartView plotSegmentValues:self.normalizedSegmentValues];
}

- (void)handleClose:(UIBarButtonItem *)sender
{
    if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
        [self.delegate stepViewControllerDidFinish:self navigationDirection:RKSTStepViewControllerNavigationDirectionForward];
    }
}

#pragma mark - Queries

- (void)runStatQueryFromDate:(NSDate *)startDate toDate:(NSDate *)endDate
{
    NSLog(@"Start/End: %@/%@", startDate, endDate);
    
    HKQuantityType *distance = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate
                                                               endDate:endDate
                                                               options:HKQueryOptionStrictStartDate];
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    HKStatisticsQuery *query;
    query = [[HKStatisticsQuery alloc] initWithQuantityType:distance
                                    quantitySamplePredicate:predicate
                                                    options:sumOptions
                                          completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
                                              HKQuantity *sum = [result sumQuantity];
                                              NSLog(@"Distance (m): %f", [sum doubleValueForUnit:[HKUnit meterUnit]]);
                                          }];
    
    [self.healthStore executeQuery:query];
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
        interval.hour = kIntervalByHour;
        NSLog(@"Today Start/End: %@/%@", startDate, [NSDate date]);
    } else {
        startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                             minute:0
                                                             second:0
                                                             ofDate:[self checkSevenDayFitnessStartDate]
                                                            options:0];
        interval.day = kIntervalByDay;
        NSLog(@"Week Start/End: %@/%@", startDate, [NSDate date]);
    }
    
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
            dispatch_async(dispatch_get_main_queue(), ^{
                if ((kind == SevenDayFitnessDatasetKindToday) && self.showTodaysDataAtViewLoad) {
                    [self handleToday:nil];
                    self.showTodaysDataAtViewLoad = NO;
                }
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

- (NSString *)fitnessDaysRemaining
{
    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                 minute:0
                                                                 second:0
                                                                 ofDate:[self checkSevenDayFitnessStartDate]
                                                                options:0];
    NSDate *today = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                             minute:0
                                                             second:0
                                                             ofDate:[NSDate date]
                                                            options:0];
    // Compute the remaing days of the 7 day fitness allocation.
    NSDateComponents *numberOfDaysFromStartDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                                  fromDate:startDate
                                                                                    toDate:today
                                                                                   options:NSCalendarWrapComponents];
    self.numberOfDaysOfFitnessWeek = [numberOfDaysFromStartDate day];
    
    NSUInteger daysRemain = 7 - self.numberOfDaysOfFitnessWeek;

    NSString *days = (daysRemain == 1) ? NSLocalizedString(@"Day", @"Day") : NSLocalizedString(@"Days", @"Days");
    
    NSString *remaining = [NSString stringWithFormat:NSLocalizedString(@"%lu %@ Remaining",
                                                                       @"{count} {day/s} Remaining"), daysRemain, days];
    
    return remaining;
}

#pragma mark - Normalize Data

- (void)normalizeData:(NSArray *)dataset
{
    NSRange inactiveRange = NSMakeRange(0, 402);
    NSRange sedentaryRange = NSMakeRange(0, 804);
    NSRange moderateRange = NSMakeRange(0, 1207); // a number beyond this is considered vigorous
    
    self.normalizedSegmentValues = [NSMutableArray arrayWithArray:@[
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
        
        NSMutableDictionary *normalSegment = [[self.normalizedSegmentValues objectAtIndex:segment] mutableCopy];
        NSNumber *currentValue = normalSegment[kDatasetValueKey];
        
        normalSegment[kDatasetValueKey] = [NSNumber numberWithInteger:[currentValue integerValue] + value];

        [self.normalizedSegmentValues replaceObjectAtIndex:segment withObject:normalSegment];
    }
}

- (NSDate *)checkSevenDayFitnessStartDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *fitnessStartDate = [defaults objectForKey:kSevenDayFitnessStartDateKey];
    
    if (!fitnessStartDate) {
        fitnessStartDate = [NSDate date];
        [self saveSevenDayFitnessStartDate:fitnessStartDate];
    }
    
    return fitnessStartDate;
}

- (void)saveSevenDayFitnessStartDate:(NSDate *)startDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:startDate forKey:kSevenDayFitnessStartDateKey];
    
    [defaults synchronize];
}

@end
