//
//  APHFitnessTaskViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTaskViewController.h"


static NSString *MainStudyIdentifier = @"com.ymedialabs.fitnessTest";

static  NSString  *kFitnessTestStep101 = @"FitnessStep101";
static  NSString  *kFitnessTestStep102 = @"FitnessStep102";
static  NSString  *kFitnessTestStep103 = @"FitnessStep103";
static  NSString  *kFitnessTestStep104 = @"FitnessStep104";
static  NSString  *kFitnessTestStep105 = @"FitnessStep105";
static  NSString  *kFitnessTestStep106 = @"FitnessStep106";
@interface APHFitnessTaskViewController ()

@property (strong, nonatomic) APHFitnessTestHealthKitSampleTypeTracker *healthKitSampleTracker;
@property (strong, nonatomic) APHFitnessTestDistanceTracker *distanceTracker;

@property (strong, nonatomic) RKDataArchive *taskArchive;
@end

@implementation APHFitnessTaskViewController

/*********************************************************************************/
#pragma  mark  -  Initialisation
/*********************************************************************************/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = NSLocalizedString(@"Fitness Test", @"");

    //setup heart rate tracker
    self.healthKitSampleTracker = [[APHFitnessTestHealthKitSampleTypeTracker alloc] init];
    [self.healthKitSampleTracker setDelegate:self];
    [self.healthKitSampleTracker startUpdating];
    
    self.distanceTracker = [[APHFitnessTestDistanceTracker alloc] init];
    [self.distanceTracker setDelegate:self];
    [self.distanceTracker prepLocationUpdates];
    
    [self beginTask];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

+ (RKTask *)createTask:(APCScheduledTask *)scheduledTask
{
    APCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    APCParameters *parameters = appDelegate.dataSubstrate.parameters;
    
    NSMutableArray *steps = [[NSMutableArray alloc] init];

    {
        //Introduction to fitness test
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kFitnessTestStep101 name:@"active step"];
        step.caption = @"Fitness Test";
        step.text = @"Once you tap Get Started, you will have 5 seconds until this test begins tracking your movement.";
        step.useNextForSkip = NO;
    
        [steps addObject:step];
    }
    
    {
        //Introduction to fitness test
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kFitnessTestStep102 name:@"active step"];
        step.caption = @"Fitness Test";
        step.text = @"Get Ready!";
        step.countDown = 5.0;
        step.useNextForSkip = NO;
        
        [steps addObject:step];
    }
    
    
    {
        //Walking 6 minutes
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kFitnessTestStep103 name:@"6 Minute Walk"];
        step.recorderConfigurations = @[[APHFitnessTestCustomRecorderConfiguration new]];

        

        step.caption = NSLocalizedString(@"6 Minute Walk", @"");
        step.text = NSLocalizedString(@"Walk 6 minutes.", @"");
        step.buzz = YES;
        step.vibration = YES;
        step.voicePrompt = step.text;
        step.countDown = [[parameters numberForKey:@"FT6Min"] doubleValue];
        step.useNextForSkip = NO;
        
        [steps addObject:step];
    }
    
    {
        //Stop and sit in a comfortable position for 3 minutes
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kFitnessTestStep104 name:@"3 Minutes in a comfortable Position"];
        step.recorderConfigurations = @[[APHFitnessTestCustomRecorderConfiguration new]];
        step.caption = NSLocalizedString(@"3 Minute Comfortable Position", @"");
        step.text = NSLocalizedString(@"Rest 3 minutes in a comfortable position", @"");
        step.buzz = YES;
        step.vibration = YES;
        step.voicePrompt = step.text;
        step.countDown = [[parameters numberForKey:@"FT3MinComfPos"] doubleValue];
        step.useNextForSkip = NO;
        
        [steps addObject:step];
    }

    {
        //Rest for 3 minutes
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kFitnessTestStep105 name:@"3 Minutes in a resting Position"];
        step.recorderConfigurations = @[[APHFitnessTestCustomRecorderConfiguration new]];
        step.countDown = [[parameters numberForKey:@"FT3MinRest"] doubleValue];
        step.caption = NSLocalizedString(@"3 Minute Rest", @"");
        step.text = NSLocalizedString(@"Now rest 3 minutes.", @"");
        step.buzz = YES;
        step.vibration = YES;
        step.voicePrompt = step.text;
        step.useNextForSkip = NO;
        
        [steps addObject:step];
    }
    
    {
        //Finished
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kFitnessTestStep106 name:@"Completed"];
        step.recorderConfigurations = @[];
        step.caption = NSLocalizedString(@"Good job.", @"");
        step.text = NSLocalizedString(@"Great job.", @"");
        
        step.useNextForSkip = NO;
        [steps addObject:step];
    }

    RKTask  *task = [[RKTask alloc] initWithName:@"Fitness Test" identifier:@"Fitness Test" steps:steps];
    
    return  task;
}


/*********************************************************************************/
#pragma  mark  - Private methods
/*********************************************************************************/

- (void) importantDetails:(id)sender {
    APHImportantDetailsViewController *detailsVC = [APHImportantDetailsViewController new];
    [self presentViewController:detailsVC animated:YES completion:^{
        NSLog(@"Present details view");
    }];
}

- (void)beginTask
{
    if (self.taskArchive)
    {
        [self.taskArchive resetContent];
    }
    
    self.taskArchive = [[RKDataArchive alloc] initWithItemIdentifier:[RKItemIdentifier itemIdentifierForTask:self.task] studyIdentifier:MainStudyIdentifier taskInstanceUUID:self.taskInstanceUUID extraMetadata:nil fileProtection:RKFileProtectionCompleteUnlessOpen];
}

/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/
- (void)taskViewController:(RKTaskViewController *)taskViewController
willPresentStepViewController:(RKStepViewController *)stepViewController{
    
    if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep101]) {
        UIView* customView = [UIView new];
        customView.backgroundColor = [UIColor cyanColor];
        
        // Have the custom view request the space it needs.
        // A little tricky because we need to let it size to fit if there's not enough space.
        [customView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[c(>=160)]" options:0 metrics:nil views:@{@"c":customView}];
        for (NSLayoutConstraint *constraint in verticalConstraints)
        {
            constraint.priority = UILayoutPriorityFittingSizeLevel;
        }
        [customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=280)]" options:0 metrics:nil views:@{@"c":customView}]];
        [customView addConstraints:verticalConstraints];
        
        [(RKActiveStepViewController*)stepViewController setCustomView:customView];
        
        // Set custom button on navi bar
        stepViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Custom button"
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:nil
                                                                                              action:nil];
        
        
        
        stepViewController.learnMoreButton =[[UIBarButtonItem alloc] initWithTitle:@"View Important Details" style:stepViewController.continueButton.style target:self action:@selector(importantDetails:)];
        
        
        
        
        
        stepViewController.continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Get Started" style:stepViewController.continueButton.style target:stepViewController.continueButton.target action:stepViewController.continueButton.action];
        
//        [stepViewController.continueButton.tintColor = UIColor colorWithRed:0.83 green:0.43 blue:0.57 alpha:1];

        
        stepViewController.skipButton = nil;
        
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep102]) {
    
        stepViewController.continueButton = nil;
        stepViewController.skipButton = nil;
    
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep103]) {
        
        stepViewController.continueButton = nil;
        stepViewController.skipButton = nil;
        
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep104]) {
        
        stepViewController.continueButton = nil;
        stepViewController.skipButton = nil;
        
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep105]) {

        stepViewController.continueButton = nil;
        stepViewController.skipButton = nil;
        
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep106]) {
        
        stepViewController.continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Well done!" style:stepViewController.continueButton.style target:stepViewController.continueButton.target action:stepViewController.continueButton.action];
        
    }
}



/*********************************************************************************/
#pragma  mark  -  Navigation Bar Button Action Methods
/*********************************************************************************/

- (void)cancelButtonTapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonTapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/*********************************************************************************/
#pragma mark - APHFitnessTestHealthKitSampleTypeTrackerDelegate delegate methods
/*********************************************************************************/

- (void)fitnessTestHealthKitSampleTypeTracker:(APHFitnessTestHealthKitSampleTypeTracker *)heartRateTracker didUpdateHeartRate:(NSInteger)heartBPM {
    
    NSDictionary* heartBPMDictionary = @{@"heartBPM": [NSNumber numberWithInteger:heartBPM],
                                 @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};

    [[NSNotificationCenter defaultCenter] postNotificationName:@"APHFitnessHeartRateBPMUpdated" object:self userInfo:heartBPMDictionary];
}

- (void)fitnessTestHealthKitSampleTypeTracker:(APHFitnessTestHealthKitSampleTypeTracker *)stepCountTracker didUpdateStepCount:(NSInteger)stepCount {
    
    NSDictionary* stepCountDictionary = @{@"stepCount": [NSNumber numberWithInteger:stepCount],
                                     @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APHFitnessStepCountUpdated" object:self userInfo:stepCountDictionary];
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
}


@end
