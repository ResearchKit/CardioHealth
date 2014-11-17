//
//  APHActivityTrackingStepViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHActivityTrackingStepViewController.h"
#import "APHActivitySummaryView.h"
#import "APHActivityLegendView.h"

static NSInteger kStatusForToday = -1;
static NSInteger kStatusForTheWeek = -7;
static NSInteger kIntervalByHour = 1;
static NSInteger kIntervalByDay = 1;

@interface APHActivityTrackingStepViewController ()

@property (weak, nonatomic) IBOutlet UILabel *daysRemaining;
@property (weak, nonatomic) IBOutlet APHActivitySummaryView *chartView;
@property (weak, nonatomic) IBOutlet UIView *legendView;

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) NSMutableArray *dataset;
@property (nonatomic, strong) NSMutableArray *normalizedSegmentValues;

@property (nonatomic) NSUInteger numberOfSegments;

@end

@implementation APHActivityTrackingStepViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.daysRemaining.text = [self fitnessDaysRemaining];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(handleClose:)];
    self.view.layer.backgroundColor = [UIColor colorWithWhite:0.973 alpha:1.000].CGColor;
    
    self.dataset = [NSMutableArray array];
    
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
                                                }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)handleToday:(UIButton *)sender
{
    NSLog(@"Tapped Today.");
    [self runStatsCollectionQueryForSpan:kStatusForToday];
}

- (IBAction)handleWeek:(UIButton *)sender
{
    NSLog(@"Tapped Week.");
    [self runStatsCollectionQueryForSpan:kStatusForTheWeek];
}

- (void)showData
{
    self.chartView.hideAllLabels = YES;
    self.chartView.numberOfSegments = self.numberOfSegments;
    [self.chartView drawWithSegmentValues:self.normalizedSegmentValues];
}

- (void)handleClose:(UIBarButtonItem *)sender
{
    NSLog(@"You tapped close.");
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKStepViewControllerNavigationDirectionForward];
        }
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

- (void)runStatsCollectionQueryForSpan:(NSInteger)span
{
    NSDate *startDate = [self dateForSpan:span];
    
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    
    if (span == kStatusForToday) {
        interval.hour = kIntervalByHour;
    } else {
        interval.day = kIntervalByDay;
    }
    
    NSLog(@"Start/End: %@/%@", startDate, [NSDate date]);
    
    HKQuantityType *distanceType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:distanceType
                                                                           quantitySamplePredicate:nil
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:startDate
                                                                                intervalComponents:interval];
    // set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSDate *endDate = [NSDate date];
            NSDate *beginDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                         value:span
                                                                        toDate:endDate
                                                                       options:0];
            [results enumerateStatisticsFromDate:beginDate
                                          toDate:endDate
                                       withBlock:^(HKStatistics *result, BOOL *stop) {
                                           HKQuantity *quantity = result.sumQuantity;
                                           
                                           if (quantity) {
                                               NSDate *date = result.startDate;
                                               double value = [quantity doubleValueForUnit:[HKUnit meterUnit]];
                                               double mileValue = value/1609.344;
                                               
                                               [self.dataset addObject:@{
                                                                         @"date": date,
                                                                         @"value": [NSNumber numberWithDouble:value]
                                                                        }];
                                               
                                               
                                               NSLog(@"%@: %f (%f)", date, value, mileValue);
                                           }
                                       }];
            [self normalizeData];
            [self showData];
        }
    };
    
    [self.healthStore executeQuery:query];
    
}

#pragma mark - Helpers

/**
 * @brief   Returns an NSDate that is past/future by the value of daySpan.
 *
 * @param   daySpan Number of days relative to current date.
 *                  If negative, date will be number of days in the past;
 *                  otherwise the date will be number of days in the future.
 *
 * @return  Returns the date as NSDate.
 */
- (NSDate *)dateForSpan:(NSInteger)daySpan
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = daySpan;

    NSDate *spanDate = [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                                     toDate:[NSDate date]
                                                                    options:0];
    
    return spanDate;
}

- (NSSet *)healthKitDataTypesToRead {
    HKQuantityType *steps = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distance = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    return [NSSet setWithObjects:steps, distance, nil];
}

- (NSString *)fitnessDaysRemaining
{
    NSString *remaining = nil;
    
    NSDate *startDate = [self dateForSpan:-3];
    // Compute the remaing days of the 7 day fitness allocation.
    NSDateComponents *numberOfDaysRemaining = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                              fromDate:startDate
                                                                                toDate:[NSDate date] // today
                                                                               options:NSCalendarWrapComponents];
    if ([numberOfDaysRemaining day] == 1) {
        remaining = [NSString stringWithFormat:@"%lu Day Remaining", [numberOfDaysRemaining day]];
    } else {
        remaining = [NSString stringWithFormat:@"%lu Days Remaining", [numberOfDaysRemaining day]];
    }
    
    return remaining;
}

#pragma mark - Normalize Data

- (void)normalizeData
{
    // Why 4? Because we only have 4 segments that needs to be
    // displayed: Inactive, sedentary, moderate, and vigorous.
    self.numberOfSegments = 4;
    
    NSRange inactiveRange = NSMakeRange(0, 402);
    NSRange sedentaryRange = NSMakeRange(0, 804);
    NSRange moderateRange = NSMakeRange(0, 1207); // number beyond this is considered vigorous
    
    self.normalizedSegmentValues = [NSMutableArray arrayWithArray:@[
                                                                    @{@"segmentName": @"Inactive", @"value": @0},
                                                                    @{@"segmentName": @"Sedentary", @"value": @0},
                                                                    @{@"segmentName": @"Moderate", @"value": @0},
                                                                    @{@"segmentName": @"Vigorous", @"value": @0}
                                                                   ]];
    
    for (NSDictionary *data in self.dataset) {
        NSUInteger segment = 0;
        NSUInteger value = [data[@"value"] integerValue];
        
        if (NSLocationInRange(value, inactiveRange)) {
            segment = 0;
        } else if (NSLocationInRange(value, sedentaryRange)) {
            segment = 1;
        } else if (NSLocationInRange(value, moderateRange)) {
            segment = 2;
        } else {
            segment = 3;
        }
        
        NSNumber *currentValue = [self.normalizedSegmentValues objectAtIndex:segment][@"value"];
        
        NSDictionary *segmentValue = @{
                                       @"segmentName": [self.normalizedSegmentValues objectAtIndex:segment][@"segmentName"],
                                       @"value": [NSNumber numberWithInteger:[currentValue integerValue] + value]
                                       };
        
        [self.normalizedSegmentValues replaceObjectAtIndex:segment withObject:segmentValue];
    }
}

@end
