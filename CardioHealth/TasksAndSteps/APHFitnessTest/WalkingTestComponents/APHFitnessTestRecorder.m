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


static CGFloat kAPHFitnessTestMetersToMilesConversion = 1609.34;

static  NSString  *kFitnessTestStep101 = @"FitnessStep101";
static  NSString  *kFitnessTestStep102 = @"FitnessStep102";
static  NSString  *kFitnessTestStep103 = @"FitnessStep103";
static  NSString  *kFitnessTestStep104 = @"FitnessStep104";
static  NSString  *kFitnessTestStep105 = @"FitnessStep105";

@interface APHFitnessTestRecorder ()
@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, strong) NSMutableDictionary* dictionaryRecord;
@property (nonatomic, strong) NSMutableArray* distanceRecords;
@property (nonatomic, strong) NSMutableArray* heartRateRecords;
@property (nonatomic, strong) NSMutableArray* stepCountRecords;
@property (nonatomic, strong) NSTimer* timer;

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
    if (self.step.identifier == kFitnessTestStep102) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveUpdatedLocationNotification:)
                                                     name:@"APHFitnessDistanceUpdated"
                                                   object:nil];
        
        self.containerView.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, 320.0, view.frame.size.height);
        UINib *nib = [UINib nibWithNibName:@"APHFitnessSixMinuteFitnessTestView" bundle:nil];
        APHFitnessSixMinuteFitnessTestView *updatedView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
        [self.containerView addSubview:updatedView];

    } else {

        self.containerView.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, 320.0, view.frame.size.height);
        UINib *nib = [UINib nibWithNibName:@"APHFitnessTestRestComfortablyView" bundle:nil];
        APHFitnessTestRestComfortablyView *updatedView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
        [self.containerView addSubview:updatedView];
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
    
    //This timer is unrelated to the one that is running by ResearchKit. However, I can use the values to add to records.
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    
    //TODO Apple was thinking about using code like this to delay the beginning of the countdown. I'm keeping this around to remind myself to ask Ed about this functionality.
//    double delayInSeconds = 5.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
//    });
    
}

/*********************************************************************************/
#pragma mark - NSNotification Methods
/*********************************************************************************/
- (void)receiveHeartBPMNotification:(NSNotification *)notification {
    NSMutableDictionary *heartBeatInfo = [notification.userInfo mutableCopy];
    NSTimeInterval numberOfSeconds = [[NSDate date] timeIntervalSinceDate:self.timer.fireDate];
    heartBeatInfo[@"timer"] = [[NSNumber alloc] initWithDouble:numberOfSeconds];
    
    //NSLog(@"Recorder Heart Beat Info %@", heartBeatInfo);
    
    [self.heartRateRecords addObject:heartBeatInfo];
}

- (void)receiveStepCountNotification:(NSNotification *)notification {
    NSMutableDictionary *stepCountInfo = [notification.userInfo mutableCopy];
    NSTimeInterval numberOfSeconds = [[NSDate date] timeIntervalSinceDate:self.timer.fireDate];
    stepCountInfo[@"timer"] = [[NSNumber alloc] initWithDouble:numberOfSeconds];
    
    //NSLog(@"Custom View Step Count Info %@", stepCountInfo);
    
    [self.stepCountRecords addObject:stepCountInfo];
}

- (void)receiveUpdatedLocationNotification:(NSNotification *)notification {
    NSMutableDictionary *distanceUpdatedInfo = [notification.userInfo mutableCopy];
    NSTimeInterval numberOfSeconds = [[NSDate date] timeIntervalSinceDate:self.timer.fireDate];
    distanceUpdatedInfo[@"timer"] = [[NSNumber alloc] initWithDouble:numberOfSeconds];
    
    CLLocationDistance distance = [[distanceUpdatedInfo objectForKey:@"distance"] doubleValue];
    self.totalDistance += distance;
    CLLocationDistance distanceInMiles = self.totalDistance/kAPHFitnessTestMetersToMilesConversion;
    distanceUpdatedInfo[@"totalDistanceInMiles"] = [[NSNumber alloc] initWithDouble:distanceInMiles];
    
    //NSLog(@"Custom View Distance Total Info %@", distanceUpdatedInfo);
    
    [self.distanceRecords addObject:distanceUpdatedInfo];
}


/*********************************************************************************/
#pragma mark - Overriding Methods
/*********************************************************************************/
//Start begins whenever the timer starts in the step view controller
- (BOOL)start:(NSError *__autoreleasing *)error{
    BOOL didStart = [super start:error];
    
    
    return didStart;
}

- (IBAction)timerFired:(id)sender{
    
//    NSDictionary* dictionary = @{@"event": _button.hidden? @"buttonHide": @"buttonShow",
//                                 @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
//    
//    [_records addObject:dictionary];
    
}

- (IBAction)buttonTapped:(id)sender{
    
//    NSDictionary* dictionary = @{@"event": @"userTouchDown",
//                                 @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
//    
//    [_records addObject:dictionary];
    
}

- (BOOL)stop:(NSError *__autoreleasing *)error{
    BOOL didStop = [super stop:error];
    
    //If the step collects distance
    if (self.step.identifier == kFitnessTestStep102) {
        self.dictionaryRecord[@"distance"] = self.distanceRecords;
    }
    
    self.dictionaryRecord[@"heartRateBPM"] = self.heartRateRecords;
    self.dictionaryRecord[@"stepCount"] = self.stepCountRecords;
    
    if (self.dictionaryRecord) {
    
        
        NSLog(@"%@", self.dictionaryRecord);
        
        id<RKRecorderDelegate> localDelegate = self.delegate;
        if (localDelegate && [localDelegate respondsToSelector:@selector(recorder:didCompleteWithResult:)]) {
            RKDataResult* result = [[RKDataResult alloc] initWithStep:self.step];
            result.contentType = [self mimeType];
            NSError* err;
            result.data = [NSJSONSerialization dataWithJSONObject:self.dictionaryRecord options:(NSJSONWritingOptions)0 error:&err];
            
            if (err) {
                if (error) {
                    *error = err;
                }
                return NO;
            }
            
            result.filename = self.fileName;
            [localDelegate recorder:self didCompleteWithResult:result];
            self.dictionaryRecord = nil;
        }
    }else{
        if (error) {
            *error = [NSError errorWithDomain:RKErrorDomain
                                         code:RKErrorObjectNotFound
                                     userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Records object is nil.", nil)}];
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


