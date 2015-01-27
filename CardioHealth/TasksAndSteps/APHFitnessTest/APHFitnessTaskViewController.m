// 
//  APHFitnessTaskViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHFitnessTaskViewController.h"
#import <AudioToolbox/AudioToolbox.h> 

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

static NSInteger kRestDuration = 3.0 * 60.0;
static NSInteger kWalkDuration = 6.0 * 60.0;

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
    
    
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = NSLocalizedString(@"6-Minute Walk Test", @"");

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
    RKSTOrderedTask  *task = [RKSTOrderedTask fitnessCheckTaskWithIdentifier:@"6-Minute Walk Test" intendedUseDescription:@"" walkDuration:kWalkDuration restDuration:kRestDuration options:RKPredefinedTaskOptionNone];
    
    return  task;
}

/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/
//
//- (void)taskViewController:(RKSTTaskViewController *)taskViewController stepViewControllerWillAppear:(RKSTStepViewController *)stepViewController
//{
//    
//    [super taskViewController:taskViewController stepViewControllerWillAppear:stepViewController];
//    
//    taskViewController.navigationBar.topItem.title = NSLocalizedString(@"6-Minute Walk Test", @"6-Minute Walk Test");
//    
//    stepViewController = (RKSTStepViewController *) stepViewController;
//    
//    if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep104]) {
//
//        RKSTStepResult *stepResult = [taskViewController.result stepResultForStepIdentifier:kFitnessTestStep103];
//        
//        RKSTDataResult * result = (RKSTDataResult*) [stepResult resultForIdentifier:kFitnessTestStep103];
//        
//        NSError* error;
//        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:result.data
//                                                             options:kNilOptions
//                                                               error:&error];
//        
//        NSArray* totalDist = json[@"distance"];
//        NSDictionary *singleEntry = [totalDist lastObject];
//        
//        NSLog(@"distance: %@", singleEntry[@"totalDistanceInFeet"]);
//        
//        //Adding "Time" subview
//        UILabel *countdownTitle = [UILabel new];
//        [countdownTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
//        [countdownTitle setBackgroundColor:[UIColor clearColor]];
//        countdownTitle.text = @"Time";
//        countdownTitle.textAlignment = NSTextAlignmentCenter;
//        
//        [countdownTitle addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=55)]" options:0 metrics:nil views:@{@"c":countdownTitle}]];
//        
//        //TODO Add Font and Size
//        /*******************/
//        [countdownTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:32]];
//        
//        [stepViewController.view addSubview:countdownTitle];
//        
//        [stepViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:stepViewController.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
//        
//        [stepViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:stepViewController.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
//        
//        [stepViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:stepViewController.view attribute:NSLayoutAttributeCenterY multiplier:0.47f constant:5.0f]];
//
//        [stepViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle
//                                                                        attribute:NSLayoutAttributeCenterX
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:stepViewController.view
//                                                                        attribute:NSLayoutAttributeCenterX
//                                                                       multiplier:1.0
//                                                                         constant:0.0]];
//        
//        //Adding custom view which includes the distance and BPM.
//        UIView *updatedView = [UIView new];
//        
//        
//        RKSTStepViewController *stepVC = (RKSTStepViewController *)stepViewController;
//        [stepVC setCustomView:updatedView];
//        
//        // Height constraint
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:updatedView
//                                                                        attribute:NSLayoutAttributeHeight
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:stepViewController.view
//                                                                        attribute:NSLayoutAttributeHeight
//                                                                       multiplier:0.15
//                                                                         constant:0]];
//        
//        
//        /**** use for setting custom views. **/
//        UINib *nib = [UINib nibWithNibName:@"APHFitnessTestRestComfortablyView" bundle:nil];
//        APHFitnessTestRestComfortablyView *restComfortablyView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
//
//        [stepViewController.view addSubview:restComfortablyView];
//        
//        //int distanceIntFeet = (int)roundf(self.totalDistance);
//        CLLocationDistance distanceInFeet = [singleEntry[@"totalDistanceInFeet"] doubleValue];
//        
//        if (singleEntry == nil) {
//            distanceInFeet = 0.0;
//        }
//        int distanceAsInt = (int)roundf(distanceInFeet);
//        [restComfortablyView setTotalDistance:[NSNumber numberWithInt:distanceAsInt]];
//        
//        [restComfortablyView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        
//        [restComfortablyView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=280)]" options:0 metrics:nil views:@{@"c":restComfortablyView}]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                                        attribute:NSLayoutAttributeHeight
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:stepVC.view
//                                                                        attribute:NSLayoutAttributeHeight
//                                                                       multiplier:0.5
//                                                                         constant:0]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                                        attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
//                                                                           toItem:stepVC.view
//                                                                        attribute:NSLayoutAttributeCenterY
//                                                                       multiplier:1.15
//                                                                         constant:75]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                                        attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
//                                                                           toItem:stepVC.view
//                                                                        attribute:NSLayoutAttributeWidth
//                                                                       multiplier:1
//                                                                         constant:0]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:stepVC.view
//                                                                        attribute:NSLayoutAttributeCenterX
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:restComfortablyView
//                                                                        attribute:NSLayoutAttributeCenterX
//                                                                       multiplier:1.0
//                                                                         constant:0.0]];
//        
//        
//        [stepVC.view layoutIfNeeded];
//        
//    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep105]) {
//        
//        taskViewController.navigationBar.topItem.title = NSLocalizedString(@"Task Complete", @"Task Complete");
//        
//        //Check if there is a heart rate monitor attached and sending data.
//        APCAppDelegate *appDelegate = (APCAppDelegate*) [[UIApplication sharedApplication] delegate];
//        NSInteger totalUpdates = appDelegate.healthKitTracker.totalUpdates;
//        
//        BOOL heartIsUpdating = NO;
//        
//        if (totalUpdates > kUpdatedHeartRateThreshold) {
//            heartIsUpdating = YES;
//        }
//        
//        if (heartIsUpdating) {
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//            
//            AVSpeechUtterance *utterance = [AVSpeechUtterance
//                                            speechUtteranceWithString:NSLocalizedString(@"You have completed the task.", @"You have completed the task.")];
//            AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
//            utterance.rate = 0.1;
//            [synth speakUtterance:utterance];
//        }
//    }
//}
//
//- (APCStepViewController *)setupInstructionStepWithStep:(RKSTStep *)step
//{
//    APCStepViewController             *controller     = (APCInstructionStepViewController *)[[UIStoryboard storyboardWithName:@"APCInstructionStep"
//                                                                                                                       bundle:[NSBundle appleCoreBundle]] instantiateInitialViewController];
//    APCInstructionStepViewController  *instController = (APCInstructionStepViewController*)controller;
//    
//    instController.imagesArray    = @[ @"6minwalk", @"tutorial-2", @"6minwalk-Icon-1", @"6minwalk-Icon-2", @"illustration_dataanalysis@3x" ];
//    
//    instController.headingsArray  = @[ @"Measure 6-Minute Walk Distance", @"Measure 6-Minute Walk Distance", @"Measure 6-Minute Walk Distance", @"Measure 6-Minute Walk Distance", @"Measure 6-Minute Walk Distance" ];
//    
//    instController.messagesArray  = @[
//                                      @"Once you tap Get Started, you will have 5 seconds until this test begins tracking your movements.",
//                                      @"If you have a wearable device linked to your phone that can track your heart rate, please put it on and make sure it captures your resting heart rate before you start.",
//                                      @"Begin walking at your fastest possible pace for 6 minutes.",
//                                      @"After 6 minutes expires and you are wearing a heart rate sensing device, you will be asked to sit down and rest for 3 minutes.",
//                                      @"After the test is finished, your results will be analyzed and available on the dashboard."
//                                    ];
//    
//    UIButton  *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    CGRect     frame = CGRectMake(0.0, 0.0, 100.0, 27.0);
//    button.frame = frame;
//    
//    button.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [button setTitle:@"View Important Details" forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(viewImportantDetailButtonTapped) forControlEvents:UIControlEventTouchUpInside];
//    
//    instController.accessoryContent = button;
//    
//    controller.delegate = self;
//    controller.step     = step;
//    
//    return  controller;
//}
//
//- (RKSTStepViewController *)taskViewController:(RKSTTaskViewController *)taskViewController viewControllerForStep:(RKSTStep *)step
//{
//    RKSTStepViewController  *controller = nil;
//    
//    if (step.identifier == kFitnessTestStep101) {
//        controller = [self setupInstructionStepWithStep:(RKSTStep *)step];
//    }   else if (step.identifier == kFitnessTestStep105) {
//        
//        APCSimpleTaskSummaryViewController  *simpleTaskSummaryViewController = [[APCSimpleTaskSummaryViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
//        simpleTaskSummaryViewController.taskProgress = 0.25;
//        
//        controller = (RKSTStepViewController *) simpleTaskSummaryViewController;
//        controller.delegate = self;
//        controller.step = step;
//        
//    }
//    return  controller;
//}
//
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
