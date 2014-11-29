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

static NSString *kNotificationUpdatedName = @"APHFitnessDistanceUpdated";
static  NSString  *kImportantDetailsViewControllerId = @"APHImportantDetailsTableViewController";

static  NSString  *kFitnessTestStep101 = @"FitnessStep101";
static  NSString  *kFitnessTestStep102 = @"FitnessStep102";
static  NSString  *kFitnessTestStep103 = @"FitnessStep103";
static  NSString  *kFitnessTestStep104 = @"FitnessStep104";
static  NSString  *kFitnessTestStep105 = @"FitnessStep105";
static  NSString  *kFitnessTestStep106 = @"FitnessStep106";

static NSInteger kCountDownTimer = 5;
static NSInteger kUpdatedHeartRateThreshold = 2;
static NSInteger kUpdatedHeartRateTimeThreshold = 10;

@interface APHFitnessTaskViewController ()

@property  (nonatomic, weak)  APCStepProgressBar  *progressor;
@property (strong, nonatomic) APHFitnessTestHealthKitSampleTypeTracker *healthKitSampleTracker;
@property (strong, nonatomic) APHFitnessTestDistanceTracker *distanceTracker;


@property (assign) NSInteger heartRateMonitoring;
@property (assign) BOOL heartRateIsUpdating;

@property (strong, nonatomic) NSData *lastDataResult;

@property (strong, nonatomic) CLLocation *previousLocation;
@property (assign) CLLocationDistance totalDistance;

@end

@implementation APHFitnessTaskViewController

/*********************************************************************************/
#pragma  mark  -  Initialisation
/*********************************************************************************/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    NSInteger totalUpdates = appDelegate.healthKitTracker.totalUpdates;
    NSDate *lastUpdate = appDelegate.healthKitTracker.lastUpdate;
    
    NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:lastUpdate];
    
    BOOL heartIsUpdating = NO;
    
    if (totalUpdates > kUpdatedHeartRateThreshold && secondsBetween < kUpdatedHeartRateTimeThreshold) {
        heartIsUpdating = YES;
    }

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
    
    if (heartIsUpdating) {
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
    }
    
    {
        //Finished
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:kFitnessTestStep105];
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

- (void)taskViewController:(RKSTTaskViewController *)taskViewController stepViewControllerWillAppear:(RKSTStepViewController *)stepViewController
{
    
    [super taskViewController:taskViewController stepViewControllerWillAppear:stepViewController];
    
    taskViewController.navigationBar.topItem.title = NSLocalizedString(@"6 Minute Walk", @"6 Minute Walk");
    
    stepViewController = (RKSTStepViewController *) stepViewController;
    
    if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep104]) {

        RKSTStepResult *stepResult = [taskViewController.result stepResultForStepIdentifier:kFitnessTestStep103];
        
        RKSTDataResult * result = (RKSTDataResult*) [stepResult resultForIdentifier:kFitnessTestStep103];
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:result.data
                                                             options:kNilOptions
                                                               error:&error];
        
        NSArray* totalDist = json[@"distance"];
        NSDictionary *singleEntry = [totalDist lastObject];
        
        NSLog(@"distance: %@", singleEntry[@"totalDistanceInFeet"]);
        
        //Adding "Time" subview
        UILabel *countdownTitle = [UILabel new];
        [countdownTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
        [countdownTitle setBackgroundColor:[UIColor clearColor]];
        countdownTitle.text = @"Time";
        countdownTitle.textAlignment = NSTextAlignmentCenter;
        
        [countdownTitle addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=55)]" options:0 metrics:nil views:@{@"c":countdownTitle}]];
        
        //TODO Add Font and Size
        /*******************/
        [countdownTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:32]];
        
        [stepViewController.view addSubview:countdownTitle];
        
        [stepViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:stepViewController.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
        
        [stepViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:stepViewController.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
        
        [stepViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:stepViewController.view attribute:NSLayoutAttributeCenterY multiplier:0.47f constant:5.0f]];

        [stepViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:stepViewController.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0
                                                                         constant:0.0]];
        
        //Adding custom view which includes the distance and BPM.
        UIView *updatedView = [UIView new];
        
        
        RKSTActiveStepViewController *stepVC = (RKSTActiveStepViewController *)stepViewController;
        [stepVC setCustomView:updatedView];
        
        // Height constraint
        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:updatedView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:stepViewController.view
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:0.15
                                                                         constant:0]];
        
        
        /**** use for setting custom views. **/
        UINib *nib = [UINib nibWithNibName:@"APHFitnessTestRestComfortablyView" bundle:nil];
        APHFitnessTestRestComfortablyView *restComfortablyView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];

        [stepViewController.view addSubview:restComfortablyView];
        
        //int distanceIntFeet = (int)roundf(self.totalDistance);
        CLLocationDistance distanceInFeet = [singleEntry[@"totalDistanceInFeet"] doubleValue];
        int distanceAsInt = (int)roundf(distanceInFeet);
        [restComfortablyView setTotalDistance:[NSNumber numberWithInt:distanceAsInt]];
        
        [restComfortablyView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [restComfortablyView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=280)]" options:0 metrics:nil views:@{@"c":restComfortablyView}]];
        
        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:stepVC.view
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:0.5
                                                                         constant:0]];
        
        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
                                                                        attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                                           toItem:stepVC.view
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1.15
                                                                         constant:75]];
        
        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
                                                                        attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                           toItem:stepVC.view
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1
                                                                         constant:0]];
        
        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:stepVC.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:restComfortablyView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0
                                                                         constant:0.0]];
        
        
        [stepVC.view layoutIfNeeded];
        
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep105]) {
        
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
    }   else if (step.identifier == kFitnessTestStep105) {
        
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
    

    if (!self.previousLocation) {
        
        self.previousLocation = location;
    } else {
        
        CLLocationDistance distance = [self.previousLocation distanceFromLocation:location];
        
        self.totalDistance += distance;
        
        self.previousLocation = location;
    }
    
    if (self.currentStepViewController.step.identifier == kFitnessTestStep103 || self.currentStepViewController.step.identifier == kFitnessTestStep104) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedName object:self userInfo:dictionary];
    }
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
