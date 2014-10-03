//
//  APHHeartPulseTracking.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTestHeartRateTracker.h"

@interface APHFitnessTestHeartRateTracker ()

@property (strong, nonatomic) HKHealthStore *healthStore;
@property (strong, nonatomic) HKObserverQuery *observerQuery;
@end

@implementation APHFitnessTestHeartRateTracker

- (instancetype) init {
    self = [super init];
    
    if (self) {
        APCAppDelegate *apcAppleDelegate = [[UIApplication sharedApplication] delegate];
        
        if (apcAppleDelegate.dataSubstrate.currentUser) {
            
        }
    }
    
    return self;
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

- (void)prepHeartRateUpdate {

    self.healthStore = [[HKHealthStore alloc] init];
    
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    NSSet *readTypes = [[NSSet alloc] initWithArray:@[heartRateType]];
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:readTypes completion:^(BOOL success, NSError *error) {
        NSLog(@"Authorization?");
    }];
    
    
    if ([HKHealthStore isHealthDataAvailable]) {
        self.healthStore = [[HKHealthStore alloc] init];
        
        HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        
        __block double heartRate;


        [self.healthStore enableBackgroundDeliveryForType:heartRateType frequency:3.0 withCompletion:^(BOOL success, NSError *error) {
            
            if (success) {
                HKQuantityType *vitals = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
                
                
                [self.healthStore mostRecentQuantitySampleOfType:vitals predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
                    
                    if (error) {
                        [error handle];
                    } else {
                        //                    heartRate = mostRecentQuantity;
                        NSLog(@"Heart Rate %@", mostRecentQuantity);
                    }
                }];
            } else {
                [error handle];
                
            }
        }];
        
    self.observerQuery = [[HKObserverQuery alloc] initWithSampleType:heartRateType predicate:nil updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error) {
            if (!error) {
                [self.healthStore mostRecentQuantitySampleOfType:heartRateType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
                    
                    HKUnit * heartBPM = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
                
                    heartRate = [mostRecentQuantity doubleValueForUnit:heartBPM];
                    NSLog(@"Heart Rate %f", heartRate);
                    dispatch_async(dispatch_get_main_queue(), ^{ [self heartRateDidChange:heartRate]; });
                    
                }];
                
                completionHandler();
                
            } else {

                [error handle];
            }
            
        }];
        

        [self.healthStore executeQuery:self.observerQuery];
        
        
    }
}

/*********************************************************************************/
#pragma mark - Delegate Methods
/*********************************************************************************/

- (void)heartRateDidChange:(double)heartRateBPM {
    
    NSLog(@"%f",heartRateBPM);
    if ([self.delegate respondsToSelector:@selector(fitnessTestHeartRateTracker:didUpdateHeartRate:)]) {
        NSInteger integerValueOfBPM = (NSInteger) roundf(heartRateBPM);
        
        [self.delegate fitnessTestHeartRateTracker:self didUpdateHeartRate:integerValueOfBPM];
    }
}


- (void)start {
    NSLog(@"Stop");
}

- (void)stop {
    NSLog(@"Stop");
    [self.healthStore stopQuery:self.observerQuery];
}




@end
