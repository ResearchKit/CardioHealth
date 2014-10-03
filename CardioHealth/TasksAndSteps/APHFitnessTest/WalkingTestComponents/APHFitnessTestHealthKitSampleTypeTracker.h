//
//  APHHeartPulseTracking.h
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
@import APCAppleCore;

/**
 Track the user's heart rate and step count by initializing a Health Kit Observer query. Observer queries are long-running tasks. They continue to run on an anonymous background thread and call their results handler whenever they detects relevant changes to the HealthKit store. The provided update handler block is called every time samples matching this query are saved to or deleted from the HealthKit store. You often need to launch other queries from inside this block to get the updated data. In particular, you can use Anchored Object Queries to retrieve the list of new samples that have been added to the store.
 
 - (instancetype)initWithSampleType:(HKSampleType *)sampleType
 predicate:(NSPredicate *)predicate
 updateHandler:(void (^)(HKObserverQuery *query,
 HKObserverQueryCompletionHandler completionHandler,
 NSError *error))updateHandler
 
 */

@protocol APHFitnessTestHealthKitSampleTypeTrackerDelegate;

@interface APHFitnessTestHealthKitSampleTypeTracker : NSObject

/**
 *  Designated initializer
 *
 *  @return instancetype
 */
- (instancetype)init;

/**
 *  @brief Get an early lock on updates from Health Store heart rate data
 */
- (void)startUpdating;

/**
 *  @brief stop Stops the queries to Health Store
 */
- (void)stop;

/**
 *  Delegate conforms to APHFitnessTestHeartRateTrackerDelegate.
 *
 */
@property (weak, nonatomic) id <APHFitnessTestHealthKitSampleTypeTrackerDelegate> delegate;

@end

/*********************************************************************************/
//Protocol
/*********************************************************************************/
@protocol APHFitnessTestHealthKitSampleTypeTrackerDelegate <NSObject>


@optional

/**
 * @brief Location has failed to update.
 */
- (void)fitnessTestHealthKitSampleTypeTracker:(APHFitnessTestHealthKitSampleTypeTracker *)heartRateTracker didUpdateHeartRate:(NSInteger)heartBPM;

- (void)fitnessTestHealthKitSampleTypeTracker:(APHFitnessTestHealthKitSampleTypeTracker *)stepCountTracker didUpdateStepCount:(NSInteger)stepCount;

@end
