//
//  APHHeartAgeTaskViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 9/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//
#import "APHHeartAgeTaskViewController.h"
#import "APHHeartAgeFinalStepViewController.h"

static NSString *kHeartAgeQuestion1 = @"HeartAgeQuestion1";
static NSString *kHeartAgeQuestion2 = @"HeartAgeQuestion2";
static NSString *kHeartAgeQuestion3 = @"HeartAgeQuestion3";
static NSString *kHeartAgeQuestion4 = @"HeartAgeQuestion4";
static NSString *kHeartAgeQuestion5 = @"HeartAgeQuestion5";
static NSString *kHeartAgeQuestion6 = @"HeartAgeQuestion6";
static NSString *kHeartAgeQuestion7 = @"HeartAgeQuestion7";
static NSString *kHeartAgeQuestion8 = @"HeartAgeQuestion8";
static NSString *kHeartAgeQuestion9 = @"HeartAgeQuestion9";
static NSString *kHeartAgeQuestion10 = @"HeartAgeQuestion10";
static NSString *kHeartAgeQuestion11 = @"HeartAgeQuestion11";
static NSString *kHeartAgeQuestion12 = @"HeartAgeQuestion12";
static NSString *kHeartAgeQuestion13 = @"HeartAgeQuestion13";
static NSString *kHeartAgeQuestion14 = @"HeartAgeQuestion14";

@interface APHHeartAgeTaskViewController ()

@end

@implementation APHHeartAgeTaskViewController

#pragma mark - Initialize

+ (RKTask *)createTask:(APCScheduledTask *)scheduledTask
{
    NSMutableArray *steps = [NSMutableArray array];
    
    {
        RKIntroductionStep *step = [[RKIntroductionStep alloc] initWithIdentifier:kHeartAgeQuestion1
                                                                             name:NSLocalizedString(@"Heart Age Test",
                                                                                                    @"Heart Age Test")];
        step.caption = NSLocalizedString(@"Heart Age Test", @"");
        step.explanation = NSLocalizedString(@"The following few details about you we will be used to calculate your heart age.",
                                             @"Requesting user to provide information to calculate their heart age.");
        step.instruction = nil;
        
        [steps addObject:step];
    }
    
    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat decimalAnswerWithUnit:nil];
        format.minimum = @(0);
        format.minimumFractionDigits = @(2);
        format.maximumFractionDigits = @(2);
        
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestion2
                                                                     name:@"YourHeight"
                                                                 question:@"What is your height?"
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:@"lbs"];
        format.minimum = @(0);
        format.minimumFractionDigits = @(2);
        format.maximumFractionDigits = @(2);
        
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestion3
                                                                     name:@"YourWeight"
                                                                 question:@"How much do you weigh?"
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(18);
        
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestion4
                                                                     name:@"YourAge"
                                                                 question:@"What is your age?"
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
//    {
//        RKAnswerFormat *format = [RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"African American", @"Caucasian", @"Asian", @"Hispanic"]
//                                                                         style:RKChoiceAnswerStyleMultipleChoice];
//        
//        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestion5
//                                                                     name:@"Ethnicity"
//                                                                 question:@"What is your ethnic group?"
//                                                                   answer:format];
//        [steps addObject:step];
//    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestion6
                                                                     name:@"SmokeA"
                                                                 question:@"Have you ever smoked?"
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestion7
                                                                     name:@"SmokeB"
                                                                 question:@"Do you still smoke?"
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestion8
                                                                     name:@"MedicalConditions"
                                                                 question:@"Do you have the following medical conditions?\nHeart attack, Stoke, Rheumatoid Arthritis, Chronic Kidney Disease, Atrial Fibrillation or Diabetes"
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestion9
                                                                     name:@"FamilyHistory"
                                                                 question:@"Do the previous conditions run in your family?\nHeart attack, Stoke, Rheumatoid Arthritis, Chronic Kidney Disease, Atrial Fibrillation or Diabetes"
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestion10
                                                                     name:@"ParentHistory"
                                                                 question:@"Have either of your parents had heart problems?"
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestion14
                                                                     name:@"FinalStep"
                                                                 question:@"I should not see this!"
                                                                   answer:[RKBooleanAnswerFormat new]];
        
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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark  -  Navigation Bar Button Action Methods

//- (void)cancelButtonTapped:(UIBarButtonItem *)sender
//{
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{ } ];
//}

//- (void)doneButtonTapped:(UIBarButtonItem *)sender
//{
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{ } ];
//}


#pragma  mark  -  Task View Controller Delegate Methods

//- (BOOL)taskViewController:(RKTaskViewController *)taskViewController shouldPresentStepViewController:(RKStepViewController *)stepViewController
//{
//    return  YES;
//}

//- (void)taskViewController:(RKTaskViewController *)taskViewController willPresentStepViewController:(RKStepViewController *)stepViewController
//{
//    stepViewController.cancelButton = nil;
//    stepViewController.backButton = nil;
//}

- (RKStepViewController *)taskViewController:(RKTaskViewController *)taskViewController viewControllerForStep:(RKStep *)step
{
    if ([step.identifier isEqualToString:kHeartAgeQuestion14]) {
        NSDictionary  *controllers = @{kHeartAgeQuestion14: [APHHeartAgeFinalStepViewController class]};
        
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
