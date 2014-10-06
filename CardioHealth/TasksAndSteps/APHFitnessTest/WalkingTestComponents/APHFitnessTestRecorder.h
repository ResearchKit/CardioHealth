//
//  APHFitnessTestRecorder.h
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>
#import "APHFitnessTestDistanceTracker.h"
#import "APHFitnessTestHealthKitSampleTypeTracker.h"
#import "APHTimer.h"

@protocol  APHFitnessTestRecorderDelegate;

@interface APHFitnessTestRecorder : RKRecorder <APHFitnessTestDistanceTrackerDelegate, APHFitnessTestHealthKitSampleTypeTrackerDelegate>

/**
 *  Delegate conforms to APHFitnessTestRecorderDelegate.
 */
@property (weak, nonatomic) id <APHFitnessTestRecorderDelegate> recorderDelegate;

@end

/*********************************************************************************/
//Protocol
/*********************************************************************************/
@protocol  APHFitnessTestRecorderDelegate <NSObject>

@optional

- (void)recorder:(APHFitnessTestRecorder *)recorder didRecordData:(NSDictionary *)dictionary;

- (void)recorder:(APHFitnessTestRecorder *)recorder didUpdateHeartRate:(NSInteger)heartRateBPM;

- (void)recorder:(APHFitnessTestRecorder *)recorder didUpdateLocation:(CLLocationDistance)location;

- (void)recorder:(APHFitnessTestRecorder *)recorder didFinishPrep:(BOOL)finishedPrep;

- (void)recorder:(APHFitnessTestRecorder *)recorder didUpdateStepCount:(NSInteger)stepsCount;

@end


@interface APHFitnessTestCustomRecorderConfiguration : NSObject <RKRecorderConfiguration>

@end
