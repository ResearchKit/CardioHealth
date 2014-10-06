//
//  APHFitnessTestRecorder.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTestRecorder.h"

static CGFloat kAPHFitnessTestMetersToMilesConversion = 1609.34;
@interface APHFitnessTestRecorder ()
@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, strong) UIButton* button;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) NSMutableArray* records;
@property (nonatomic, strong) NSMutableDictionary* dictionaryRecord;
@property (nonatomic, strong) NSMutableArray* distanceRecords;
@property (nonatomic, strong) NSMutableArray* heartRateRecords;
@property (nonatomic, strong) NSMutableArray* stepCountRecords;


@property (strong, nonatomic) APHFitnessTestDistanceTracker *distanceTracker;
@property (strong, nonatomic) APHFitnessTestHealthKitSampleTypeTracker *healthKitSampleTypeTracker;
@property (strong, nonatomic) APHTimer *countDownTimer;
@end
@implementation APHFitnessTestRecorder

- (void)viewController:(UIViewController*)viewController willStartStepWithView:(UIView*)view{
    [super viewController:viewController willStartStepWithView:view];
    self.containerView = view;
    
    //setup distance tracker
    self.distanceTracker = [[APHFitnessTestDistanceTracker alloc] init];
    [self.distanceTracker setDelegate:self];
    [self.distanceTracker prepLocationUpdates];
    
    //setup heart rate tracker
    self.healthKitSampleTypeTracker = [[APHFitnessTestHealthKitSampleTypeTracker alloc] init];
    [self.healthKitSampleTypeTracker setDelegate:self];
    [self.healthKitSampleTypeTracker startUpdating];
    
    //Prepare records for recording
    self.records = [NSMutableArray array];
    
    self.dictionaryRecord = [NSMutableDictionary new];
    self.distanceRecords = [NSMutableArray array];
    self.heartRateRecords = [NSMutableArray array];
    self.stepCountRecords = [NSMutableArray array];
}

//Start begins whenever the timer starts in the step view controller
- (BOOL)start:(NSError *__autoreleasing *)error{
    BOOL didStart = [super start:error];
    
    //Start tracking distance. Logging data occurs in the delegate methods where the data is being returned.
    [self.distanceTracker start];
    
    return didStart;
}


//{
//    "distance": [
//                 {
//                     "timestamp": 123,
//                     "location": 123
//                 },
//                 {
//                     "timestamp": 123,
//                     "location": 123
//                 }
//                 ],
//    "heartRate": [
//                  {
//                      "timestamp": 123,
//                      "heartRate": 123
//                  },
//                  {
//                      "timestamp": 123,
//                      heartRate": 123
//                  }
//                  ],
//    "stepCount": [
//                  {
//                      "timestamp": 123,
//                      "stepCount": 123
//                  },
//                  {
//                      "timestamp": 123,
//                      "stepCount": 123
//                  }
//                  ],
//    
//}

//- (IBAction)timerFired:(id)sender{
//    _button.hidden = !_button.hidden;
//    
//    NSDictionary* dictionary = @{@"event": _button.hidden? @"buttonHide": @"buttonShow",
//                                 @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
//    
//    [_records addObject:dictionary];
//    
//}
//
//- (IBAction)buttonTapped:(id)sender{
//    NSDictionary* dictionary = @{@"event": @"userTouchDown",
//                                 @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
//    
//    [_records addObject:dictionary];
//    
//}

- (BOOL)stop:(NSError *__autoreleasing *)error{
    BOOL didStop = [super stop:error];
    
    [self.distanceTracker stop];
    [self.healthKitSampleTypeTracker stop];
    
    [self.timer invalidate];
    [_button removeFromSuperview];
    _button = nil;
    
    if (self.dictionaryRecord) {
        
        NSLog(@"%@", self.records);
        
        id <RKRecorderDelegate> localDelegate = self.delegate;
        
        if (localDelegate && [localDelegate respondsToSelector:@selector(recorder:didCompleteWithResult:)]) {
            RKDataResult* result = [[RKDataResult alloc] initWithStep:self.step];
            result.contentType = [self mimeType];
            NSError* err;
            
            self.dictionaryRecord[@"distance"] = self.distanceRecords;
            self.dictionaryRecord[@"heartRate"] = self.heartRateRecords;
            self.dictionaryRecord[@"stepCount"] = self.stepCountRecords;
            
            result.data = [NSJSONSerialization dataWithJSONObject:self.dictionaryRecord options:(NSJSONWritingOptions)0 error:&err];
            
            if (err) {
                if (error) {
                    *error = err;
                }
                return NO;
            }
            
            result.filename = self.fileName;
            [localDelegate recorder:self didCompleteWithResult:result];
            self.records = nil;
        }
    }else{
        if (error) {
            NSLog(@"Records object is nil");
//            *error = [NSError errorWithDomain:RKErrorDomain
//                                         code:RKErrorObjectNotFound
//                                     userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Records object is nil.", nil)}];
        }
        didStop = NO;
    }
    
    
    return didStop;
}

- (NSString*)dataType{
    return @"tapTheButton";
}

- (NSString*)mimeType{
    return @"application/json";
}

- (NSString*)fileName{
    return @"tapTheButton.json";
}


/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

-(void)dismiss:(UIAlertController*)alert
{
    [alert dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismissing gps signal strength");
    }];
}

/*********************************************************************************/
#pragma mark - APHFitnessTestDistanceTrackerDelegate delegate methods
/*********************************************************************************/

/**
 * @brief Did update locations.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)parameters didUpdateLocations:(CLLocationDistance)distance {
    
    if ([self.recorderDelegate respondsToSelector:@selector(recorder:didUpdateLocation:)]) {
        
        double distanceInMiles = distance / kAPHFitnessTestMetersToMilesConversion;
        
        NSDictionary* dictionary = @{@"distance": [NSNumber numberWithDouble:distanceInMiles],
                                     @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
        
        [self.distanceRecords addObject:dictionary];
        
        [self.recorderDelegate recorder:self didUpdateLocation:distanceInMiles];
    }
}

- (void)locationManager:(CLLocationManager *)locationManager finishedPrepLocation:(BOOL)finishedPrep {
    
    if (finishedPrep) {
        if ([self.recorderDelegate respondsToSelector:@selector(recorder:didFinishPrep:)]) {

            [self.recorderDelegate recorder:self didFinishPrep:YES];
        }
    }
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

/*********************************************************************************/
#pragma mark - APHFitnessTestHealthKitSampleTypeTrackerDelegate delegate methods
/*********************************************************************************/

- (void)fitnessTestHealthKitSampleTypeTracker:(APHFitnessTestHealthKitSampleTypeTracker *)heartRateTracker didUpdateHeartRate:(NSInteger)heartBPM {
    
    if ([self.recorderDelegate respondsToSelector:@selector(recorder:didUpdateHeartRate:)]) {
        
        NSDictionary* dictionary = @{@"heartBPM": [NSNumber numberWithInteger:heartBPM],
                                     @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
        
        [self.heartRateRecords addObject:dictionary];
        
        [self.recorderDelegate recorder:self didUpdateHeartRate:heartBPM];
        
        //self.heartRate.text = [NSString stringWithFormat:@"%ld", (long)heartBPM];
    }
}

- (void)fitnessTestHealthKitSampleTypeTracker:(APHFitnessTestHealthKitSampleTypeTracker *)stepCountTracker didUpdateStepCount:(NSInteger)stepCount {

    if ([self.recorderDelegate respondsToSelector:@selector(recorder:didUpdateStepCount:)]) {
        
        NSDictionary* dictionary = @{@"stepCount": [NSNumber numberWithInteger:stepCount],
                                     @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
        
        [self.stepCountRecords addObject:dictionary];
        
        [self.recorderDelegate recorder:self didUpdateHeartRate:stepCount];
    }
}

/*********************************************************************************/
#pragma mark - APHTimer delegate methods
/*********************************************************************************/

//- (void)aphTimer:(APHTimer *)timer didUpdateCountDown:(NSString *)countdown {
//    self.myCounterLabel.text = countdown;
//}
//
//- (void)aphTimer:(APHTimer *)timer didFinishCountingDown:(NSString *)countdown {
//    [self.distanceTracker stop];
//    [self.heartRateTracker stop];
//    
//}

@end
/*********************************************************************************/
/*********************************************************************************/
/*********************************************************************************/
#pragma mark - implementation APHFitnessTestCustomRecorderConfiguration
/*********************************************************************************/

@implementation APHFitnessTestCustomRecorderConfiguration

- (RKRecorder*)recorderForStep:(RKStep*)step taskInstanceUUID:(NSUUID*)taskInstanceUUID{
    
    return [[APHFitnessTestRecorder alloc] initWithStep:step taskInstanceUUID:taskInstanceUUID];
}

#pragma mark - RKSerialization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary{
    
    self = [self init];
    if (self) {
        
    }
    return self;
}

- (NSDictionary*)dictionaryValue{
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    
    dict[@"_class"] = NSStringFromClass([self class]);
    
    return dict;
}

@end


