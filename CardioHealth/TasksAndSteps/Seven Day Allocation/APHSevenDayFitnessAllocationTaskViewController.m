//
//  APHSevenDayFitnessAllocationViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSevenDayFitnessAllocationTaskViewController.h"
#import "APHSevenDayFitnessIntroStepViewController.h"
//#import "APHFitnessTestIntroStepViewController.h"

static NSString *kMainStudyIdentifier = @"com.cardioVascular.sevenDayFitnessAllocation";
static NSString *kSevenDayFitnessInstructionStep = @"sevenDayFitnessInstructionStep";

@interface APHSevenDayFitnessAllocationTaskViewController ()

@end

@implementation APHSevenDayFitnessAllocationTaskViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
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
        //Introduction to fitness test
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"Step102" name:@"active step"];
        step.caption = NSLocalizedString(@"Fitness Test", @"");
        step.text = NSLocalizedString(@"Get Ready!", @"");
        step.countDown = 2.0;
        step.useNextForSkip = NO;
        step.buzz = YES;
        step.speakCountDown = YES;
        
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
        NSDictionary  *controllers = @{kSevenDayFitnessInstructionStep: [APHSevenDayFitnessIntroStepViewController class] };
        
        Class  aClass = [controllers objectForKey:step.identifier];
        APCStepViewController  *controller = [[aClass alloc] initWithNibName:nil bundle:nil];
        controller.resultCollector = self;
        controller.delegate = self;
        controller.title = @"Activity Tracking";
        controller.step = step;
        
        stepVC = controller;
    }
    
    return stepVC;
}


@end
