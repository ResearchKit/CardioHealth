//
//  APHHeartAgeTaskViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 9/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//
#import "APHHeartAgeTaskViewController.h"
#import "APHHeartAgeSummaryViewController.h"
#import "APHHeartAgeAndRiskFactors.h"

// Introduction Step Key
static NSString *kHeartAgeIntroduction = @"HeartAgeIntroduction";
static NSString *kHeartAgeSummary = @"HeartAgeSummary";

@interface APHHeartAgeTaskViewController ()

// This property will hold the parameters that will be used
// for calculating the heart age, 10 year, and lifetime risk table.
@property (nonatomic, strong) NSDictionary *heartAgeParametersLookup;

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
        
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeTestDataAge
                                                                     name:@"YourAge"
                                                                 question:NSLocalizedString(@"What is your age?", @"What is your age?")
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKAnswerFormat *format = [RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"Female", @"Male"]
                                                                         style:RKChoiceAnswerStyleSingleChoice];
        
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataGender
                                                                     name:@"Gender"
                                                                 question:NSLocalizedString(@"What is your biological sex?", @"What is your biological sex?")
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKAnswerFormat *format = [RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"African-American", @"Other"]
                                                                         style:RKChoiceAnswerStyleSingleChoice];

        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataEthnicity
                                                                     name:@"Ethnicity"
                                                                 question:@"What is your ethnic group?"
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(0);

        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataTotalCholesterol
                                                                     name:@"TotalCholesterol"
                                                                 question:NSLocalizedString(@"What is your Total Cholesterol?", @"What is your Total Cholesterol?")
                                                                   answer:format];
        step.optional = NO;

        [steps addObject:step];
    }

    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(0);

        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataHDL
                                                                     name:@"HDLCholesterol"
                                                                 question:NSLocalizedString(@"What is your HDL Cholesterol?", @"What is your HDL Cholesterol?")
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(0);
        
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataSystolicBP
                                                                     name:@"SystolicBP"
                                                                 question:NSLocalizedString(@"What is your Systolic Blood Pressure?", @"What is your Systolic Blood Pressure?")
                                                                   answer:format];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataSmoke
                                                                     name:@"SmokeA"
                                                                 question:NSLocalizedString(@"Have you ever smoked?", @"Have you ever smoked?")
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataCurrentlySmoke
                                                                     name:@"SmokeB"
                                                                 question:NSLocalizedString(@"Do you still smoke?", @"Do you still smoke?")
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataDiabetes
                                                                     name:@"Diabetes"
                                                                 question:NSLocalizedString(@"Do you have Diabetes?", @"Do you have Diabetes?")
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataHypertension
                                                                     name:@"Hypertension"
                                                                 question:NSLocalizedString(@"Are you being treated for Hypertension?",
                                                                                            @"Are you being treated for Hypertension?")
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataFamilyDiabetes
                                                                     name:@"FamilyDiabetes"
                                                                 question:NSLocalizedString(@"Does Diabetes run in your family?", @"Does Diabetes run in your family?")
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataFamilyHeart
                                                                     name:@"ParentHistory"
                                                                 question:NSLocalizedString(@"Have either of your parents had heart problems?", @"Have either of your parents had heart problems?")
                                                                   answer:[RKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeSummary
                                                                     name:@"Heart Age Summary"
                                                                 question:@"No question"
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
    
    // This shows the 'Step 1 of x' in the Navigation bar,
    // not to be confused with a proper progress bar.
    self.showsProgressInNavigationBar = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - StepViewController Delegate Methods

- (void)stepViewControllerWillBePresented:(RKStepViewController *)viewController
{
    NSLog(@"Step: %@ (%@)", viewController.step.name, viewController.step.identifier);
    
    APCAppDelegate *apcAppDelegate = [[UIApplication sharedApplication] delegate];
    
    if ([viewController.step.identifier isEqualToString:kHeartAgeTestDataAge]) {
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
    NSLog(@"Stubbed: Task Completed.");
}

- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKResult *)result
{
    [super taskViewController:taskViewController didProduceResult:result];
    
    if ([result isKindOfClass:[RKSurveyResult class]]) {
        RKSurveyResult *surveyResult = (RKSurveyResult *)result;
        NSMutableDictionary *surveyResultsDictionary = [NSMutableDictionary dictionary];
        
        // Normalize survey results into dictionary.
        for (RKQuestionResult *questionResult in surveyResult.surveyResults) {
            NSString *questionIdentifier = [[questionResult itemIdentifier] stringValue];
            if ([questionIdentifier isEqualToString:kHeartAgekHeartAgeTestDataEthnicity] || [questionIdentifier isEqualToString:kHeartAgekHeartAgeTestDataGender]) {
                [surveyResultsDictionary setObject:(NSString *)questionResult.answer forKey:questionIdentifier];
            } else {
                [surveyResultsDictionary setObject:(NSNumber *)questionResult.answer forKeyedSubscript:questionIdentifier];
            }
        }
        
        // Kickoff heart age calculations
        APHHeartAgeAndRiskFactors *heartAgeAndRiskFactors = [[APHHeartAgeAndRiskFactors alloc] init];
        NSDictionary *heartAgeInfo = [heartAgeAndRiskFactors calculateHeartAgeAndRiskFactors:surveyResultsDictionary];
        
        UIStoryboard *sbHeartAgeSummary = [UIStoryboard storyboardWithName:@"HeartAgeSummary" bundle:nil];
        APHHeartAgeSummaryViewController *heartAgeResultsVC = [sbHeartAgeSummary instantiateInitialViewController];

        heartAgeResultsVC.taskProgress = 0.25;
        heartAgeResultsVC.actualAge = [surveyResultsDictionary[kHeartAgeTestDataAge] integerValue];
        heartAgeResultsVC.heartAge = [heartAgeInfo[@"age"] integerValue];
        heartAgeResultsVC.tenYearRisk = heartAgeInfo[@"tenYearRisk"];
        heartAgeResultsVC.lifetimeRisk = heartAgeInfo[@"lifetimeRisk"];
        heartAgeResultsVC.someImprovement = @"Some suggestions to improve your heart age.";
        
        [self pushViewController:heartAgeResultsVC animated:YES];
    }
}

@end
