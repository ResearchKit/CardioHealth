//
//  APHFitnessTaskViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTaskViewController.h"

static NSString *MainStudyIdentifier = @"com.cardioVascular.fitnessTest";
static NSString *kdataResultsFileName = @"FitnessTestResult.json";

static  NSString  *kFitnessTestStep101 = @"FitnessStep101";
static  NSString  *kFitnessTestStep102 = @"FitnessStep102";
static  NSString  *kFitnessTestStep103 = @"FitnessStep103";
static  NSString  *kFitnessTestStep104 = @"FitnessStep104";
static  NSString  *kFitnessTestStep105 = @"FitnessStep105";
static  NSString  *kFitnessTestStep106 = @"FitnessStep106";

static  NSString  *kImportantDetailsViewControllerId = @"APHImportantDetailsTableViewController";

static NSInteger kCountDownTimer = 1;

@interface APHFitnessTaskViewController ()

@property  (nonatomic, weak)  APCStepProgressBar  *progressor;
@property (strong, nonatomic) APHFitnessTestHealthKitSampleTypeTracker *healthKitSampleTracker;
@property (strong, nonatomic) APHFitnessTestDistanceTracker *distanceTracker;

@property (strong, nonatomic) RKSTDataArchive *taskArchive;

@property (assign) NSInteger heartRateMonitoring;
@property (assign) BOOL      heartRateIsUpdating;

@property (strong, nonatomic) NSData *lastDataResult;

@property (strong, nonatomic) CLLocation *previousLocation;
@property (assign) CLLocationDistance totalDistance;
@property (assign) BOOL finishedSixMinuteStep;
@end

@implementation APHFitnessTaskViewController

/*********************************************************************************/
#pragma  mark  -  Initialisation
/*********************************************************************************/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //sixMinuteStepFlag
    self.finishedSixMinuteStep = NO;
    
    self.stepsToAutomaticallyAdvanceOnTimer = @[kFitnessTestStep102, kFitnessTestStep103, kFitnessTestStep104, kFitnessTestStep105];
}

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
    
    self.heartRateMonitoring = 0;
    self.heartRateIsUpdating = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

+ (RKSTOrderedTask *)createTask:(APCScheduledTask *)scheduledTask
{
    APCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    APCParameters *parameters = appDelegate.dataSubstrate.parameters;
    
    NSMutableArray *steps = [[NSMutableArray alloc] init];

    {
        RKSTInstructionStep *step = [[RKSTInstructionStep alloc] initWithIdentifier:kFitnessTestStep101];
        step.title = NSLocalizedString(@"Measure Excercise Tolerance", @"");
        step.detailText = NSLocalizedString(@"Once you tap Get Started, you will have 5 seconds until this test begins tracking your movement.", @"");
        [steps addObject:step];
    }
    
    {
        //Introduction to fitness test
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:kFitnessTestStep102];
        step.title = NSLocalizedString(@"Fitness Test", @"");
        step.text = NSLocalizedString(@"Get Ready!", @"");
        step.countDownInterval = kCountDownTimer;
        step.shouldUseNextAsSkipButton = NO;
        step.shouldPlaySoundOnStart = YES;
        step.shouldSpeakCountDown = YES;
        step.shouldStartTimerAutomatically = YES;
        
        [steps addObject:step];
    }
    
    {
        //Walking 6 minutes
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:kFitnessTestStep103];
        step.recorderConfigurations = @[[APHFitnessTestCustomRecorderConfiguration new]];
        step.title = NSLocalizedString(@"Start Walking", @"");
        step.text = @"   \n      ";
        step.shouldPlaySoundOnStart = YES;
        step.shouldVibrateOnStart = YES;
        step.spokenInstruction = NSLocalizedString(@"Start Walking", @"");
        step.countDownInterval = [[parameters numberForKey:@"FT6Min"] doubleValue];
        step.shouldUseNextAsSkipButton = NO;
        step.shouldStartTimerAutomatically = YES;
        
        [steps addObject:step];
    }
    
    {
        //Stop and sit in a comfortable position for 3 minutes
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:kFitnessTestStep104];
        step.recorderConfigurations = @[[APHFitnessTestCustomRecorderConfiguration new]];
        step.title = NSLocalizedString(@"Good Work!", @"");
        step.text = NSLocalizedString(@"Stop walking, and sit in a comfortable position for 3 minutes.", @"");
        step.shouldPlaySoundOnStart = YES;
        step.shouldVibrateOnStart = YES;
        step.spokenInstruction = step.text;
        step.countDownInterval = [[parameters numberForKey:@"FT3MinComfPos"] doubleValue];
        step.shouldUseNextAsSkipButton = NO;
        step.shouldStartTimerAutomatically = YES;
        
        [steps addObject:step];
    }
    
    {
        //Finished
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:kFitnessTestStep106];
        step.recorderConfigurations = @[];
        step.title = NSLocalizedString(@"Good job.", @"");
        step.text = NSLocalizedString(@"Great job.", @"");
        
        step.shouldUseNextAsSkipButton = NO;
        [steps addObject:step];
    }

    RKSTOrderedTask  *task = [[RKSTOrderedTask alloc] initWithIdentifier:@"Fitness Test" steps:steps];
    
    return  task;
}

/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/

- (BOOL)taskViewController:(RKSTTaskViewController *)taskViewController shouldPresentStep:(RKSTStep *)step
{
    return YES;
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController stepViewControllerWillAppear:(RKSTStepViewController *)stepViewController
{
    
    [super taskViewController:taskViewController stepViewControllerWillAppear:stepViewController];
    
    taskViewController.navigationBar.topItem.title = NSLocalizedString(@"6 Minute Walk", @"6 Minute Walk");
    
    stepViewController = (RKSTStepViewController *) stepViewController;
    
    if ([stepViewController.step.identifier isEqualToString:@""]) {
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
        
        [(RKSTActiveStepViewController*)stepViewController setCustomView:customView];
        
        stepViewController.continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Get Started" style:stepViewController.continueButton.style target:stepViewController.continueButton.target action:stepViewController.continueButton.action];
        
        stepViewController.skipButton = nil;
        
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep102]) {
    
        stepViewController.continueButton = nil;
        stepViewController.skipButton = nil;
    
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep105]) {

        stepViewController.continueButton = nil;
        stepViewController.skipButton = nil;
        
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep106]) {
        
        stepViewController.continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Well done!" style:stepViewController.continueButton.style target:stepViewController.continueButton.target action:stepViewController.continueButton.action];
        
        taskViewController.navigationBar.topItem.title = NSLocalizedString(@"Task Complete", @"Task Complete");
        
    }
}

- (RKSTStepViewController *)taskViewController:(RKSTTaskViewController *)taskViewController viewControllerForStep:(RKSTStep *)step
{
    RKSTStepViewController  *controller = nil;
    
    if (step.identifier == kFitnessTestStep101) {
        controller = (APCInstructionStepViewController *)[[UIStoryboard storyboardWithName:@"APCInstructionStep" bundle:[NSBundle appleCoreBundle]] instantiateInitialViewController];
        APCInstructionStepViewController  *instController = (APCInstructionStepViewController*)controller;
        instController.imagesArray = @[ @"6minwalk", @"6minwalk-Icon-1", @"6minwalk-Icon-2", @"Updated-Data-Cardio" ];
        instController.headingsArray = @[ @"Test Exercise Tolerance", @"Test Exercise Tolerance", @"Test Exercise Tolerance", @"Test Exercise Tolerance" ];
        instController.messagesArray  = @[
                                      @"Once you tap Get Started, you will have 5 seconds until this test begins tracking your movements.",
                                      @"Begin walking at your fastest possible pace for 6 minutes.",
                                      @"After 6 minutes expires and if you're tracking your BPM sit down and rest for 3 minutes.",
                                      @"After the test is finished, your results will be analyzed and available on the dashboard. You will be notified when analysis is ready."
                                      ];
        UIButton  *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect     frame = CGRectMake(0.0, 0.0, 100.0, 27.0);
        button.frame = frame;
        
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:@"View Important Details" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(viewImportantDetailButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        instController.accessoryContent = button;
        controller.delegate = self;
        controller.step = step;
    }   else if (step.identifier == kFitnessTestStep106) {
        
        APCSimpleTaskSummaryViewController  *controller = [[APCSimpleTaskSummaryViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
        controller.delegate = self;
        controller.step = step;
        controller.taskProgress = 0.25;
    }
    return  controller;
}

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/

- (void)viewImportantDetailButtonTapped
{
    UIStoryboard  *storyboard = [UIStoryboard storyboardWithName:kImportantDetailsViewControllerId bundle:nil];
    UITableViewController  *controller = [storyboard instantiateViewControllerWithIdentifier:kImportantDetailsViewControllerId];
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:controller animated:YES completion:NULL];
}

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/

-(void)sendCompleteResult:(RKSTDataResult*)result
{
    // In a real application, consider adding to the archive on a concurrent queue.
    NSError *err = nil;
    if (![result addToArchive:self.taskArchive error:&err])
    {
        // Error adding the result to the archive; archive may be invalid. Tell
        // the user there's been a problem and stop the task.
        NSLog(@"Error adding %@ to archive: %@", result, err);
    }
}

-(void)sendResult:(RKSTDataResult*)result
{
    // In a real application, consider adding to the archive on a concurrent queue.
    NSError *err = nil;
    if (![result addToArchive:self.taskArchive error:&err])
    {
        // Error adding the result to the archive; archive may be invalid. Tell
        // the user there's been a problem and stop the task.
        NSLog(@"Error adding %@ to archive: %@", result, err);
    }
}

/*********************************************************************************/
#pragma mark - APHFitnessTestHealthKitSampleTypeTrackerDelegate delegate methods
/*********************************************************************************/

- (void)fitnessTestHealthKitSampleTypeTracker:(APHFitnessTestHealthKitSampleTypeTracker *)heartRateTracker didUpdateHeartRate:(NSInteger)heartBPM {
    
    if (self.heartRateMonitoring == 1) {
        
        self.heartRateIsUpdating = YES;
    }
    
    self.heartRateMonitoring = 1;
    
    
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
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)parameters didUpdateLocations:(CLLocation *)location {
    
    NSDictionary* dictionary = @{@"latitude" : [NSNumber numberWithDouble:location.coordinate.latitude],
                                 @"longitude" : [NSNumber numberWithDouble:location.coordinate.longitude],
                                 @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
    
    if (!self.finishedSixMinuteStep) {
        
        if (!self.previousLocation) {
            
            self.previousLocation = location;
        } else {
            
            CLLocationDistance distance = [self.previousLocation distanceFromLocation:location];
            
            self.totalDistance += distance;
            
            self.previousLocation = location;
        }
    }
    
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
