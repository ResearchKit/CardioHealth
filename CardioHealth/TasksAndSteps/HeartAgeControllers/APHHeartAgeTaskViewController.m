//
//  APHHeartAgeTaskViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 9/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//
#import "APHHeartAgeTaskViewController.h"
#import "APHHeartAgeResultsViewController.h"

static NSString *kHeartAgeIntroduction = @"HeartAgeIntroduction";
static NSString *kHeartAgeQuestionAge = @"HeartAgeQuestion1";
static NSString *kHeartAgeQuestionTotalCholesterol = @"HeartAgeQuestion2";
static NSString *kHeartAgeQuestionHDL = @"HeartAgeQuestion3";
static NSString *kHeartAgeQuestionSystolicBP = @"HeartAgeQuestion4";
static NSString *kHeartAgeQuestionSmoke = @"HeartAgeQuestion5";
static NSString *kHeartAgeQuestionDiabetes = @"HeartAgeQuestion6";
static NSString *kHeartAgeQuestionFamilyDiabetes = @"HeartAgeQuestion7";
static NSString *kHeartAgeQuestionFamilyHeart = @"HeartAgeQuestion8";

@interface APHHeartAgeTaskViewController ()

@end

@implementation APHHeartAgeTaskViewController

#pragma mark - Initialize

+ (RKTask *)createTask:(APCScheduledTask *)scheduledTask
{
    NSMutableArray *steps = [NSMutableArray array];
    
    {
        RKIntroductionStep *step = [[RKIntroductionStep alloc] initWithIdentifier:kHeartAgeIntroduction
                                                                             name:NSLocalizedString(@"Heart Age Test",
                                                                                                    @"Heart Age Test")];
        step.caption = NSLocalizedString(@"Heart Age Test", @"");
        step.explanation = NSLocalizedString(@"The following few details about you we will be used to calculate your heart age.",
                                             @"Requesting user to provide information to calculate their heart age.");
        step.instruction = nil;
        
        [steps addObject:step];
    }
    
    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(17);
        format.maximum = @(99);
        
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionAge
                                                                     name:@"YourAge"
                                                                 question:@"What is your age?"
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
//    {
//        RKAnswerFormat *format = [RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"African American", @"Caucasian"]
//                                                                         style:RKChoiceAnswerStyleMultipleChoice];
//
//        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestion10
//                                                                     name:@"Ethnicity"
//                                                                 question:@"What is your ethnic group?"
//                                                                   answer:format];
//        [steps addObject:step];
//    }
    
    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(0);

        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionTotalCholesterol
                                                                     name:@"TotalCholesterol"
                                                                 question:@"What is your Total Cholesterol?"
                                                                   answer:format];
        step.optional = NO;

        [steps addObject:step];
    }

    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(0);

        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionHDL
                                                                     name:@"HDLCholesterol"
                                                                 question:@"What is your HDL Cholesterol?"
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(0);
        
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionSystolicBP
                                                                     name:@"SystolicBP"
                                                                 question:@"What is your Systolic Blood Pressure?"
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionSmoke
                                                                     name:@"SmokeA"
                                                                 question:@"Have you ever smoked?"
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionDiabetes
                                                                     name:@"MedicalConditions"
                                                                 question:@"Do you have the Diabetes?"
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionFamilyDiabetes
                                                                     name:@"FamilyHistory"
                                                                 question:@"Does Diabetes run in your family?"
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionFamilyHeart
                                                                     name:@"ParentHistory"
                                                                 question:@"Have either of your parents had heart problems?"
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    RKTask *task = [[RKTask alloc] initWithName:NSLocalizedString(@"Heart Age Test", @"Heart Age Test")
                                     identifier:@"Heart Age Test"
                                          steps:steps];
    
    return task;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showsProgressInNavigationBar = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma  mark  -  Task View Controller Delegate Methods

//- (BOOL)taskViewController:(RKTaskViewController *)taskViewController shouldPresentStepViewController:(RKStepViewController *)stepViewController
//{
//    return  YES;
//}

- (void)taskViewControllerDidComplete:(RKTaskViewController *)taskViewController
{
    NSLog(@"Task Did Complete: triggered");
}

- (RKStepViewController *)taskViewController:(RKTaskViewController *)taskViewController viewControllerForStep:(RKStep *)step
{
    if ([step.identifier isEqualToString:kHeartAgeResults]) {
        NSDictionary  *controllers = @{kHeartAgeResults: [APHHeartAgeResultsViewController class]};
        
        Class  aClass = [controllers objectForKey:step.identifier];
        
        APCStepViewController  *controller = [[aClass alloc] initWithNibName:nil bundle:nil];
        controller.resultCollector = self;
        controller.delegate = self;
        controller.title = NSLocalizedString(@"Heart Age Test", @"Heart Age Test");
        controller.continueButtonOnToolbar = NO;
        controller.step = step;
        
        return  controller;
    } else {
        return nil;
    }
}

@end
