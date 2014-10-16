//
//  APHFitnessTaskViewController.h
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import APCAppleCore;
#import "APHFitnessTestHealthKitSampleTypeTracker.h"
#import "APHFitnessTestDistanceTracker.h"
#import "APHFitnessTestRecorder.h"
#import "APHFitnessTestRestComfortablyView.h"
#import "APHFitnessTestRestView.h"
#import <CoreLocation/CoreLocation.h>
#import "APHImportantDetailsViewController.h"

@interface APHFitnessTaskViewController : APCSetupTaskViewController <APHFitnessTestHealthKitSampleTypeTrackerDelegate, APHFitnessTestDistanceTrackerDelegate>

@end
