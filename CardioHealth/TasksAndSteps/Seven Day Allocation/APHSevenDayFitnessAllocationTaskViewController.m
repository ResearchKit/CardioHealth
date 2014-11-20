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

+ (RKSTOrderedTask *)createTask:(APCScheduledTask *)scheduledTask
{
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    {
        RKSTInstructionStep *step = [[RKSTInstructionStep alloc] initWithIdentifier:kSevenDayFitnessInstructionStep];
        step.title = NSLocalizedString(@"7 Day Fitness Allocation", @"7 Day Fitness Allocation");
        step.detailText = @"Some instructions";
        
        [steps addObject:step];
    }
    
    {
        // Seven Day Fitness Allocation Step
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:kSevenDayFitnessActivityStep];
        step.title = NSLocalizedString(@"Activity Tracking", @"Activity Tracking");
        step.text = NSLocalizedString(@"Get Ready!", @"Get Ready");
        
        [steps addObject:step];
    }
    
    RKSTOrderedTask  *task = [[RKSTOrderedTask alloc] initWithIdentifier:@"sevenDayFitnessAllocation" steps:steps];
    
    return task;
}

#pragma mark - Task View Delegates

- (RKSTStepViewController *)taskViewController:(RKSTTaskViewController *)taskViewController viewControllerForStep:(RKSTStep *)step
{
    RKSTStepViewController *stepVC = nil;
    
    if (step.identifier == kSevenDayFitnessInstructionStep) {
        NSDictionary  *controllers = @{kSevenDayFitnessInstructionStep: [APHSevenDayFitnessIntroStepViewController class]};
        Class  aClass = [controllers objectForKey:step.identifier];
        APCStepViewController *controller = [[aClass alloc] initWithNibName:nil bundle:nil];

        controller.delegate = self;
        controller.step = step;
        
        stepVC = controller;
    } else if (step.identifier == kSevenDayFitnessActivityStep) {
        UIStoryboard *sbActivityTracking = [UIStoryboard storyboardWithName:@"APHActivityTracking" bundle:nil];
        APHActivityTrackingStepViewController *activityVC = [sbActivityTracking instantiateInitialViewController];
        
        activityVC.delegate = self;
        activityVC.step = step;
        
        stepVC = activityVC;
    }
    
    return stepVC;
}


@end
