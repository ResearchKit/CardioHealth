//
//  APHHealthyHeartTaskViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/17/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHealthyHeartTaskViewController.h"

static NSString *kHealthyHeartIntroduction = @"healthyHeartIntroduction";
static NSString *kBloodPressureChecked = @"bloodPressureChecked";
static NSString *kBloodPressureLevel = @"bloodPressureLevel";
static NSString *kHaveHighBloodPressure = @"haveHighBloodPressure";

@interface APHHealthyHeartTaskViewController ()

@end

@implementation APHHealthyHeartTaskViewController

#pragma mark - Task

+ (RKTask *)createTask:(APCScheduledTask *)scheduledTask
{
    NSMutableArray *steps = [NSMutableArray array];
    
    {
        RKIntroductionStep *step = [[RKIntroductionStep alloc] initWithIdentifier:kHealthyHeartIntroduction
                                                                             name:NSLocalizedString(@"Healthy Heart",
                                                                                                    @"Healthy Heart")];
        step.caption = NSLocalizedString(@"Healthy Heart", @"");
        step.explanation = NSLocalizedString(@"The purpose of this survey is to learn about the heart health of patients at this clinic.",
                                             @"The purpose of this survey is to learn about the heart health of patients at this clinic.");
        step.instruction = nil;
        
        [steps addObject:step];
    }
    {
        RKChoiceAnswerFormat *format = [RKChoiceAnswerFormat choiceAnswerWithOptions:@[
                                                                                       @"Within the past year",
                                                                                       @"Within the past 2 years",
                                                                                       @"Within the past 5 years",
                                                                                       @"Don't Know",
                                                                                       @"Never had it checked."]
                                                                               style:RKChoiceAnswerStyleSingleChoice];
        
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kBloodPressureChecked
                                                                     name:kBloodPressureChecked
                                                                 question:@"When was the last time you had your blood pressure checked?"
                                                                   answer:format];
        
        [steps addObject:step];
    }
    {
        RKChoiceAnswerFormat *format = [RKChoiceAnswerFormat choiceAnswerWithOptions:@[
                                                                                       @"Normal",
                                                                                       @"High",
                                                                                       @"Don't Know"]
                                                                               style:RKChoiceAnswerStyleSingleChoice];
        
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kBloodPressureLevel
                                                                     name:kBloodPressureLevel
                                                                 question:@"The LAST time you had your blood pressure checked, was it normal or high?"
                                                                   answer:format];
        
        [steps addObject:step];
    }
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHaveHighBloodPressure
                                                                     name:kHaveHighBloodPressure
                                                                 question:@"Have you EVER been told by a doctor, nurse, or other health professional that you have high blood pressure?"
                                                                   answer:[RKBooleanAnswerFormat new]];
        [steps addObject:step];
    }
    
    RKTask *task = [[RKTask alloc] initWithName:NSLocalizedString(@"Healthy Heart", @"Healthy Heart")
                                     identifier:@"Healthy Heart"
                                          steps:steps];
    
    return task;
    
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
