// 
//  APHFitnessTaskViewController.h 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
@import APCAppCore;
#import "APHFitnessTestHealthKitSampleTypeTracker.h"
#import "APHFitnessTestDistanceTracker.h"
#import "APHFitnessTestRecorder.h"
#import "APHFitnessSixMinuteFitnessTestView.h"
#import "APHFitnessTestRestComfortablyView.h"
#import "APHFitnessTestRestView.h"
#import <CoreLocation/CoreLocation.h>

@interface APHFitnessTaskViewController : APCBaseWithProgressTaskViewController <APHFitnessTestHealthKitSampleTypeTrackerDelegate, APHFitnessTestDistanceTrackerDelegate>

@end
