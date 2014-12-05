// 
//  APHFitnessTestHealthKitSampleTypeTracker.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 <INSTITUTION-NAME-TBD> All rights reserved. 
// 
 
#import "APHFitnessTestHealthKitSampleTypeTracker.h"

@interface APHFitnessTestHealthKitSampleTypeTracker ()

@property (strong, nonatomic) HKHealthStore *healthStore;
@property (strong, nonatomic) HKObserverQuery *observerQuery;
@property (strong, nonatomic) HKObserverQuery *stepObserverQuery;

@property (assign) __block double stepCount;
@end

@implementation APHFitnessTestHealthKitSampleTypeTracker

- (instancetype) init {
    self = [super init];
    
    if (self) {
        APCAppDelegate *apcAppleDelegate = (APCAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        //TODO this isn't working yet.
//        if (apcAppleDelegate.dataSubstrate.currentUser) {
            self.healthStore = apcAppleDelegate.dataSubstrate.healthStore;
//        }
    }
    
    return self;
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

- (void)startUpdating {
    
    HKQuantityType *stepsCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];

    //TODO this is here temporary until onboarding is getting the appropriate permissions
    NSSet *readTypes = [[NSSet alloc] initWithArray:@[heartRateType, stepsCountType]];
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:readTypes completion:^(BOOL success, NSError *error) {
        NSLog(@"Authorization?");
    }];
    
    
    if ([HKHealthStore isHealthDataAvailable]) {

        self.observerQuery = [[HKObserverQuery alloc] initWithSampleType:heartRateType predicate:nil updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error) {
            if (!error) {
                
                [self.healthStore mostRecentQuantitySampleOfType:heartRateType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
                    
                    HKUnit * heartBPM = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
                    double heartRate;                    
                    heartRate = [mostRecentQuantity doubleValueForUnit:heartBPM];
                    dispatch_async(dispatch_get_main_queue(), ^{ [self heartRateDidChange:heartRate]; });
                    
                }];
                
                completionHandler();
                
            } else {

                [error handle];
            }
        }];
        
        //Execute query
        [self.healthStore executeQuery:self.observerQuery];
        
        self.stepObserverQuery = [[HKObserverQuery alloc] initWithSampleType:stepsCountType predicate:nil updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error) {
            if (!error) {
                
                HKQuantityType *stepsCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                [self.healthStore mostRecentQuantitySampleOfType:stepsCountType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
                    
                    HKUnit * stepCountUnit = [HKUnit countUnit];
                    self.stepCount = [mostRecentQuantity doubleValueForUnit:stepCountUnit];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{ [self stepCountDidChange:self.stepCount]; });
                    
                }];

                completionHandler();
                
            } else {
                
                [error handle];
            }
            
        }];

        //Execute query
        [self.healthStore executeQuery:self.stepObserverQuery];

    }
}

- (void)stop {
    [self.healthStore stopQuery:self.observerQuery];
    [self.healthStore stopQuery:self.stepObserverQuery];
}
/*********************************************************************************/
#pragma mark - Delegate Methods
/*********************************************************************************/

- (void)heartRateDidChange:(double)heartRateBPM {
    
    if ([self.delegate respondsToSelector:@selector(fitnessTestHealthKitSampleTypeTracker:didUpdateHeartRate:)]) {
        //Rounding to the nearest integer
        NSInteger integerValueOfBPM = (NSInteger) roundf(heartRateBPM);
        
        [self.delegate fitnessTestHealthKitSampleTypeTracker:self didUpdateHeartRate:integerValueOfBPM];
    }
}

- (void)stepCountDidChange:(double)stepCount {
    
    if ([self.delegate respondsToSelector:@selector(fitnessTestHealthKitSampleTypeTracker:didUpdateStepCount:)]) {
        //Rounding to the nearest integer
        NSInteger integerValueOfStepCount = (NSInteger) roundf(stepCount);
        
        [self.delegate fitnessTestHealthKitSampleTypeTracker:self didUpdateStepCount:integerValueOfStepCount];
    }
}

@end
