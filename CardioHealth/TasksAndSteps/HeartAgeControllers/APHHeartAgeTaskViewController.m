//
//  APHHeartAgeTaskViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 9/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//
#import "APHHeartAgeTaskViewController.h"
#import "APHHeartAgeResultsViewController.h"
#import <math.h>

// Question Keys
static NSString *kHeartAgeIntroduction = @"HeartAgeIntroduction";
static NSString *kHeartAgeQuestionAge = @"HeartAgeQuestion1";
static NSString *kHeartAgeQuestionTotalCholesterol = @"HeartAgeQuestion2";
static NSString *kHeartAgeQuestionHDL = @"HeartAgeQuestion3";
static NSString *kHeartAgeQuestionSystolicBP = @"HeartAgeQuestion4";
static NSString *kHeartAgeQuestionSmoke = @"HeartAgeQuestion5";
static NSString *kHeartAgeQuestionDiabetes = @"HeartAgeQuestion6";
static NSString *kHeartAgeQuestionFamilyDiabetes = @"HeartAgeQuestion7";
static NSString *kHeartAgeQuestionFamilyHeart = @"HeartAgeQuestion8";
static NSString *kHeartAgeQuestionEthnicity = @"HeartAgeQuestion9";
static NSString *kHeartAgeQuestionGender = @"HeartAgeQuestion10";
static NSString *kHeartAgeQuestionSmokeB = @"HeartAgeQuestion11";
static NSString *kHeartAgeQuestionHypertension = @"HeartAgeQuestion12";

@interface APHHeartAgeTaskViewController ()

// This property will hold the parameters that will be used
// for calculating the heart age, 10 year, and lifetime risk table.
@property (nonatomic, strong) NSDictionary *heartAgeParametersLookUp;

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
        step.explanation = NSLocalizedString(@"The following few details about you will be used to calculate your heart age.",
                                             @"Requesting user to provide information to calculate their heart age.");
        step.instruction = nil;
        
        [steps addObject:step];
    }
    
    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(1);
        
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionAge
                                                                     name:@"YourAge"
                                                                 question:NSLocalizedString(@"What is your age?", @"What is your age?")
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKAnswerFormat *format = [RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"Female", @"Male"]
                                                                         style:RKChoiceAnswerStyleSingleChoice];
        
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionGender
                                                                     name:@"Gender"
                                                                 question:NSLocalizedString(@"What is your biological sex?", @"What is your biological sex?")
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKAnswerFormat *format = [RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"African American", @"Other"]
                                                                         style:RKChoiceAnswerStyleSingleChoice];

        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionEthnicity
                                                                     name:@"Ethnicity"
                                                                 question:@"What is your ethnic group?"
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(0);

        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionTotalCholesterol
                                                                     name:@"TotalCholesterol"
                                                                 question:NSLocalizedString(@"What is your Total Cholesterol?", @"What is your Total Cholesterol?")
                                                                   answer:format];
        step.optional = NO;

        [steps addObject:step];
    }

    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(0);

        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionHDL
                                                                     name:@"HDLCholesterol"
                                                                 question:NSLocalizedString(@"What is your HDL Cholesterol?", @"What is your HDL Cholesterol?")
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(0);
        
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionSystolicBP
                                                                     name:@"SystolicBP"
                                                                 question:NSLocalizedString(@"What is your Systolic Blood Pressure?", @"What is your Systolic Blood Pressure?")
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionSmoke
                                                                     name:@"SmokeA"
                                                                 question:NSLocalizedString(@"Have you ever smoked?", @"Have you ever smoked?")
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionSmokeB
                                                                     name:@"SmokeB"
                                                                 question:NSLocalizedString(@"Do you still smoke?", @"Do you still smoke?")
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionDiabetes
                                                                     name:@"MedicalConditions"
                                                                 question:NSLocalizedString(@"Do you have Diabetes?", @"Do you have Diabetes?")
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionHypertension
                                                                     name:@"Hypertension"
                                                                 question:NSLocalizedString(@"Are you being treated for Hypertension?",
                                                                                            @"Are you being treated for Hypertension?")
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionFamilyDiabetes
                                                                     name:@"FamilyHistory"
                                                                 question:NSLocalizedString(@"Does Diabetes run in your family?", @"Does Diabetes run in your family?")
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeQuestionFamilyHeart
                                                                     name:@"ParentHistory"
                                                                 question:NSLocalizedString(@"Have either of your parents had heart problems?", @"Have either of your parents had heart problems?")
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


#pragma mark - StepViewController Delegate Methods

- (void)stepViewControllerWillBePresented:(RKStepViewController *)viewController
{
    NSLog(@"Step: %@ (%@)", viewController.step.name, viewController.step.identifier);
    
    APCAppDelegate *apcAppDelegate = [[UIApplication sharedApplication] delegate];
    
    if ([viewController.step.identifier isEqualToString:kHeartAgeQuestionAge]) {
        // Check if we have the date of birth available via HealthKit
        if (apcAppDelegate.dataSubstrate.currentUser.consented) {
            NSDate *dateOfBirth = apcAppDelegate.dataSubstrate.currentUser.birthDate;
            
            // Compute the age of the user.
            NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                              fromDate:dateOfBirth
                                                                                toDate:[NSDate date] // today
                                                                               options:NSCalendarWrapComponents];
            
            NSUInteger usersAge = [ageComponents year];
            
            NSLog(@"Your Age: %lu", usersAge);
        }
    }
}


#pragma  mark  -  Task View Controller Delegate Methods

- (void)taskViewControllerDidComplete:(RKTaskViewController *)taskViewController
{
    NSLog(@"Task Did Complete: triggered");
}

- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKResult *)result
{
    //[super taskViewController:taskViewController didProduceResult:result];
    
    NSLog(@"didProduceResult = %@", result);
    
    if ([result isKindOfClass:[RKSurveyResult class]]) {
        RKSurveyResult *surveyResult = (RKSurveyResult *)result;
        //NSUInteger personAge = 0;
        NSMutableDictionary *surveyResultsDictionary = [NSMutableDictionary dictionary];
        
        for (RKQuestionResult *questionResult in surveyResult.surveyResults) {
            NSLog(@"%@ = [%@] %@ ", [[questionResult itemIdentifier] stringValue], questionResult.answer.class, questionResult.answer);
            [surveyResultsDictionary setObject:(NSNumber *)questionResult.answer forKeyedSubscript:[[questionResult itemIdentifier] stringValue]];
        }
        
        APHHeartAgeResultsViewController *heartAgeResultsVC = [[APHHeartAgeResultsViewController alloc] init];
        heartAgeResultsVC.taskProgress = 0.65;
        heartAgeResultsVC.actualAge = [surveyResultsDictionary[kHeartAgeQuestionAge] integerValue];
        heartAgeResultsVC.heartAge = [self calculateHeartAge:surveyResultsDictionary];
        heartAgeResultsVC.tenYearRisk = @"Your 10-Year risk assessment.";
        heartAgeResultsVC.someImprovement = @"Some suggestions to improve your heart age.";
        
        [self pushViewController:heartAgeResultsVC animated:YES];
    }
}

- (NSUInteger)calculateHeartAge:(RKSurveyResult *)results
{
    return 25;
}

@end
