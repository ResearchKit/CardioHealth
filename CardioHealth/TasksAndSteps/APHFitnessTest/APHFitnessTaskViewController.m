// 
//  APHFitnessTaskViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHFitnessTaskViewController.h"

static NSInteger const  kRestDuration              = 3.0 * 60.0;
static NSInteger const  kWalkDuration              = 6.0 * 60.0;
static NSString* const  kFitnessTestIdentifier     = @"6-Minute Walk Test";
#warning The intended use description is using placeholder text.
static NSString* const  kIntendedUseDescription    = @"Once you tap Get Started begin walking at your fastest possible pace. If you have a wearable device linked to your phone that can track your heart rate, please put it on. After the test is finished, your results will be analyzed and available on the dashboard.";

static NSString* const  kIntroStep                 = @"instruction";
static NSString* const  kIntroOneStep              = @"instruction1";
static NSString* const  kCountdownStep             = @"countdown";
static NSString* const  kWalkStep                  = @"fitness.walk";
static NSString* const  kRestStep                  = @"fitness.rest";
static NSString* const  kConclusionStep            = @"conclusion";

@interface APHFitnessTaskViewController ()

@end

@implementation APHFitnessTaskViewController

/*********************************************************************************/
#pragma  mark  -  Initialisation
/*********************************************************************************/

+ (RKSTOrderedTask *)createTask:(APCScheduledTask *)scheduledTask
{
    RKSTOrderedTask  *task = [RKSTOrderedTask fitnessCheckTaskWithIdentifier:kFitnessTestIdentifier intendedUseDescription:kIntendedUseDescription walkDuration:kWalkDuration restDuration:kRestDuration options:RKPredefinedTaskOptionNone];
    
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
    
    return  task;
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController stepViewControllerWillAppear:(RKSTStepViewController *)stepViewController {
    
    if ([stepViewController.step.identifier isEqualToString:kConclusionStep]) {
        [[UIView appearance] setTintColor:[UIColor appTertiaryColor1]];
    }
}

@end
