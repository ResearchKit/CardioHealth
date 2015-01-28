// 
//  APHFitnessTaskViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHFitnessTaskViewController.h"

static NSInteger const  kRestDuration              = 3.0 * 60.0;
static NSInteger const  kWalkDuration              = 6.0 * 60.0;
static NSString *const  kFitnessTestIdentifier     = @"6-Minute Walk Test";
static NSString *const  kIntendedUseDescription    = @"This is placeholder text.";

@interface APHFitnessTaskViewController ()

@end

@implementation APHFitnessTaskViewController

/*********************************************************************************/
#pragma  mark  -  Initialisation
/*********************************************************************************/

+ (RKSTOrderedTask *)createTask:(APCScheduledTask *)scheduledTask
{
    RKSTOrderedTask  *task = [RKSTOrderedTask fitnessCheckTaskWithIdentifier:kFitnessTestIdentifier intendedUseDescription:kIntendedUseDescription walkDuration:kWalkDuration restDuration:kRestDuration options:RKPredefinedTaskOptionNone];
    
    return  task;
}

@end
