//
//  APHFitnessTestWalkingViewController.h
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APHTimer.h"
#import "APHFitnessTestRecorder.h"

@import APCAppleCore;

/**
This step represents a fitness test that requires the user to walk 6 minutes, rest for 3 minutes, and walk another 6 minutes. 
 For the walking step there is a time component represented as a countdown timer. Another component represent the distance 
 the user has walked. There is also a graphical component that updates the user's heart rate in real time. The data for the 
 heart rate component is driven by queries to the HKHealthStore.
 
 Possible issues is the timing of when a location update is first available and when the timer begins
 
 */

@interface APHFitnessTestWalkingViewController : APCStepViewController <APHTimerDelegate>


@end
