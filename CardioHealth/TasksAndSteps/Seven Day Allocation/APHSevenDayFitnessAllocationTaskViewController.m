//
//  APHSevenDayFitnessAllocationViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSevenDayFitnessAllocationTaskViewController.h"
#import "APHSevenDayFitnessIntroStepViewController.h"
#import "APHActivityTrackingStepViewController.h"

static NSString *kMainStudyIdentifier = @"com.cardioVascular.sevenDayFitnessAllocation";
static NSString *kSevenDayFitnessInstructionStep = @"sevenDayFitnessInstructionStep";
static NSString *kSevenDayFitnessActivityStep = @"sevenDayFitnessActivityStep";
static NSString *kSevenDayFitnessCompleteStep = @"sevenDayFitnessCompleteStep";

@interface APHSevenDayFitnessAllocationTaskViewController ()

@end

@implementation APHSevenDayFitnessAllocationTaskViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showsProgressInNavigationBar = NO;
    self.navigationBar.topItem.title = NSLocalizedString(@"Activity Tracking", @"Activity Tracking");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Task

+ (RKTask *)createTask:(APCScheduledTask *)scheduledTask
{
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    {
        RKIntroductionStep *step = [[RKIntroductionStep alloc] initWithIdentifier:kSevenDayFitnessInstructionStep
                                                                             name:@"Seven Day Fitness Instructions"];
        step.caption = NSLocalizedString(@"7 Day Fitness Allocation", @"7 Day Fitness Allocation");
        step.instruction = @"Some instructions";
        [steps addObject:step];
    }
    
    {
        // Seven Day Fitness Allocation Step
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kSevenDayFitnessActivityStep
                                                                 name:@"Activity Tracking"];
        step.caption = NSLocalizedString(@"Activity Tracking", @"Activity Tracking");
        step.text = NSLocalizedString(@"Get Ready!", @"Get Ready");
        
        [steps addObject:step];
    }
    
    RKTask  *task = [[RKTask alloc] initWithName:@"7 Day Fitness Allocation"
                                      identifier:@"sevenDayFitnessAllocation"
                                           steps:steps];
    return task;
}

#pragma mark - Task View Delegates

- (RKStepViewController *)taskViewController:(RKTaskViewController *)taskViewController viewControllerForStep:(RKStep *)step
{
    RKStepViewController *stepVC = nil;
    
    if (step.identifier == kSevenDayFitnessInstructionStep) {
        NSDictionary  *controllers = @{kSevenDayFitnessInstructionStep: [APHSevenDayFitnessIntroStepViewController class]};
        Class  aClass = [controllers objectForKey:step.identifier];
        APCStepViewController *controller = [[aClass alloc] initWithNibName:nil bundle:nil];
        controller.resultCollector = self;
        controller.delegate = self;
        controller.title = NSLocalizedString(@"Activity Tracking", @"Activity Tracking");
        controller.step = step;
        
        stepVC = controller;
    } else if (step.identifier == kSevenDayFitnessActivityStep) {
        UIStoryboard *sbActivityTracking = [UIStoryboard storyboardWithName:@"APHActivityTracking" bundle:nil];
        APHActivityTrackingStepViewController *activityVC = [sbActivityTracking instantiateInitialViewController];
        
        activityVC.resultCollector = self;
        activityVC.delegate = self;
        activityVC.step = step;
        
        stepVC = activityVC;
    }
    
    return stepVC;
}


@end
