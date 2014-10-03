//
//  APHFitnessTestComfortablePositionViewController.h
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <APCAppleCore/APCAppleCore.h>
#import "APHFitnessTestDistanceTracker.h"
#import "APHFitnessTestHealthKitSampleTypeTracker.h"
#import "APHTimer.h"

@interface APHFitnessTestComfortablePositionViewController : APCStepViewController <APHFitnessTestDistanceTrackerDelegate, APHFitnessTestHealthKitSampleTypeTrackerDelegate, APHTimerDelegate>

@end
