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
#import "APHFitnessTestComfortablePositionViewController.h"
#import "APHFitnessTestRestViewController.h"
#import "APHFitnessTestFinishedViewController.h"

static  NSString  *kIntervalTappingStep101 = @"FitnessStep101";
static  NSString  *kIntervalTappingStep102 = @"FitnessStep102";
static  NSString  *kIntervalTappingStep103 = @"FitnessStep103";
static  NSString  *kIntervalTappingStep104 = @"FitnessStep104";
static  NSString  *kIntervalTappingStep105 = @"FitnessStep105";

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
    
    //TODO Commented out code in the steps are intended to be configured at a later date. The recorders are there as a reminder that these steps will require logging. 
    {
        //Introduction to fitness test
        RKIntroductionStep *step = [[RKIntroductionStep alloc] initWithIdentifier:kIntervalTappingStep101 name:@"Fitness Test Intro"];
        [steps addObject:step];
    }
    
    {
        //Walking 6 minutes
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kIntervalTappingStep102 name:@"6 Minute Walk"];
//        step.recorderConfigurations = [RKRecorder new];
//        step.caption = NSLocalizedString(@"6 Minute Walk", @"");
//        step.text = NSLocalizedString(@"Walk 6 minutes.", @"");
        [steps addObject:step];
    }
    
    {
        //Stop and sit in a comfortable position for 3 minutes
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kIntervalTappingStep103 name:@"3 Minutes in a comfortable Position"];
//        step.recorderConfigurations = [RKRecorder new];
//        step.caption = NSLocalizedString(@"3 Minute Rest", @"");
//        step.text = NSLocalizedString(@"Now rest 3 minutes.", @"");
        [steps addObject:step];
    }

    {
        //Rest for 3 minutes
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kIntervalTappingStep104 name:@"3 Minutes in a resting Position"];
//        step.recorderConfigurations = [RKRecorder new];        
//        step.caption = NSLocalizedString(@"3 Minute Rest", @"");
//        step.text = NSLocalizedString(@"Now rest 3 minutes.", @"");
        [steps addObject:step];
    }
    
    {
        //Finished
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:kIntervalTappingStep105 name:@"Completed"];

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
                                   kIntervalTappingStep102 : [APHFitnessTestWalkingViewController   class],
                                   kIntervalTappingStep103 : [APHFitnessTestComfortablePositionViewController   class],
                                   kIntervalTappingStep104 : [APHFitnessTestRestViewController class],
                                   kIntervalTappingStep105 : [APHFitnessTestFinishedViewController class]
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
