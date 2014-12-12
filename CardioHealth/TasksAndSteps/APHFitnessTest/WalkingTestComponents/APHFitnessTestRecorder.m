// 
//  APHFitnessTestRecorder.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHFitnessTestRecorder.h"
#import "APHFitnessTestRestComfortablyView.h"
#import "APHFitnessSixMinuteFitnessTestView.h"
#import <CoreLocation/CoreLocation.h>


static CGFloat kAPHFitnessTestMetersToFeetConversion = 3.28084;

static  NSString  *kFitnessTestStep101 = @"FitnessStep101";
static  NSString  *kFitnessTestStep102 = @"FitnessStep102";
static  NSString  *kFitnessTestStep103 = @"FitnessStep103";
static  NSString  *kFitnessTestStep104 = @"FitnessStep104";
static  NSString  *kFitnessTestStep105 = @"FitnessStep105";
static  NSString  *kFitnessTestStep106 = @"FitnessStep106";

@interface APHFitnessTestRecorder ()
@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, strong) NSMutableDictionary* dictionaryRecord;
@property (nonatomic, strong) NSMutableArray* distanceRecords;
@property (nonatomic, strong) NSMutableArray* heartRateRecords;
@property (nonatomic, strong) NSMutableArray* stepCountRecords;
@property (strong, nonatomic) CLLocation *previousLocation;
@property (strong, nonatomic) APHFitnessSixMinuteFitnessTestView *restComfortablyView;
@property (assign) CLLocationDistance totalDistance;
@end
@implementation APHFitnessTestRecorder


/*********************************************************************************/
#pragma mark - System methods
/*********************************************************************************/

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"APHFitnessHeartRateBPMUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"APHFitnessStepCountUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"APHFitnessDistanceUpdated" object:nil];
}

/*********************************************************************************/
#pragma mark - Delegate methods
/*********************************************************************************/
- (void)viewController:(UIViewController*)viewController willStartStepWithView:(UIView*)view{
    [super viewController:viewController willStartStepWithView:view];
    
    self.containerView = view;
   
    //If the step collects distance
    if (self.step.identifier == kFitnessTestStep103) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveUpdatedLocationNotification:)
                                                     name:@"APHFitnessDistanceUpdated"
                                                   object:nil];
        
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
        
        [viewController.view addSubview:countdownTitle];
        
        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
        
        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
        
        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeCenterY multiplier:0.47f constant:5.0f]];
        
        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:viewController.view
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0]];
        
        //Adding custom view which includes the distance and BPM.
        UIView *updatedView = [UIView new];
        
        RKSTActiveStepViewController *stepVC = (RKSTActiveStepViewController *)viewController;
        [stepVC setCustomView:updatedView];
        
        // Height constraint
        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:updatedView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:viewController.view
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:0.15
                                                                 constant:0]];
        
        
        /**** use for setting custom views. **/
        UINib *nib = [UINib nibWithNibName:@"APHFitnessSixMinuteFitnessTestView" bundle:nil];
        self.restComfortablyView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
        
        [viewController.view addSubview:self.restComfortablyView];
        
        [self.restComfortablyView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.restComfortablyView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=280)]" options:0 metrics:nil views:@{@"c":self.restComfortablyView}]];
        
        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.restComfortablyView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:viewController.view
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:0.5
                                                                 constant:0]];
        
        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.restComfortablyView
                                                                attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                                   toItem:viewController.view
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.15
                                                                 constant:75]];
        
        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.restComfortablyView
                                                                attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                   toItem:viewController.view
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1
                                                                 constant:0]];
        
        // Center horizontally
        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.restComfortablyView
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0]];
        
        [viewController.view layoutIfNeeded];
        
    } else if (self.step.identifier == kFitnessTestStep104) {

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
//        [viewController.view addSubview:countdownTitle];
//        
//        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
//        
//        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
//        
//        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeCenterY multiplier:0.47f constant:5.0f]];
//        
//        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:countdownTitle
//                                                                attribute:NSLayoutAttributeCenterX
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:viewController.view
//                                                                attribute:NSLayoutAttributeCenterX
//                                                               multiplier:1.0
//                                                                 constant:0.0]];
//        
//        //Adding custom view which includes the distance and BPM.
//        UIView *updatedView = [UIView new];
//        
//        
//        RKSTActiveStepViewController *stepVC = (RKSTActiveStepViewController *)viewController;
//        [stepVC setCustomView:updatedView];
//        
//        // Height constraint
//        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:updatedView
//                                                                attribute:NSLayoutAttributeHeight
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:viewController.view
//                                                                attribute:NSLayoutAttributeHeight
//                                                               multiplier:0.15
//                                                                 constant:0]];
//        
//        
//        /**** use for setting custom views. **/
//        UINib *nib = [UINib nibWithNibName:@"APHFitnessTestRestComfortablyView" bundle:nil];
//        APHFitnessTestRestComfortablyView *restComfortablyView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
//        
//        [viewController.view addSubview:restComfortablyView];
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
//        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                                attribute:NSLayoutAttributeHeight
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:viewController.view
//                                                                attribute:NSLayoutAttributeHeight
//                                                               multiplier:0.5
//                                                                 constant:0]];
//        
//        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                                attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
//                                                                   toItem:viewController.view
//                                                                attribute:NSLayoutAttributeCenterY
//                                                               multiplier:1.15
//                                                                 constant:75]];
//        
//        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:restComfortablyView
//                                                                attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
//                                                                   toItem:viewController.view
//                                                                attribute:NSLayoutAttributeWidth
//                                                               multiplier:1
//                                                                 constant:0]];
//        
//        [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view
//                                                                attribute:NSLayoutAttributeCenterX
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:restComfortablyView
//                                                                attribute:NSLayoutAttributeCenterX
//                                                               multiplier:1.0
//                                                                 constant:0.0]];
//        
//        
//        [viewController.view layoutIfNeeded];


    
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveHeartBPMNotification:)
                                                 name:@"APHFitnessHeartRateBPMUpdated"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveStepCountNotification:)
                                                 name:@"APHFitnessStepCountUpdated"
                                               object:nil];
    
    //Initialize the collectors.
    self.dictionaryRecord = [NSMutableDictionary new];
    self.distanceRecords = [NSMutableArray array];
    self.heartRateRecords = [NSMutableArray array];
    self.stepCountRecords = [NSMutableArray array];

}

/*********************************************************************************/
#pragma mark - Private methods
/*********************************************************************************/

- (void)timerFired:(id)sender {
    
//    self.timer;
}

/*********************************************************************************/
#pragma mark - NSNotification Methods
/*********************************************************************************/
- (void)receiveHeartBPMNotification:(NSNotification *)notification {
    NSMutableDictionary *heartBeatInfo = [notification.userInfo mutableCopy];
    
    [self.heartRateRecords addObject:heartBeatInfo];
}

- (void)receiveStepCountNotification:(NSNotification *)notification {
    NSMutableDictionary *stepCountInfo = [notification.userInfo mutableCopy];
    
    [self.stepCountRecords addObject:stepCountInfo];
}

- (void)receiveUpdatedLocationNotification:(NSNotification *)notification {
    NSMutableDictionary *distanceUpdatedInfo = [notification.userInfo mutableCopy];
    
    CLLocationDegrees latitude = [[distanceUpdatedInfo objectForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude = [[distanceUpdatedInfo objectForKey:@"longitude"] doubleValue];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    if (!self.previousLocation) {
        
        self.previousLocation = location;
    } else {
        
        CLLocationDistance distance = [self.previousLocation distanceFromLocation:location];
        
        self.totalDistance += distance;
        
        CLLocationDistance distanceInFeet = self.totalDistance * kAPHFitnessTestMetersToFeetConversion;
        
        distanceUpdatedInfo[@"totalDistanceInFeet"] = @(distanceInFeet);
        int distanceAsInt = (int)roundf(distanceInFeet);
        
        self.restComfortablyView.distanceTotalLabel.text = [NSString stringWithFormat:@"%dft", distanceAsInt];
        [self.distanceRecords addObject:distanceUpdatedInfo];
        self.previousLocation = location;
    }
    
}


/*********************************************************************************/
#pragma mark - Overriding Methods
/*********************************************************************************/
//Start begins whenever the timer starts in the step view controller

- (void)stop
{
    //If the step collects distance
    if (self.step.identifier == kFitnessTestStep103) {
        self.dictionaryRecord[@"distance"] = self.distanceRecords;
    }
    
    self.dictionaryRecord[@"heartRateBPM"] = self.heartRateRecords;
    self.dictionaryRecord[@"stepCount"] = self.stepCountRecords;
    
    id<RKSTRecorderDelegate> localDelegate = self.delegate;
    
    if (self.dictionaryRecord) {
        if (localDelegate && [localDelegate respondsToSelector:@selector(recorder:didCompleteWithResult:)]) {
            RKSTDataResult* result = [[RKSTDataResult alloc] initWithIdentifier:self.step.identifier];
            result.contentType = [self mimeType];
            
            NSError  *serializationError = nil;
            result.data = [NSJSONSerialization dataWithJSONObject:self.dictionaryRecord options:(NSJSONWritingOptions)0 error:&serializationError];
            
            if (serializationError != nil) {
                if (localDelegate != nil && [localDelegate respondsToSelector:@selector(recorder:didFailWithError:)]) {
                    [localDelegate recorder:self didFailWithError:serializationError];
                }
            } else {
                result.filename = self.fileName;
                [localDelegate recorder:self didCompleteWithResult:result];
                self.dictionaryRecord = nil;
            }
        }
    } else {
        
        if (localDelegate != nil && [localDelegate respondsToSelector:@selector(recorder:didFailWithError:)]) {
            NSError  *error = [NSError errorWithDomain:@"Application Internal Error"
                                          code:999
                                      userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"APHFitnessTestRecorder has no recorded data", @"") }
                               ];
            [localDelegate recorder:self didFailWithError:error];
        }
    }
    
    [super stop];
}



- (NSString*)dataType{
    return @"fitnessTest";
}

- (NSString*)mimeType{
    return @"application/json";
}

- (NSString*)fileName{

    NSString *filesName;
    
    if (self.step.identifier == kFitnessTestStep103) {
     
        filesName = @"6MinuteFitnessTest";
    } else if (self.step.identifier == kFitnessTestStep104) {
        
        filesName = @"3MinuteComfortablePosition";
    } else if (self.step.identifier == kFitnessTestStep105) {
        
        filesName = @"3MinuteRest";
    }
    return filesName;
}

@end
/*********************************************************************************/
/*********************************************************************************/
/*********************************************************************************/
#pragma mark - implementation APHFitnessTestCustomRecorderConfiguration
/*********************************************************************************/

@implementation APHFitnessTestCustomRecorderConfiguration

- (RKSTRecorder *)recorderForStep:(RKSTStep *)step outputDirectory:(NSURL *)outputDirectory
{
    return [[APHFitnessTestRecorder alloc] initWithStep:step outputDirectory:nil];
}

@end


