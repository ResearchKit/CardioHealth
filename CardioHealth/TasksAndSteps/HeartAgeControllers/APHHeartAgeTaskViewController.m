// 
//  APHHeartAgeTaskViewController.m 
//  MyHeart Counts 
// 
// Copyright (c) 2015, Stanford Medical. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APHHeartAgeTaskViewController.h"
#import "APHHeartAgeAndRiskFactors.h"
#import "APHHeartAgeResultsViewController.h"
#import "APHHeartAgeLearnMoreViewController.h"

static NSString *MainStudyIdentifier = @"com.cardiovascular.heartAgeTest";
static NSString *kKludgeIdentifierForHeartAgeTaskB = @"APHHeartAgeB-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";

// Introduction Step and Summary Key
static NSString *kHeartAgeIntroduction = @"HeartAgeIntroduction";
static NSString *kHeartAgeHasHeartDiseaseIntroduction = @"hasHeartDiseaseIntroduction";
static NSString *kHeartAgeSummary = @"HeartAgeSummary";
static NSString *kHeartAgeResult = @"HeartAgeResult";

// RKForm keys
static NSString *kHeartAgeFormStepBiographicAndDemographic = @"biographicAndDemographic";
static NSString *kHeartAgeFormStepEthnicty = @"ethnicity";
static NSString *kHeartAgeFormStepSmokingHistory = @"smokingHistory";
static NSString *kHeartAgeFormStepCholesterolHdlSystolic = @"cholesterolHdlSystolic";
static NSString *kHeartAgeFormStepBlood = @"blood";
static NSString *const kBloodPressureInstruction = @"bloodPressureInstruction";


static NSString *kHeartAgeFormStepMedicalHistory = @"medicalHistory";

static NSString *kHeartDiseaseInstructionsTitle = @"Heart Age Test";
static NSString *kHeartDiseaseInstructionsDetail = @"You have indicated that you have heart disease. This test is designed for people that do not have heart disease, thus the results will not be applicable to you - but you are welcome to proceed and use the tool.";

@interface APHHeartAgeTaskViewController ()

@property (nonatomic, strong) NSDictionary *heartAgeInfo;
@property (nonatomic, strong) NSDictionary *heartAgeTaskQuestionIndex;
@property (nonatomic, strong) NSMutableDictionary *heartAgeSummaryResults;

@property (assign) BOOL shouldShowResultsStep;
@end

@implementation APHHeartAgeTaskViewController

/*********************************************************************************/
#pragma  mark  -  View Controller Methods
/*********************************************************************************/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

/*********************************************************************************/
#pragma mark - Initialize
/*********************************************************************************/

+ (ORKOrderedTask *)createTask:(APCScheduledTask *)scheduledTask
{
    NSMutableArray *steps = [NSMutableArray array];
    
    APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.dataSubstrate.currentUser.hasHeartDisease) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:kHeartAgeHasHeartDiseaseIntroduction];
            step.title = NSLocalizedString(kHeartDiseaseInstructionsTitle, kHeartDiseaseInstructionsTitle);
            
            step.detailText = NSLocalizedString(kHeartDiseaseInstructionsDetail,
                                          kHeartDiseaseInstructionsDetail);
            
            [steps addObject:step];
        }
    }
    
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:kHeartAgeIntroduction];
        step.title = NSLocalizedString(@"Risk Score and Heart Age", @"Risk Score and Heart Age");
        step.text = NSLocalizedString(@"You will be asked to enter your blood pressure and laboratory data to calculate your risk score and estimate your 'heart age.'", nil);
        

        step.detailText = nil;
        
        
        [steps addObject:step];
    }
    
    // Biographic and Demographic
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        
        
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:kHeartAgeFormStepBiographicAndDemographic title:nil text:NSLocalizedString(@"To calculate risk score and heart age, please enter a few details about yourself.", nil)];
        
        step.optional = NO;
        
        {
            ORKNumericAnswerFormat* format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:NSLocalizedString(@"years", nil)];

            format.maximum = @(150);
            format.minimum = @(18);
    
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataAge
                                                                   text:NSLocalizedString(@"What is your age?", nil)
                                                           answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            ORKHealthKitCharacteristicTypeAnswerFormat *format = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataGender
                                                                 text:NSLocalizedString(@"Gender", nil)
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
                
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    // Biographic and Demographic
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        
        
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:kHeartAgeFormStepEthnicty title:nil text:NSLocalizedString(nil,
                                                                                                                                               nil)];
        
        step.optional = NO;
        
        
        {
            
            NSArray *choices = @[@"I prefer not to indicate an ethnicity", @"Alaska Native", @"American Indian", @"Asian", @"Black", @"Hispanic", @"Pacific Islander", @"White", @"Other"];
            
            ORKAnswerFormat *format = [ORKTextChoiceAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:choices];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataEthnicity
                                                                   text:NSLocalizedString(@"Ethnicity", nil)
                                                           answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kHeartAgeFormStepSmokingHistory title:NSLocalizedString(@"Are you currently smoking cigarettes?",nil) answer:[ORKBooleanAnswerFormat new]];

        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:kHeartAgeFormStepCholesterolHdlSystolic
                                                                title:nil
                                                                 text:NSLocalizedString(@"Cholesterol & Glucose", nil)];
        step.optional = NO;
        
        {
            ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"mg/dL"];
            format.minimum = @(130);
            format.maximum = @(400);
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataTotalCholesterol
                                                                 text:NSLocalizedString(@"Total Cholesterol", nil)
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"mg/dL"];
            format.minimum = @(20);
            format.maximum = @(100);
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataHDL
                                                                 text:NSLocalizedString(@"HDL Cholesterol", nil)
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"emptyIdentifier"
                                                                   text:NSLocalizedString(@"The items below are optional. If you do not know the values you may enter 0.", nil)
                                                           answerFormat:nil];
            [stepQuestions addObject:item];
        }
        
        {
            ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"mg/dL"];
            format.minimum = @(0);
            format.maximum = @(1000);
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataLDL
                                                                   text:NSLocalizedString(@"LDL Cholesterol (optional)", nil)
                                                           answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            ORKHealthKitQuantityTypeAnswerFormat *format = [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose]
                                                                                                                         unit:[HKUnit unitFromString:@"mg/dL"]
                                                                                                                        style:ORKNumericAnswerStyleInteger];
            
            
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestBloodGlucose
                                                                   text:NSLocalizedString(@"Fasting Blood Glucose (optional)", nil)
                                                           answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:kHeartAgeFormStepBlood
                                                              title:nil
                                                               text:NSLocalizedString(@"Blood pressure (typically shown as systolic over diastolic)", nil)];
        step.optional = NO;
        
        {
            ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"mmHg"];
            format.minimum = @(90);
            format.maximum = @(200);
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kBloodPressureInstruction
                                                                   text:NSLocalizedString(@"Systolic Blood Pressure", nil)
                                                           answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            ORKHealthKitQuantityTypeAnswerFormat *format = [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic]
                                                                                                                         unit:[HKUnit unitFromString:@"mmHg"]
                                                                                                                        style:ORKNumericAnswerStyleInteger];
            
            
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataSystolicBloodPressure
                                                                   text:NSLocalizedString(@"Diastolic Blood Pressure", nil)
                                                           answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kHeartAgeTestDataDiabetes title:NSLocalizedString(@"Do you have Diabetes?", nil) answer:[ORKBooleanAnswerFormat new]];
        
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kHeartAgeTestDataHypertension title:NSLocalizedString(@"Are you being treated for Hypertension (High Blood Pressure)?", nil) answer:[ORKBooleanAnswerFormat new]];
        
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kHeartAgeResult
                                                                        title:@"No question"
                                                                       answer:[ORKBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:scheduledTask.task.taskID steps:steps];
    
    return task;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];


    self.shouldShowResultsStep = YES;
        
    self.heartAgeTaskQuestionIndex = @{
                                        kHeartAgeFormStepBiographicAndDemographic: @[
                                                                                    kHeartAgeTestDataAge,
                                                                                    kHeartAgeTestDataGender
                                                                                    ],
                                       
                                                        kHeartAgeFormStepEthnicty: @[
                                                                                    kHeartAgeTestDataEthnicity
                                                                                    ],
                                       
                                                        kHeartAgeTestDataDiabetes: @[
                                                                                    kHeartAgeTestDataDiabetes
                                                                                    ],
                                       
                                                    kHeartAgeTestDataHypertension: @[
                                                                                    kHeartAgeTestDataHypertension
                                                                                    ],
                                       
                                          kHeartAgeFormStepCholesterolHdlSystolic: @[
                                                                                    kHeartAgeTestDataTotalCholesterol,
                                                                                    kHeartAgeTestDataHDL,
                                                                                    kHeartAgeTestDataLDL,
                                                                                    kHeartAgeTestBloodGlucose
                                                                                    ],
                                                            kHeartAgeFormStepBlood: @[
                                                                                    kHeartAgeTestDataSystolicBloodPressure,
                                                                                    kHeartAgeTestDataDiastolicBloodPressure
                                                                                    ],
                                                  kHeartAgeFormStepSmokingHistory: @[
                                                                                    kHeartAgeFormStepSmokingHistory
                                                                                    ]
                                       };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/

- (void)showAlert:(NSString *)title andMessage:(NSString*)message
{
    UIAlertController* alerVC = [UIAlertController alertControllerWithTitle:title
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"OK",
                                                           @"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * __unused action) {
                             [alerVC dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    
    [alerVC addAction:ok];
    
    [self presentViewController:alerVC animated:NO completion:nil];
    
}

- (NSString *)createResultSummary
{
    NSError *error = nil;
    NSString *heartAgeSummary = nil;
    
    if (self.heartAgeSummaryResults) {
        NSData *heartAgeData = [NSJSONSerialization dataWithJSONObject:self.heartAgeSummaryResults options:0 error:&error];
        
        if (heartAgeData) {
            heartAgeSummary = [[NSString alloc] initWithData:heartAgeData encoding:NSUTF8StringEncoding];
        } else {
            APCLogError2(error);
        }
    }
    
    return heartAgeSummary;
}


/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(nullable NSError *)error
{
    if (reason == ORKTaskViewControllerFinishReasonCompleted)
    {
        [self taskViewControllerDidComplete:taskViewController];
    }
    else if (reason == ORKTaskViewControllerFinishReasonDiscarded)
    {
        [self taskViewControllerDidComplete:taskViewController];
    }

    [super taskViewController:taskViewController didFinishWithReason:reason error:error];
}

- (void)taskViewControllerDidComplete: (ORKTaskViewController *) __unused taskViewController{
    
    // We need to create three question results that will hold the value of Heart Age,
    // Ten Year Risk, and Lifetime Risk factors. Ideally we would like to simply
    // amend the self.headerAgeInfo dictionary to the results, but an appropriate
    // RKSurveyQuestionType is not available for adding dictionary to the result;
    // thus we create separate question results for each of these data points.
    NSMutableArray *stepsForSurvey = [NSMutableArray new];
    NSMutableArray *summaryResultForSurvey = [NSMutableArray new];
    
    for (ORKStepResult *stepResult in self.result.results) {
        
        NSMutableArray *stepQuestionResults = [NSMutableArray new];
        
        for (ORKQuestionResult *surveyQuestionResult in stepResult.results) {
            if (![surveyQuestionResult.identifier isEqualToString:kHeartAgeTestDataAge]) {
                [stepQuestionResults addObject:surveyQuestionResult];
            } else {
                ORKNumericQuestionResult *qrAge = [[ORKNumericQuestionResult alloc] initWithIdentifier:kHeartAgeTestDataAge];
                qrAge.questionType = ORKQuestionTypeInteger;
                qrAge.numericAnswer = self.heartAgeSummaryResults[kHeartAgeTestDataAge];
                
                [stepQuestionResults addObject:qrAge];
            }
        }
        
        stepResult.results = stepQuestionResults;
        
        [stepsForSurvey addObject:stepResult];
    }
    
    ORKNumericQuestionResult *qrHeartAge = [[ORKNumericQuestionResult alloc] initWithIdentifier:kSummaryHeartAge];
    qrHeartAge.questionType = ORKQuestionTypeInteger;
    qrHeartAge.numericAnswer = self.heartAgeInfo[kSummaryHeartAge];
    
    [summaryResultForSurvey addObject:qrHeartAge];
    
    
    ORKNumericQuestionResult *qrTenYearRisk = [[ORKNumericQuestionResult alloc] initWithIdentifier:kSummaryTenYearRisk];
    qrTenYearRisk.questionType = ORKQuestionTypeDecimal;
    qrTenYearRisk.numericAnswer = self.heartAgeInfo[kSummaryTenYearRisk];
    
    [summaryResultForSurvey addObject:qrTenYearRisk];
    
    ORKNumericQuestionResult *qrLifetimeRisk = [[ORKNumericQuestionResult alloc] initWithIdentifier:kSummaryLifetimeRisk];
    qrLifetimeRisk.questionType = ORKQuestionTypeDecimal;
    qrLifetimeRisk.numericAnswer = self.heartAgeInfo[kSummaryLifetimeRisk];
    
    [summaryResultForSurvey addObject:qrLifetimeRisk];
    
    ORKStepResult *summaryStepResult = [[ORKStepResult alloc] initWithStepIdentifier:kHeartAgeSummary
                                                                             results:summaryResultForSurvey];
    
    [stepsForSurvey addObject:summaryStepResult];
    
    self.result.results = [stepsForSurvey copy];
}

- (ORKStepViewController *)taskViewController:(ORKTaskViewController *)taskViewController viewControllerForStep:(ORKStep *)step
{
    
    ORKStepViewController *stepVC = nil;
    
    if ([step.identifier isEqualToString:kHeartAgeResult]) {
        
        NSMutableDictionary *surveyResultsDictionary = [NSMutableDictionary dictionary];
        
        // Normalize survey results into dictionary.
        for (ORKStepResult *survey in taskViewController.result.results) {
            if (![survey.identifier isEqualToString:kHeartAgeIntroduction]) {
                NSArray *qrIdentifiers = self.heartAgeTaskQuestionIndex[survey.identifier];
                
                [survey.results enumerateObjectsUsingBlock:^(ORKQuestionResult *questionResult, NSUInteger idx, BOOL * __unused stop) {
                    NSString *questionIdentifier = [qrIdentifiers objectAtIndex:idx];
                    
                    if ([questionIdentifier isEqualToString:kHeartAgeTestDataEthnicity]) {
                        APCAppDelegate *apcDelegate = (APCAppDelegate*)[[UIApplication sharedApplication] delegate];

                        ORKChoiceQuestionResult *textResult = (ORKChoiceQuestionResult *) questionResult;

                        NSString *ethnicity = @"";
                        if ([textResult.choiceAnswers firstObject] != nil) {
                        
                            ethnicity = (NSString *)[textResult.choiceAnswers firstObject];
                        }

                        // persist ethnicity to the datastore
                        [apcDelegate.dataSubstrate.currentUser setEthnicity:ethnicity];
                        
                        [surveyResultsDictionary setObject:ethnicity forKey:questionIdentifier];
                    } else if ([questionIdentifier isEqualToString:kHeartAgeTestDataGender]) {
                        ORKChoiceQuestionResult *textResult = (ORKChoiceQuestionResult *) questionResult;
                        
                        NSString *selectedGender = @"";
                        if ([textResult.choiceAnswers firstObject] != nil) {
                            
                            selectedGender = ([(NSString *)[textResult.choiceAnswers firstObject] isEqualToString:@"HKBiologicalSexFemale"]) ? kHeartAgeTestDataGenderFemale :kHeartAgeTestDataGenderMale;
                        }
                        
                        [surveyResultsDictionary setObject:selectedGender
                                                    forKey:questionIdentifier];
                    } else if ([questionIdentifier isEqualToString:kHeartAgeTestDataAge])
                    {
                        ORKNumericQuestionResult*   ageResult   = (ORKNumericQuestionResult *) questionResult;
                        NSNumber*                   currentAge  = @(0);
                        
                        if (ageResult.numericAnswer != nil)
                        {
                            currentAge = ageResult.numericAnswer;
                        }
                    
                        [surveyResultsDictionary setObject:currentAge forKey:questionIdentifier];
                    }
                    else if ([questionResult isKindOfClass:[ORKBooleanQuestionResult class]]) {
                        ORKBooleanQuestionResult *numericResult = (ORKBooleanQuestionResult *) questionResult;
                        
                        NSNumber *answer = @(0);
                        
                        if (numericResult.booleanAnswer != nil) {
                            answer = numericResult.booleanAnswer;
                        }
                        
                        [surveyResultsDictionary setObject:answer forKey:questionIdentifier];
                    } else if ([questionResult isKindOfClass:[ORKNumericQuestionResult class]]) {
                        ORKNumericQuestionResult *numericResult = (ORKNumericQuestionResult *) questionResult;
                        
                        NSNumber *answer = @(0);
                        
                        if (numericResult.numericAnswer != nil) {
                            answer = numericResult.numericAnswer;
                        }
                        
                        [surveyResultsDictionary setObject:answer forKey:questionIdentifier];
                    }
                }];
            }
        }
     
        self.heartAgeSummaryResults = [NSMutableDictionary dictionaryWithDictionary:surveyResultsDictionary];
     
        // Kickoff heart age calculations
        
        APHHeartAgeAndRiskFactors *heartAgeAndRiskFactors = [[APHHeartAgeAndRiskFactors alloc] init];
        self.heartAgeInfo = [heartAgeAndRiskFactors calculateHeartAgeAndRiskFactors:surveyResultsDictionary];
        
        NSDictionary *optimalRiskFactors = [heartAgeAndRiskFactors calculateRiskWithOptimalFactors:surveyResultsDictionary];
        
        UIStoryboard *sbHeartAgeSummary = [UIStoryboard storyboardWithName:@"APHHeartAgeSummary" bundle:nil];
        APHHeartAgeResultsViewController *heartAgeResultsVC = [sbHeartAgeSummary instantiateInitialViewController];
        
        heartAgeResultsVC.delegate = self;
        heartAgeResultsVC.step = step;
        heartAgeResultsVC.actualAge = [surveyResultsDictionary[kHeartAgeTestDataAge] integerValue];
        heartAgeResultsVC.heartAge = [self.heartAgeInfo[kSummaryHeartAge] integerValue];
        heartAgeResultsVC.tenYearRisk = self.heartAgeInfo[kSummaryTenYearRisk];
        heartAgeResultsVC.lifetimeRisk = self.heartAgeInfo[kSummaryLifetimeRisk];
        heartAgeResultsVC.optimalTenYearRisk = optimalRiskFactors[kSummaryTenYearRisk];
        heartAgeResultsVC.optimalLifetimeRisk = optimalRiskFactors[kSummaryLifetimeRisk];
        
        // Add the heart age summary to summart results
        [self.heartAgeSummaryResults addEntriesFromDictionary:self.heartAgeInfo];
        
        stepVC = heartAgeResultsVC;
    }
    
    return stepVC;
}


- (BOOL)taskViewController:(ORKTaskViewController *) __unused taskViewController hasLearnMoreForStep:(ORKStep *)step {
    
    BOOL hasLearnMore = NO;
    
    if ([step.identifier isEqualToString:kHeartAgeIntroduction])
    {
        hasLearnMore = YES;
        
    }
    
    return hasLearnMore;
}

- (void)taskViewController:(ORKTaskViewController *) __unused taskViewController learnMoreForStep:(ORKStepViewController *)stepViewController {
    
    
    if ([stepViewController.step.identifier isEqualToString:kHeartAgeIntroduction]) {
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"APHHeartAgeLearnMoreViewController"
                                                                 bundle:nil];
        
        APHHeartAgeLearnMoreViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"APHHeartAgeLearnMoreViewController"];
        
        controller.taskIdentifier = self.scheduledTask.task.taskID;
    
        
        [self presentViewController:controller animated:YES completion:nil];
    
    }
}

@end
