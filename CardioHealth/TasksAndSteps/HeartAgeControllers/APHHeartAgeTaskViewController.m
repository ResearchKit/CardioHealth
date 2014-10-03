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

// Lookup Keys
static NSString *kLookupOptimalRiskFactors = @"optimal-risk-factors";
static NSString *kLookupOptimalRiskFactorTotalCholesterol = @"total-cholesterol";
static NSString *kLookupOptimalRiskFactorHDL = @"hdl-c";
static NSString *kLookupOptimalRiskFactorSystolicBP = @"systolic-bp";
static NSString *kLookupParameters = @"parameters";
static NSString *kLookupGenderFemale = @"Female";
static NSString *kLookupGenderMale = @"Male";
static NSString *kLookupEthnicityAfricanAmerican = @"African-American";
static NSString *kLookupEthnicityOther = @"Other";
static NSString *kLookupBaseline = @"baseline-10-year-survival";
static NSString *kLookupPopulationMean = @"population-mean";
static NSString *kLookupCoefficients = @"coefficients";
static NSString *kLookupCoefficient1 = @"coefficient-1";
static NSString *kLookupCoefficient2 = @"coefficient-2";
static NSString *kLookupCoefficient3 = @"coefficient-3";


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
        RKAnswerFormat *format = [RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"African-American", @"Other"]
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
    
    // Heart age lookup parameters
    self.heartAgeParametersLookUp = @{
                            kLookupOptimalRiskFactors: @{
                                    kLookupOptimalRiskFactorTotalCholesterol: @170,
                                    kLookupOptimalRiskFactorHDL: @50,
                                    kLookupOptimalRiskFactorSystolicBP: @110
                                },
                            kLookupGenderFemale: @{
                                    kLookupEthnicityAfricanAmerican: @{
                                            kLookupParameters: @{
                                                    kLookupPopulationMean: @86.61,
                                                    kLookupBaseline: @0.9533,
                                                    kLookupCoefficient1: @61.5776393901894,
                                                    kLookupCoefficient2: @6.00638641400169,
                                                    kLookupCoefficient3: @0,
                                                    kLookupCoefficients: @[@17.1141, @0, @0.9396, @0, @-18.9196, @4.4748,
                                                                           @29.2907, @-6.4321, @27.8197, @-6.0873, @0.6908, @0, @0.8738]
                                                }
                                        },
                                    kLookupEthnicityOther: @{
                                            kLookupParameters: @{
                                                    kLookupPopulationMean: @-29.18,
                                                    kLookupBaseline: @0.9665,
                                                    kLookupCoefficient1: @25.6201025458129,
                                                    kLookupCoefficient2: @-33.4729158888813,
                                                    kLookupCoefficient3: @4.884,
                                                    kLookupCoefficients: @[@-29.799, @4.884, @13.54, @-3.114, @-13.578, @3.149,
                                                                           @2.019, @0, @1.957, @0, @7.574,@-1.665, @0.661]
                                                }
                                        }
                                },
                            kLookupGenderMale: @{
                                    kLookupEthnicityAfricanAmerican: @{
                                            kLookupParameters: @{
                                                    kLookupPopulationMean: @19.54,
                                                    kLookupBaseline: @0.8954,
                                                    kLookupCoefficient1: @8.85318904704122,
                                                    kLookupCoefficient2: @2.469,
                                                    kLookupCoefficient3: @0,
                                                    kLookupCoefficients: @[@2.4690, @0.0000, @0.3020, @0.0000, @-0.3070,
                                                                           @0.0000, @1.9160, @0.0000, @1.8090, @0.0000, @0.5490, @0.0000, @0.6450]
                                                    }
                                            },
                                    kLookupEthnicityOther: @{
                                            kLookupParameters: @{
                                                    kLookupPopulationMean: @61.18,
                                                    kLookupBaseline: @0.9144,
                                                    kLookupCoefficient1: @37.9092024262437,
                                                    kLookupCoefficient2: @5.58260166030049,
                                                    kLookupCoefficient3: @0,
                                                    kLookupCoefficients: @[@12.344, @0, @11.853, @-2.664, @-7.990, @1.769,
                                                                           @1.797, @0, @1.764, @0, @7.837, @-1.795, @0.658]
                                                    }
                                        }
                                }
                           };
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

- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKResult *)result
{
    [super taskViewController:taskViewController didProduceResult:result];
    
    if ([result isKindOfClass:[RKSurveyResult class]]) {
        RKSurveyResult *surveyResult = (RKSurveyResult *)result;
        NSMutableDictionary *surveyResultsDictionary = [NSMutableDictionary dictionary];
        
        // Normalize survey results into dictionary.
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
}

@end
