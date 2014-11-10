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
static NSInteger kCountDownTimer = 5;
static  NSString  *kFitnessTestStep101 = @"FitnessStep101";
static  NSString  *kFitnessTestStep102 = @"FitnessStep102";
static  NSString  *kFitnessTestStep103 = @"FitnessStep103";
static  NSString  *kFitnessTestStep104 = @"FitnessStep104";
static  NSString  *kFitnessTestStep105 = @"FitnessStep105";
static  NSString  *kFitnessTestStep106 = @"FitnessStep106";

static  CGFloat  kAPCStepProgressBarHeight = 8.0;

@interface APHFitnessTaskViewController ()

@property  (nonatomic, weak)  APCStepProgressBar  *progressor;
@property (strong, nonatomic) APHFitnessTestHealthKitSampleTypeTracker *healthKitSampleTracker;
@property (strong, nonatomic) APHFitnessTestDistanceTracker *distanceTracker;

@property (strong, nonatomic) RKDataArchive *taskArchive;

@property (assign) NSInteger heartRateMonitoring;
@property (assign) BOOL heartRateIsUpdating;

@property (strong, nonatomic) NSData *lastDataResult;

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
    
    RKTask  *task = self.task;
    NSArray  *steps = task.steps;
    tempProgressor.numberOfSteps = [steps count];
    [tempProgressor setCompletedSteps: 1 animation:NO];
    self.progressor.progressTintColor = [UIColor appTertiaryColor1];
    [self.navigationBar addSubview:tempProgressor];
    self.progressor = tempProgressor;
    
    self.showsProgressInNavigationBar = NO;
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
        RKIntroductionStep *step = [[RKIntroductionStep alloc] initWithIdentifier:kFitnessTestStep101 name:@"Tap Intro"];
        step.caption = NSLocalizedString(@"Measure Excercise Tolerance", @"");
        step.instruction = NSLocalizedString(@"Once you tap Get Started, you will have 5 seconds until this test begins tracking your movement.", @"");
        [steps addObject:step];
    }
    
    {
        //Introduction to fitness test
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kFitnessTestStep102 name:@"active step"];
        step.caption = NSLocalizedString(@"Fitness Test", @"");
        step.text = NSLocalizedString(@"Get Ready!", @"");
        step.countDown = kCountDownTimer;
        step.useNextForSkip = NO;
        step.buzz = YES;
        step.speakCountDown = YES;
        
        [steps addObject:step];
    }
    
    
    {
        //Walking 6 minutes
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kFitnessTestStep103 name:@"6 Minute Walk"];
        step.recorderConfigurations = @[[APHFitnessTestCustomRecorderConfiguration new]];
        step.caption = NSLocalizedString(@"Start Walking", @"");
        step.text = NSLocalizedString(@"Start Walking", @"");
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
        step.caption = NSLocalizedString(@"Good Work!", @"");
        step.text = NSLocalizedString(@"Stop walking, and sit in a comfortable position for 3 minutes.", @"");
        step.buzz = YES;
        step.vibration = YES;
        step.voicePrompt = step.text;
        step.countDown = [[parameters numberForKey:@"FT3MinComfPos"] doubleValue];
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

- (void)beginTask
{
    if (self.taskArchive)
    {
        [self.taskArchive resetContent];
    }
    
    self.taskArchive = [[RKDataArchive alloc] initWithItemIdentifier:[RKItemIdentifier itemIdentifierForTask:self.task] studyIdentifier:MainStudyIdentifier taskInstanceUUID:self.taskInstanceUUID extraMetadata:nil fileProtection:RKFileProtectionCompleteUnlessOpen];
    
}

/*********************************************************************************/
#pragma mark - StepViewController Delegate Methods
/*********************************************************************************/

- (void)stepViewControllerDidFinish:(RKStepViewController *)stepViewController navigationDirection:(RKStepViewControllerNavigationDirection)direction
{
    [super stepViewControllerDidFinish:stepViewController navigationDirection:direction];
    
    NSInteger  completedSteps = self.progressor.completedSteps;
    if (direction == RKStepViewControllerNavigationDirectionForward) {
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
- (void)taskViewController:(RKTaskViewController *)taskViewController willPresentStepViewController:(RKStepViewController *)stepViewController{
    
    //If we're not capturing any heart rate data then skip
    if (stepViewController.step.identifier == kFitnessTestStep104) {
        
        if (!self.heartRateIsUpdating) {
            RKActiveStep *theStep = (RKActiveStep *)stepViewController.step;
            
            theStep.voicePrompt = nil;
            [stepViewController goToNextStep];
        }
    }
    
    taskViewController.navigationBar.topItem.title = NSLocalizedString(@"6 Minute Walk", @"6 Minute Walk");
    
    stepViewController = (RKStepViewController *) stepViewController;
    
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
        
        [(RKActiveStepViewController*)stepViewController setCustomView:customView];
        
        stepViewController.continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Get Started" style:stepViewController.continueButton.style target:stepViewController.continueButton.target action:stepViewController.continueButton.action];
        
        stepViewController.skipButton = nil;
        
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep102]) {
    
        stepViewController.continueButton = nil;
        stepViewController.skipButton = nil;
    
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep103]) {
        
        RKActiveStepViewController *stepVC = (RKActiveStepViewController *) stepViewController;
        
        UIView *updatedView = [UIView new];
        
        [stepVC setCustomView:updatedView];
        
        // Height constraint
        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:updatedView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:stepVC.view
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:0.3
                                                                 constant:0]];
        
        
        /**** use for setting custom views. **/
        UINib *nib = [UINib nibWithNibName:@"APHFitnessSixMinuteFitnessTestView" bundle:nil];
        APHFitnessSixMinuteFitnessTestView *restComfortablyView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
        
        [stepVC.view addSubview:restComfortablyView];
        
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
                                                                   toItem:stepViewController.view
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.15
                                                                 constant:75]];
        
        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
                                                                attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                   toItem:stepViewController.view
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1
                                                                 constant:0]];
        
        // Center horizontally
        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:stepVC.view
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:restComfortablyView
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0]];
        
        [stepVC.view layoutIfNeeded];

        
        stepViewController.continueButton = nil;
        stepViewController.skipButton = nil;
        
    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep104]) {

        RKActiveStepViewController *stepVC = (RKActiveStepViewController *) stepViewController;
        
        UIView *updatedView = [UIView new];
        
        [stepVC setCustomView:updatedView];
        
        // Height constraint
        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:updatedView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:stepVC.view
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:0.3
                                                                 constant:0]];

        
        /**** use for setting custom views. **/
        UINib *nib = [UINib nibWithNibName:@"APHFitnessTestRestComfortablyView" bundle:nil];
        APHFitnessTestRestComfortablyView *restComfortablyView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
        
        [stepVC.view addSubview:restComfortablyView];
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:self.lastDataResult
                                                             options:kNilOptions
                                                               error:&error];
        
        NSArray* distances = [json objectForKey:@"distance"];
        
        NSDictionary *lastObject = [distances lastObject];
        
        [restComfortablyView setTotalDistance:[NSNumber numberWithInteger:[lastObject[@"totalDistanceInFeet"] integerValue]]];
        
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
                                                                   toItem:stepViewController.view
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.15
                                                                 constant:75]];
        
        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
                                                                attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                   toItem:stepViewController.view
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1
                                                                 constant:0]];
        
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:stepViewController.view attribute:NSLayoutAttributeBottom multiplier:0.95 constant:2]];
        
        //Notes
        /*
         Multipliers are pretty amazing.
         
         Strategy to center horizontally with constantsa and multipliers.
         */
        
        
        
        // Center horizontally
        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:stepVC.view
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:restComfortablyView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        // Center vertically
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                              attribute:NSLayoutAttributeCenterY
//                                                              relatedBy:NSLayoutRelationEqual
//                                                                 toItem:stepVC.view
//                                                              attribute:NSLayoutAttributeCenterY
//                                                             multiplier:1.0
//                                                               constant:0.0]];

        
        /**** set margin between custom view and rest view **/
//        [stepVC.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:updatedView attribute:NSLayoutAttributeTop multiplier:1 constant:-100]];
        
        
        
        [stepVC.view layoutIfNeeded];
        
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

- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKDataResult *)result {

    NSLog(@"didProduceResult = %@", result.data);
    self.lastDataResult = result.data;
    
    if ([result isKindOfClass:[RKSurveyResult class]]) {
        RKSurveyResult* sresult = (RKSurveyResult*)result;
        
        for (RKQuestionResult* qr in sresult.surveyResults) {
            NSLog(@"%@ = [%@] %@ ", [[qr itemIdentifier] stringValue], [qr.answer class], qr.answer);
        }
    }

    [super taskViewController:taskViewController didProduceResult:result];
}

- (void)taskViewControllerDidFail: (RKTaskViewController *)taskViewController withError:(NSError*)error{
    
    [self.taskArchive resetContent];
    self.taskArchive = nil;
    
}

- (void)taskViewControllerDidCancel:(RKTaskViewController *)taskViewController{
    
    [taskViewController suspend];
    
    [self.taskArchive resetContent];
    self.taskArchive = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewControllerDidComplete: (RKTaskViewController *)taskViewController
{
    NSFetchRequest * request = [APCResult request];
    request.predicate = [NSPredicate predicateWithFormat:@"scheduledTask == %@ AND rkTaskInstanceUUID == %@", self.scheduledTask, self.taskInstanceUUID.UUIDString];

    APCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSArray * results = [appDelegate.dataSubstrate.mainContext executeFetchRequest:request error:NULL];
    
    RKStep * dummyStep = [[RKStep alloc] initWithIdentifier:@"Dummy" name:@"name"];
    RKDataResult * result = [[RKDataResult alloc] initWithStep:dummyStep];
    result.filename = kdataResultsFileName;
    result.contentType = @"application/json";
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    [results enumerateObjectsUsingBlock:^(APCDataResult * result, NSUInteger idx, BOOL *stop) {
        dictionary[result.rkItemIdentifier] = [NSJSONSerialization JSONObjectWithData:result.data options:0 error:NULL];
    }];

    
    NSMutableDictionary *wrapperDictionary = [NSMutableDictionary dictionary];
    wrapperDictionary[@"fitnessTest"] = dictionary;
    
    result.data = [NSJSONSerialization dataWithJSONObject:wrapperDictionary options:(NSJSONWritingOptions)0 error:NULL];
    [result addToArchive:self.taskArchive error:NULL];
    
    NSError *err = nil;
    NSURL *archiveFileURL = [self.taskArchive archiveURLWithError:&err];
    if (archiveFileURL)
    {
        NSURL *documents = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        NSURL *outputUrl = [documents URLByAppendingPathComponent:[archiveFileURL lastPathComponent]];
        
        // This is where you would queue the archive for upload. In this demo, we move it
        // to the documents directory, where you could copy it off using iTunes, for instance.
        [[NSFileManager defaultManager] moveItemAtURL:archiveFileURL toURL:outputUrl error:nil];
        
        NSLog(@"outputUrl= %@", outputUrl);
        
        // When done, clean up:
        self.taskArchive = nil;
        if (archiveFileURL)
        {
            [[NSFileManager defaultManager] removeItemAtURL:archiveFileURL error:nil];
        }
    }
    
    [super taskViewControllerDidComplete:taskViewController];
}

- (RKStepViewController *)taskViewController:(RKTaskViewController *)taskViewController viewControllerForStep:(RKStep *)step
{
    RKStepViewController *stepVC = nil;
    
    if (step.identifier == kFitnessTestStep101) {
        NSDictionary  *controllers = @{ kFitnessTestStep101 : [APHFitnessTestIntroStepViewController class] };
        
        Class  aClass = [controllers objectForKey:step.identifier];
        APCStepViewController  *controller = [[aClass alloc] initWithNibName:nil bundle:nil];
        controller.resultCollector = self;
        controller.delegate = self;
        controller.title = @"Interval Tapping";
        controller.step = step;
        
        stepVC = controller;
    }   else if (step.identifier == kFitnessTestStep106) {
        
        APHFitnessTestSummaryViewController *summaryViewController = [[APHFitnessTestSummaryViewController alloc] initWithNibName:@"APHFitnessTestSummaryViewController" bundle:nil];
        
        summaryViewController.resultCollector = self;
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

-(void)sendCompleteResult:(RKDataResult*)result
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

-(void)sendResult:(RKDataResult*)result
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
