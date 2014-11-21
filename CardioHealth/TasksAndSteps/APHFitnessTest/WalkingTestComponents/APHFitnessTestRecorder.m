//
//  APHFitnessTestRecorder.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
        
//        UINib *nib = [UINib nibWithNibName:@"APHFitnessSixMinuteFitnessTestView" bundle:nil];
//        APHFitnessSixMinuteFitnessTestView *updatedView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
//        [updatedView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        
//        RKSTActiveStepViewController * stepViewController = (RKSTActiveStepViewController *)viewController;
//        
//        UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 280, 560.00)];
//        [blankView addSubview: updatedView];
//  
//        [stepViewController setCustomView:blankView];
//        [stepViewController.customView setBackgroundColor:[UIColor greenColor]];
//        //[stepViewController.customView addSubview: updatedView];
//        
//        NSDictionary *viewsDictionary = @{@"c": updatedView, @"container" : stepViewController.customView };
//        
//        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[c(>=200)]" options:0 metrics:nil views:@{@"c":updatedView}];
//        
//        for (NSLayoutConstraint *constraint in verticalConstraints) {
//            constraint.priority = UILayoutPriorityFittingSizeLevel;
//        }
//        
//        [updatedView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=280)]" options:0 metrics:nil views:@{@"c":updatedView, @"container" : stepViewController}]];
//        
//        [updatedView addConstraints:verticalConstraints];
//        
//        
//        NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[c]"
//                                                                            options:0
//                                                                            metrics:nil
//                                                                              views:viewsDictionary];
//        
//        NSArray *constraint_POS_V2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[c]-0-|"
//                                                                            options:0
//                                                                            metrics:nil
//                                                                              views:viewsDictionary];
//        
//        NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[c]"
//                                                                            options:0
//                                                                            metrics:nil
//                                                                              views:viewsDictionary];
//        
//        NSArray *constraint_POS_H2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[c]-0-|"
//                                                                            options:0
//                                                                            metrics:nil
//                                                                              views:viewsDictionary];
//        
//        [stepViewController.customView addConstraints:constraint_POS_H];
//        [stepViewController.customView addConstraints:constraint_POS_H2];
//        [stepViewController.customView addConstraints:constraint_POS_V];
//        [stepViewController.customView addConstraints:constraint_POS_V2];
        

/*********************************************************************************/
        
    } else {

//        UINib *nib = [UINib nibWithNibName:@"APHFitnessTestRestComfortablyView" bundle:nil];
//        APHFitnessTestRestComfortablyView *updatedView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
//        [updatedView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
//        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[c(>=160)]" options:0 metrics:nil views:@{@"c":updatedView}];
//        
//        for (NSLayoutConstraint *constraint in verticalConstraints) {
//            constraint.priority = UILayoutPriorityFittingSizeLevel;
//        }
//        
//        [updatedView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=280)]" options:0 metrics:nil views:@{@"c":updatedView}]];
//        
//        [updatedView addConstraints:verticalConstraints];
//        
//        [(RKSTActiveStepViewController *)viewController setCustomView:updatedView];
        
        
        
//        UINib *nib = [UINib nibWithNibName:@"APHFitnessTestRestComfortablyView" bundle:nil];
//        APHFitnessTestRestComfortablyView *updatedView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
//        [updatedView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        
//        RKSTActiveStepViewController * stepViewController = (RKSTActiveStepViewController *)viewController;
//        
//        UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 280, 560.00)];
//        [blankView addSubview: updatedView];
//        
//        [stepViewController setCustomView:blankView];
//        [stepViewController.customView setBackgroundColor:[UIColor greenColor]];
//        //[stepViewController.customView addSubview: updatedView];
//        
//        NSDictionary *viewsDictionary = @{@"c": updatedView, @"container" : stepViewController.customView };
//        
//        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[c(>=160)]" options:0 metrics:nil views:@{@"c":updatedView}];
//        
//        for (NSLayoutConstraint *constraint in verticalConstraints) {
//            constraint.priority = UILayoutPriorityFittingSizeLevel;
//        }
//        
//        [updatedView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=280)]" options:0 metrics:nil views:@{@"c":updatedView, @"container" : stepViewController}]];
//        
//        [updatedView addConstraints:verticalConstraints];
//        
//        
//        NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[c]"
//                                                                            options:0
//                                                                            metrics:nil
//                                                                              views:viewsDictionary];
//        
//        NSArray *constraint_POS_V2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[c]-0-|"
//                                                                             options:0
//                                                                             metrics:nil
//                                                                               views:viewsDictionary];
//        
//        NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[c]"
//                                                                            options:0
//                                                                            metrics:nil
//                                                                              views:viewsDictionary];
//        
//        NSArray *constraint_POS_H2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[c]-0-|"
//                                                                             options:0
//                                                                             metrics:nil
//                                                                               views:viewsDictionary];
//        
//        [stepViewController.customView addConstraints:constraint_POS_H];
//        [stepViewController.customView addConstraints:constraint_POS_H2];
//        [stepViewController.customView addConstraints:constraint_POS_V];
//        [stepViewController.customView addConstraints:constraint_POS_V2];

    
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
        
        [self.distanceRecords addObject:distanceUpdatedInfo];
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
    
    if (self.dictionaryRecord) {
        
        NSLog(@"%@", self.dictionaryRecord);
        
        id<RKSTRecorderDelegate> localDelegate = self.delegate;
        if (localDelegate && [localDelegate respondsToSelector:@selector(recorder:didCompleteWithResult:)]) {
            RKSTDataResult* result = [[RKSTDataResult alloc] initWithIdentifier:self.step.identifier];
            result.contentType = [self mimeType];
            NSError* err;
            result.data = [NSJSONSerialization dataWithJSONObject:self.dictionaryRecord options:(NSJSONWritingOptions)0 error:&err];
            
            if (err) {
                
            }
            
            result.filename = self.fileName;
            [localDelegate recorder:self didCompleteWithResult:result];
            self.dictionaryRecord = nil;
        }
    }else{
        
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

- (RKSTRecorder*)recorderForStep:(RKSTStep*)step taskInstanceUUID:(NSUUID*)taskInstanceUUID{
    
    //TODO: For Dhanush
    return [[APHFitnessTestRecorder alloc] initWithStep:step outputDirectory:nil];
}

@end


