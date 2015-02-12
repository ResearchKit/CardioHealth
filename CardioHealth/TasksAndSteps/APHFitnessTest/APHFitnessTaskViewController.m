// 
//  APHFitnessTaskViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHFitnessTaskViewController.h"
#import <CoreLocation/CoreLocation.h>

//static NSInteger const  kRestDuration              = 3.0 * 60.0;
//static NSInteger const  kWalkDuration              = 6.0 * 60.0;
static NSInteger const  kRestDuration              = 3.0;// * 60.0;
static NSInteger const  kWalkDuration              = 10.0;// * 60.0;
static NSString* const  kFitnessTestIdentifier     = @"6-Minute Walk Test";

static NSString* const  kIntroStep                 = @"instruction";
static NSString* const  kIntroOneStep              = @"instruction1";
static NSString* const  kCountdownStep             = @"countdown";
static NSString* const  kWalkStep                  = @"fitness.walk";
static NSString* const  kRestStep                  = @"fitness.rest";
static NSString* const  kConclusionStep            = @"conclusion";

static NSString* const  kHeartRateFileNameComp     = @"HKQuantityTypeIdentifierHeartRate";
static NSString* const  kLocationFileNameComp      = @"location";
static NSString* const  kFileResultsKey            = @"items";
static NSString* const  kHeartRateValueKey         = @"value";
static NSString* const  kCoordinate                 = @"coordinate";
static NSString* const  kLongitude                 = @"longitude";
static NSString* const  kLatitude                  = @"latitude";

static NSString* const kCompletedKeyForDashboard   = @"completed";
static NSString* const kPeakHeartRateForDashboard  = @"peakHeartRate";
static NSString* const kAvgHeartRateForDashboard   = @"avgHeartRate";
static NSString* const kLastHeartRateForDashboard  = @"lastHeartRate";



@interface APHFitnessTaskViewController ()

@end

@implementation APHFitnessTaskViewController

/*********************************************************************************/
#pragma  mark  -  Initialisation
/*********************************************************************************/

+ (RKSTOrderedTask *)createTask:(APCScheduledTask *)scheduledTask
{
    RKSTOrderedTask  *task = [RKSTOrderedTask fitnessCheckTaskWithIdentifier:kFitnessTestIdentifier intendedUseDescription:nil walkDuration:kWalkDuration restDuration:kRestDuration options:RKPredefinedTaskOptionNone];
    
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
    
    return  task;
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController stepViewControllerWillAppear:(RKSTStepViewController *)stepViewController {
    
    if ([stepViewController.step.identifier isEqualToString:kConclusionStep]) {
        [[UIView appearance] setTintColor:[UIColor appTertiaryColor1]];
    }
}

- (void)taskViewControllerDidComplete:(RKSTTaskViewController *)taskViewController {
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
    
    [super taskViewControllerDidComplete:taskViewController];
    
}

- (void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController {
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
    
    [super taskViewControllerDidCancel:taskViewController];
}

/*********************************************************************************/
#pragma  mark  -  Helper methods
/*********************************************************************************/

- (NSString *) createResultSummary {
    
    NSMutableDictionary* dashboardDataSource = [NSMutableDictionary new];
    NSDictionary* distanceResults = nil;
    NSDictionary* heartRateResults = nil;
    
    RKSTStepResult* stepResult = (RKSTStepResult *)[self.result resultForIdentifier:kWalkStep];
    
    for (RKSTFileResult* fileResult in stepResult.results) {
        NSString* fileString = [fileResult.fileURL lastPathComponent];
        NSArray* nameComponents = [fileString componentsSeparatedByString:@"_"];
        
        if ([[nameComponents objectAtIndex:0] isEqualToString:kLocationFileNameComp])
        {
            distanceResults = [self computeTotalDistanceForDashboardItem:fileResult.fileURL];
            
        } else if ([[nameComponents objectAtIndex:0] isEqualToString:kHeartRateFileNameComp])
        {
            heartRateResults = [self computeHeartRateForDashboardItem:fileResult.fileURL];
        }
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSString *monthName = [[df monthSymbols] objectAtIndex:(month-1)];
    NSString *completedDate = [NSString stringWithFormat:@"%@ %ld", monthName, (long)day];
    

    [dashboardDataSource setValue:completedDate forKey:kCompletedKeyForDashboard];
    [dashboardDataSource addEntriesFromDictionary:distanceResults];
    [dashboardDataSource addEntriesFromDictionary:heartRateResults];
    
    NSString *jsonString = [self generateJSONFromDictionary:dashboardDataSource];
    
    return jsonString;
}

- (NSDictionary *) computeTotalDistanceForDashboardItem:(NSURL *)fileURL{

    NSDictionary*   distanceResults     = [self readFileResultsFor:fileURL];
    NSArray*        locations           = [distanceResults objectForKey:kFileResultsKey];
    
    
    CLLocation*     previousCoor        = nil;
    CLLocationDistance totalDistance    = 0;
    
    for (NSDictionary *location in locations) {
        float               lon = [[[location objectForKey:kCoordinate] objectForKey:kLongitude] floatValue];
        float               lat = [[[location objectForKey:kCoordinate] objectForKey:kLatitude] floatValue];
        
        CLLocation *currentCoor = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        
        if(previousCoor) {
            totalDistance       += [currentCoor distanceFromLocation:previousCoor];
            previousCoor        = currentCoor;
        }
        
        previousCoor        = currentCoor;
    }

    return @{@"totalDistance" : @(totalDistance)};
}

- (NSDictionary *) computeHeartRateForDashboardItem:(NSURL *)fileURL {
    
    NSDictionary*   heartRateResults    = [self readFileResultsFor:fileURL];
    NSArray*        heartRates          = [heartRateResults objectForKey:kFileResultsKey];

    // Using KVC operators to retrieve values for peak and average heart rate.
    return @{
             kPeakHeartRateForDashboard : [heartRates valueForKeyPath:@"@max.value"],
             kAvgHeartRateForDashboard  : [heartRates valueForKeyPath:@"@avg.value"],
             kLastHeartRateForDashboard : [[heartRates lastObject] objectForKey:kHeartRateValueKey]
            };
}


- (NSDictionary *) readFileResultsFor:(NSURL *)fileURL {

    NSError*        error       = nil;
    NSString*       contents    = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];
    NSDictionary*   results     = nil;

    APCLogError2(error);
    
    if (!error) {
        NSError*    error = nil;
        NSData*     data  = [contents dataUsingEncoding:NSUTF8StringEncoding];
        
        results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        APCLogError2(error);
    }
    
    return results;
}

- (NSString *)generateJSONFromDictionary:(NSMutableDictionary *)dictionary {
    
    NSError*    error       = nil;
    NSData*     jsonData    = [NSJSONSerialization dataWithJSONObject:dictionary
                                                               options:0
                                                                 error:&error];
    NSString* jsonString    = nil;
    
    APCLogError2(error);

    if (!error)
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

@end
