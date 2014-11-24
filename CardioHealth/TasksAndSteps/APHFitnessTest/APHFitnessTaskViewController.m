//
//  APHFitnessTaskViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTaskViewController.h"


#import "APHFitnessTestIntroStepViewController.h"

#import "APHFitnessTestSummaryViewController.h"

static NSString *MainStudyIdentifier = @"com.cardioVascular.fitnessTest";
static NSString *kdataResultsFileName = @"FitnessTestResult.json";

static  NSString  *kFitnessTestStep101 = @"FitnessStep101";
static  NSString  *kFitnessTestStep102 = @"FitnessStep102";
static  NSString  *kFitnessTestStep103 = @"FitnessStep103";
static  NSString  *kFitnessTestStep104 = @"FitnessStep104";
static  NSString  *kFitnessTestStep105 = @"FitnessStep105";
static  NSString  *kFitnessTestStep106 = @"FitnessStep106";

static NSInteger kCountDownTimer = 1;
static  CGFloat  kAPCStepProgressBarHeight = 12.0;
static CGFloat kAPHFitnessTestMetersToFeetConversion = 3.28084;

@interface APHFitnessTaskViewController ()

@property  (nonatomic, weak)  APCStepProgressBar  *progressor;
@property (strong, nonatomic) APHFitnessTestHealthKitSampleTypeTracker *healthKitSampleTracker;
@property (strong, nonatomic) APHFitnessTestDistanceTracker *distanceTracker;

@property (strong, nonatomic) RKSTDataArchive *taskArchive;

@property (assign) NSInteger heartRateMonitoring;
@property (assign) BOOL heartRateIsUpdating;

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
    
    CGRect  navigationBarFrame = self.navigationBar.frame;
    CGRect  progressorFrame = CGRectMake(0.0, CGRectGetHeight(navigationBarFrame) - kAPCStepProgressBarHeight, CGRectGetWidth(navigationBarFrame), kAPCStepProgressBarHeight);
    
    APCStepProgressBar  *tempProgressor = [[APCStepProgressBar alloc] initWithFrame:progressorFrame style:APCStepProgressBarStyleOnlyProgressView];
    
    RKSTOrderedTask  *task = nil;
    
    if ([self.task isKindOfClass:[RKSTOrderedTask class]]) {
        task =  (RKSTOrderedTask *)self.task;
    }
    
    NSArray  *steps = task.steps;
    tempProgressor.numberOfSteps = [steps count];
    [tempProgressor setCompletedSteps: 1 animation:NO];
    self.progressor.progressTintColor = [UIColor appTertiaryColor1];
    [self.navigationBar addSubview:tempProgressor];
    self.progressor = tempProgressor;
    
    self.showsProgressInNavigationBar = NO;
    
    //sixMinuteStepFlag
    self.finishedSixMinuteStep = NO;
    
    self.stepsToAutomaticallyAdvanceOnTimer = @[kFitnessTestStep102, kFitnessTestStep103, kFitnessTestStep104];
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
#pragma mark - StepViewController Delegate Methods
/*********************************************************************************/

- (void)stepViewControllerDidFinish:(RKSTStepViewController *)stepViewController navigationDirection:(RKSTStepViewControllerNavigationDirection)direction
{
    [super stepViewControllerDidFinish:stepViewController navigationDirection:direction];
    
    if (stepViewController.step.identifier == kFitnessTestStep103) {
        self.finishedSixMinuteStep = YES;
    }
    
    NSInteger  completedSteps = self.progressor.completedSteps;
    if (direction == RKSTStepViewControllerNavigationDirectionForward) {
        completedSteps = completedSteps + 1;
    } else {
        completedSteps = completedSteps - 1;
    }
    [self.progressor setCompletedSteps:completedSteps animation:YES];

    
    NSLog(@"Finished Step: %@", stepViewController.step.identifier);
}

/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/
- (void)taskViewController:(RKSTTaskViewController *)taskViewController willPresentStepViewController:(RKSTStepViewController *)stepViewController{
    
    //If we're not capturing any heart rate data then skip
    if (stepViewController.step.identifier == kFitnessTestStep104) {
        
        if (!self.heartRateIsUpdating) {
            RKSTActiveStep *theStep = (RKSTActiveStep *)stepViewController.step;
            
            theStep.spokenInstruction = nil;
            [stepViewController goForward];
        }
    }
    
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
    
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep103]) {
        
        RKSTActiveStepViewController *stepVC = (RKSTActiveStepViewController *) stepViewController;
        
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
//        [stepVC.view addSubview:countdownTitle];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:stepVC.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
//
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:stepVC.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:stepVC.view attribute:NSLayoutAttributeCenterY multiplier:0.47f constant:5.0f]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle
//                                                                attribute:NSLayoutAttributeCenterX
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:stepVC.view
//                                                                attribute:NSLayoutAttributeCenterX
//                                                               multiplier:1.0
//                                                                 constant:0.0]];
//        
//        //Adding custom view which includes the distance and BPM.
//        UIView *updatedView = [UIView new];
//        
//        [stepVC setCustomView:updatedView];
//        
//        // Height constraint
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:updatedView
//                                                                attribute:NSLayoutAttributeHeight
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:stepVC.view
//                                                                attribute:NSLayoutAttributeHeight
//                                                               multiplier:0.3
//                                                                 constant:0]];
//        
//        
//        /**** use for setting custom views. **/
//        UINib *nib = [UINib nibWithNibName:@"APHFitnessSixMinuteFitnessTestView" bundle:nil];
//        APHFitnessSixMinuteFitnessTestView *restComfortablyView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
//        
//        [stepVC.view addSubview:restComfortablyView];
//        
//        [restComfortablyView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        
//        [restComfortablyView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=280)]" options:0 metrics:nil views:@{@"c":restComfortablyView}]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                                attribute:NSLayoutAttributeHeight
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:stepVC.view
//                                                                attribute:NSLayoutAttributeHeight
//                                                               multiplier:0.5
//                                                                 constant:0]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                                attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
//                                                                   toItem:stepViewController.view
//                                                                attribute:NSLayoutAttributeCenterY
//                                                               multiplier:1.15
//                                                                 constant:75]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                                attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
//                                                                   toItem:stepViewController.view
//                                                                attribute:NSLayoutAttributeWidth
//                                                               multiplier:1
//                                                                 constant:0]];
//        
//        // Center horizontally
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:stepVC.view
//                                                                attribute:NSLayoutAttributeCenterX
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:restComfortablyView
//                                                                attribute:NSLayoutAttributeCenterX
//                                                               multiplier:1.0
//                                                                 constant:0.0]];
//        
//        [stepVC.view layoutIfNeeded];

        
        stepViewController.continueButton = nil;
        stepViewController.skipButton = nil;
        
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep104]) {

        RKSTActiveStepViewController *stepVC = (RKSTActiveStepViewController *) stepViewController;
        
        
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
//        [stepVC.view addSubview:countdownTitle];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:stepVC.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:stepVC.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:stepVC.view attribute:NSLayoutAttributeCenterY multiplier:0.47f constant:5.0f]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle
//                                                                attribute:NSLayoutAttributeCenterX
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:stepVC.view
//                                                                attribute:NSLayoutAttributeCenterX
//                                                               multiplier:1.0
//                                                                 constant:0.0]];
//        
//        //Adding custom view which includes the distance and BPM.
//        UIView *updatedView = [UIView new];
//        
//        [stepVC setCustomView:updatedView];
//        
//        // Height constraint
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:updatedView
//                                                                attribute:NSLayoutAttributeHeight
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:stepVC.view
//                                                                attribute:NSLayoutAttributeHeight
//                                                               multiplier:0.3
//                                                                 constant:0]];
//
//        
//        /**** use for setting custom views. **/
//        UINib *nib = [UINib nibWithNibName:@"APHFitnessTestRestComfortablyView" bundle:nil];
//        APHFitnessTestRestComfortablyView *restComfortablyView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
//        
//        [stepVC.view addSubview:restComfortablyView];
//        
//        CLLocationDistance distanceInFeet = self.totalDistance * kAPHFitnessTestMetersToFeetConversion;
//        
//        [NSString stringWithFormat:@"%dft", (int)roundf(distanceInFeet)];
//        
//        [restComfortablyView setTotalDistance:[NSNumber numberWithInt:(int)roundf(distanceInFeet)]];
//        
//        [restComfortablyView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        
//        [restComfortablyView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=280)]" options:0 metrics:nil views:@{@"c":restComfortablyView}]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                                attribute:NSLayoutAttributeHeight
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:stepVC.view
//                                                                attribute:NSLayoutAttributeHeight
//                                                               multiplier:0.5
//                                                                 constant:0]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                                attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
//                                                                   toItem:stepViewController.view
//                                                                attribute:NSLayoutAttributeCenterY
//                                                               multiplier:1.15
//                                                                 constant:75]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                                attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
//                                                                   toItem:stepViewController.view
//                                                                attribute:NSLayoutAttributeWidth
//                                                               multiplier:1
//                                                                 constant:0]];
//        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:stepVC.view
//                                                              attribute:NSLayoutAttributeCenterX
//                                                              relatedBy:NSLayoutRelationEqual
//                                                                 toItem:restComfortablyView
//                                                              attribute:NSLayoutAttributeCenterX
//                                                             multiplier:1.0
//                                                               constant:0.0]];
//        
//        
//        [stepVC.view layoutIfNeeded];
        
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

- (void)taskViewControllerDidFail: (RKSTTaskViewController *)taskViewController withError:(NSError*)error{
    
    [self.taskArchive resetContent];
    self.taskArchive = nil;
    
}

- (void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController{
    
    [taskViewController suspend];
    
    [self.taskArchive resetContent];
    self.taskArchive = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (RKSTStepViewController *)taskViewController:(RKSTTaskViewController *)taskViewController viewControllerForStep:(RKSTStep *)step
{
    RKSTStepViewController *stepVC = nil;
    
    if (step.identifier == kFitnessTestStep101) {
        NSDictionary  *controllers = @{ kFitnessTestStep101 : [APHFitnessTestIntroStepViewController class] };
        
        Class  aClass = [controllers objectForKey:step.identifier];
        APCStepViewController  *controller = [[aClass alloc] initWithNibName:nil bundle:nil];
        controller.delegate = self;
        controller.title = @"Interval Tapping";
        controller.step = step;
        
        stepVC = controller;
    }   else if (step.identifier == kFitnessTestStep106) {
        
        APHFitnessTestSummaryViewController *summaryViewController = [[APHFitnessTestSummaryViewController alloc] initWithNibName:@"APHFitnessTestSummaryViewController" bundle:nil];
        
        summaryViewController.delegate = self;
        summaryViewController.step = step;
        summaryViewController.taskProgress = 0.25;
        
        stepVC = summaryViewController;
    }
    
    return stepVC;
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
