//
//  APHFitnessTaskViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTaskViewController.h"

#import "APHFitnessTestIntroViewController.h"
#import "APHFitnessTestWalkingViewController.h"
//#import "APHIntervalTappingResultsViewController.h"

//#import "APHCustomRecorder.h"

static  NSString  *kIntervalTappingStep101 = @"IntervalTappingStep101";
static  NSString  *kIntervalTappingStep102 = @"IntervalTappingStep102";
static  NSString  *kIntervalTappingStep103 = @"IntervalTappingStep103";

@interface APHFitnessTaskViewController ()

@end

@implementation APHFitnessTaskViewController

#pragma  mark  -  Initialisation

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Interval Tapping";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.title = @"Interval Tapping";
}

+ (RKTask *)createTask:(APCScheduledTask *)scheduledTask
{
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    {
        RKIntroductionStep *step = [[RKIntroductionStep alloc] initWithIdentifier:kIntervalTappingStep101 name:@"Fitness Test Intro"];
        step.caption = @"Measure Heart Rate";
        step.explanation = @"";
        step.instruction = @"";
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kIntervalTappingStep102 name:@"6 Minute Walk"];
        step.caption = NSLocalizedString(@"6 Minute Walk", @"");
        step.text = NSLocalizedString(@"Now please turn 180 degrees, and walk back to your starting point.", @"");
        step.buzz = YES;
        step.vibration = YES;
        step.countDown = 360.0;
        [steps addObject:step];
    }
    
    RKTask  *task = [[RKTask alloc] initWithName:@"Interval Touches" identifier:@"Tapping Task" steps:steps];
    
    return  task;
}

#pragma  mark  -  Navigation Bar Button Action Methods

- (void)cancelButtonTapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{ } ];
}

- (void)doneButtonTapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{ } ];
}

#pragma  mark  -  Task View Controller Delegate Methods

- (BOOL)taskViewController:(RKTaskViewController *)taskViewController shouldPresentStepViewController:(RKStepViewController *)stepViewController
{
    return  YES;
}

- (void)taskViewController:(RKTaskViewController *)taskViewController willPresentStepViewController:(RKStepViewController *)stepViewController
{
    stepViewController.cancelButton = nil;
    stepViewController.backButton = nil;
}

- (RKStepViewController *)taskViewController:(RKTaskViewController *)taskViewController viewControllerForStep:(RKStep *)step
{
    NSDictionary  *controllers = @{
                                   kIntervalTappingStep101 : [APHFitnessTestIntroViewController   class],
                                   kIntervalTappingStep102 : [APHFitnessTestWalkingViewController   class]
//                                   kIntervalTappingStep103 : [APHIntervalTappingResultsViewController class]
                                   };
    Class  aClass = [controllers objectForKey:step.identifier];
    APCStepViewController  *controller = [[aClass alloc] initWithNibName:nil bundle:nil];
    controller.resultCollector = self;
    controller.delegate = self;
    controller.title = @"Interval Tapping";
    controller.continueButtonOnToolbar = NO;
    controller.step = step;
    return  controller;
}


@end
