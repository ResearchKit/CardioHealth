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
        
        // Kickoff heart age calculations
        NSDictionary *heartAgeInfo = [self calculateHeartAgeAndTenYearRisk:surveyResultsDictionary];
        
        APHHeartAgeResultsViewController *heartAgeResultsVC = [[APHHeartAgeResultsViewController alloc] init];
        heartAgeResultsVC.taskProgress = 0.65;
        heartAgeResultsVC.actualAge = [surveyResultsDictionary[kHeartAgeQuestionAge] integerValue];
        heartAgeResultsVC.heartAge = [heartAgeInfo[@"age"] integerValue];
        heartAgeResultsVC.tenYearRisk = heartAgeInfo[@"tenYearRisk"];
        heartAgeResultsVC.someImprovement = @"Some suggestions to improve your heart age.";
        
        [self pushViewController:heartAgeResultsVC animated:YES];
    }
}

/**
 * @brief  This is the entry point into calculating the heart age and all associated coefficients.
 * @param  results   an NSDictionary of results collected from the survey.
 * @return NSDictionary is returned with the keys: 'age' and 'tenYearRisk' whoes value is an NSNumber.
 * @note   This method relies on the heartAgeLookup property to retrieve constant/precomputed values
 *         that are needed to perform all of the calculations.
 */
- (NSDictionary *)calculateHeartAgeAndTenYearRisk:(NSDictionary *)results
{
    NSUInteger heartAge = 0;
    NSUInteger actualAge = [results[kHeartAgeQuestionAge] integerValue];
    
    NSString *gender = results[kHeartAgeQuestionGender];
    NSString *ethnicity = results[kHeartAgeQuestionEthnicity];
    
    // Coefficients used for computing individual sum.
    NSArray *coefficients = self.heartAgeParametersLookUp[gender][ethnicity][kLookupParameters][kLookupCoefficients];
    
    double baseline = [self.heartAgeParametersLookUp[gender][ethnicity][kLookupParameters][kLookupBaseline] doubleValue];
    double populationMean = [self.heartAgeParametersLookUp[gender][ethnicity][kLookupParameters][kLookupPopulationMean] doubleValue];
    
    // Computing log of data that is used in multiple place for computing other coefficients.
    double logActualAge = log(actualAge);
    double logTotalCholesterol = log([results[kHeartAgeQuestionTotalCholesterol] doubleValue]);
    double logHDLC = log([results[kHeartAgeQuestionHDL] doubleValue]);
    double logTreatedSystolic = log([results[kHeartAgeQuestionSystolicBP] doubleValue]) * [results[kHeartAgeQuestionHypertension] integerValue];
    double logUnTreatedSystolic = log([results[kHeartAgeQuestionSystolicBP] doubleValue]) * (1 - [results[kHeartAgeQuestionHypertension] integerValue]);
    
    double individualSum = 0;
    
    // Looping through individual coefficients to compute the individual sum.
    for (NSNumber *obj in coefficients) {
        
        NSUInteger idx = [coefficients indexOfObject:obj];
        double coefficientTimesValue = 0;
        
        switch (idx) {
            case 0:
                coefficientTimesValue = logActualAge * [obj doubleValue];
                break;
            case 1:
                coefficientTimesValue = pow(logActualAge, 2) * [obj doubleValue];
                break;
            case 2:
                coefficientTimesValue = logTotalCholesterol * [obj doubleValue];
                break;
            case 3:
                coefficientTimesValue = (logActualAge * logTotalCholesterol) * [obj doubleValue];
                break;
            case 4:
                coefficientTimesValue = logHDLC * [obj doubleValue];
                break;
            case 5:
                coefficientTimesValue = (logActualAge * logHDLC) * [obj doubleValue];
                break;
            case 6:
                coefficientTimesValue = logTreatedSystolic * [obj doubleValue];
                break;
            case 7:
                coefficientTimesValue = (logActualAge * logTreatedSystolic) * [obj doubleValue];
                break;
            case 8:
                coefficientTimesValue = logUnTreatedSystolic * [obj doubleValue];
                break;
            case 9:
                coefficientTimesValue = (logActualAge * logUnTreatedSystolic) * [obj doubleValue];
                break;
            case 10:
                coefficientTimesValue = [results[kHeartAgeQuestionSmokeB] integerValue] * [obj doubleValue];
                break;
            case 11:
                coefficientTimesValue = (logActualAge * [results[kHeartAgeQuestionSmokeB] integerValue]) * [obj doubleValue];
                break;
            case 12:
                coefficientTimesValue = [results[kHeartAgeQuestionDiabetes] integerValue] * [obj doubleValue];
                break;
            default:
                NSAssert(YES, @"You have more objects in the coefficient array.");
                break;
        }
        
        individualSum += coefficientTimesValue;
        
        NSLog(@"Coefficient x Value (%lu): %f", idx, coefficientTimesValue);
    }
    
    NSLog(@"Individual Sum: %f", individualSum);
    
    // Estimated 10 year risk with Optimal Risk  Factors for an individual
    double individualEstimatedTenYearRisk = 1 - pow(baseline, exp(individualSum - populationMean));
    
    NSLog(@"Estimated 10-Year Risk of Hard ASCVD: %f", individualEstimatedTenYearRisk);
    
    heartAge = [self findHeartAgeForRiskValue:individualEstimatedTenYearRisk forGender:gender forEthnicity:ethnicity];
    
    return @{@"age": [NSNumber numberWithDouble:heartAge], @"tenYearRisk": [NSNumber numberWithDouble:individualEstimatedTenYearRisk]};
}

- (NSInteger)findHeartAgeForRiskValue:(double)riskValue forGender:(NSString *)gender forEthnicity:(NSString *)ethnicity
{
    
    NSArray *heartAgeLookup = [self generateHeartAgeLookupTableForGender:gender ethnicity:ethnicity];
    
    NSUInteger index = [heartAgeLookup indexOfObject:@(riskValue)
                                       inSortedRange:NSMakeRange(0, heartAgeLookup.count)
                                             options:NSBinarySearchingFirstEqual | NSBinarySearchingInsertionIndex
                                     usingComparator:^NSComparisonResult(id a, id b) {
                                         NSNumber *riskA = [(NSDictionary *)a objectForKey:@"risk"];
                                         NSNumber *riskB = (NSNumber *)b;
                                         return [riskA compare:riskB];
                                     }];
    if (index == 0) {
        return [[[heartAgeLookup objectAtIndex:index] objectForKey:@"age"] integerValue];
    } else if (index == heartAgeLookup.count) {
        return [[[heartAgeLookup lastObject] objectForKey:@"age"] integerValue];
    } else {
        double leftDifference = riskValue - [[heartAgeLookup[index - 1] objectForKey:@"risk" ] doubleValue];
        double rightDifference = [[heartAgeLookup[index] objectForKey:@"risk" ] doubleValue] - riskValue;
        
        if (leftDifference < rightDifference) {
            --index;
        }
        
        return [[heartAgeLookup[index] objectForKey:@"age"] integerValue];
    }
}
}

@end
