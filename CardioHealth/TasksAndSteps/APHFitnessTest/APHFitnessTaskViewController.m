//
//  APHFitnessTaskViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTaskViewController.h"

static  NSString  *kFitnessTestStep101 = @"FitnessStep101";
static  NSString  *kFitnessTestStep102 = @"FitnessStep102";
static  NSString  *kFitnessTestStep103 = @"FitnessStep103";
static  NSString  *kFitnessTestStep104 = @"FitnessStep104";
static  NSString  *kFitnessTestStep105 = @"FitnessStep105";
@interface APHFitnessTaskViewController ()

@property (strong, nonatomic) APHFitnessTestHealthKitSampleTypeTracker *healthKitSampleTracker;
@property (strong, nonatomic) APHFitnessTestDistanceTracker *distanceTracker;

@end

@implementation APHFitnessTaskViewController

/*********************************************************************************/
#pragma  mark  -  Initialisation
/*********************************************************************************/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Fitness Test";
    
    //setup heart rate tracker
    self.healthKitSampleTracker = [[APHFitnessTestHealthKitSampleTypeTracker alloc] init];
    [self.healthKitSampleTracker setDelegate:self];
    [self.healthKitSampleTracker startUpdating];
    
    self.distanceTracker = [[APHFitnessTestDistanceTracker alloc] init];
    [self.distanceTracker setDelegate:self];
    [self.distanceTracker prepLocationUpdates];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.title = @"Fitness Test";
}

+ (RKTask *)createTask:(APCScheduledTask *)scheduledTask
{
    NSMutableArray *steps = [[NSMutableArray alloc] init];

    {
        //Introduction to fitness test
        RKIntroductionStep *step = [[RKIntroductionStep alloc] initWithIdentifier:kFitnessTestStep101 name:@"Fitness Test Intro"];
        [steps addObject:step];
    }
    
    {
        //Walking 6 minutes
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kFitnessTestStep102 name:@"6 Minute Walk"];
        step.recorderConfigurations = @[[APHFitnessTestCustomRecorderConfiguration new]];
        step.countDown = 10.0;
        step.caption = NSLocalizedString(@"6 Minute Walk", @"");
        step.text = NSLocalizedString(@"Walk 6 minutes.", @"");
        [steps addObject:step];
    }
    
    {
        //Stop and sit in a comfortable position for 3 minutes
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kFitnessTestStep103 name:@"3 Minutes in a comfortable Position"];
        step.recorderConfigurations = @[[APHFitnessTestCustomRecorderConfiguration new]];
        step.countDown = 10.0;
        step.caption = NSLocalizedString(@"3 Minute Comfortable Position", @"");
        step.text = NSLocalizedString(@"3 minutes Comfortable Position", @"");
        [steps addObject:step];
    }

    {
        //Rest for 3 minutes
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kFitnessTestStep104 name:@"3 Minutes in a resting Position"];
        step.recorderConfigurations = @[[APHFitnessTestCustomRecorderConfiguration new]];
        step.countDown = 10.0;
        step.caption = NSLocalizedString(@"3 Minute Rest", @"");
        step.text = NSLocalizedString(@"Now rest 3 minutes.", @"");
        [steps addObject:step];
    }
    
    {
        //Finished
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kFitnessTestStep105 name:@"Completed"];
        step.recorderConfigurations = @[];
        step.caption = NSLocalizedString(@"Good job.", @"");
        step.text = NSLocalizedString(@"Great job.", @"");
        [steps addObject:step];
    }

    RKTask  *task = [[RKTask alloc] initWithName:@"Fitness Test" identifier:@"Fitness Test" steps:steps];
    
    return  task;
}

#pragma  mark  -  Navigation Bar Button Action Methods

- (void)cancelButtonTapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{ } ];
}

- (void)doneButtonTapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{ } ];
}

/*********************************************************************************/
#pragma mark - APHFitnessTestHealthKitSampleTypeTrackerDelegate delegate methods
/*********************************************************************************/

- (void)fitnessTestHealthKitSampleTypeTracker:(APHFitnessTestHealthKitSampleTypeTracker *)heartRateTracker didUpdateHeartRate:(NSInteger)heartBPM {
    
    NSDictionary* dictionary = @{@"heartBPM": [NSNumber numberWithInteger:heartBPM],
                                 @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};

    [[NSNotificationCenter defaultCenter] postNotificationName:@"APHFitnessHeartRateBPMUpdated" object:self userInfo:dictionary];
}

- (void)fitnessTestHealthKitSampleTypeTracker:(APHFitnessTestHealthKitSampleTypeTracker *)stepCountTracker didUpdateStepCount:(NSInteger)stepCount {
    
    NSDictionary* dictionary = @{@"stepCount": [NSNumber numberWithInteger:stepCount],
                                     @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APHFitnessStepCountUpdated" object:self userInfo:dictionary];
}

/*********************************************************************************/
#pragma mark - APHFitnessTestDistanceTrackerDelegate delegate methods
/*********************************************************************************/

/**
 * @brief Did update locations.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)parameters didUpdateLocations:(CLLocationDistance)distance {
    
    NSDictionary* dictionary = @{@"distance": [NSNumber numberWithDouble:distance],
                                 @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APHFitnessDistanceUpdated" object:self userInfo:dictionary];
}

- (void)locationManager:(CLLocationManager *)locationManager finishedPrepLocation:(BOOL)finishedPrep {
    [self.distanceTracker start];
}

/**
 * @brief Signal strength changed
 */
- (void)locationManager:(CLLocationManager*)locationManager signalStrengthChanged:(CLLocationAccuracy)signalStrength {
    
}

/**
 * @brief GPS is consistently weak
 */
- (void)locationManagerSignalConsistentlyWeak:(CLLocationManager*)manager {
    
}

- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)distanceTracker weakGPSSignal:(NSString *)message {
    //    UIAlertController *alertController = [UIAlertController
    //                                          alertControllerWithTitle:@"GPS Signal"
    //                                          message:message
    //                                          preferredStyle:UIAlertControllerStyleAlert];
    //
    //    [self presentViewController:alertController animated:YES completion:nil];
    //
    //    [self performSelector:@selector(dismiss:) withObject:alertController afterDelay:4];
}


@end
