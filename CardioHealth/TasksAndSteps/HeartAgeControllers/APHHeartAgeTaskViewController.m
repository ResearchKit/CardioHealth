// 
//  APHHeartAgeTaskViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 

#import "APHHeartAgeTaskViewController.h"
#import "APHHeartAgeAndRiskFactors.h"
#import "APHHeartAgeResultsViewController.h"
#import "APHHeartAgeLearnMoreViewController.h"

static NSString *MainStudyIdentifier = @"com.cardiovascular.heartAgeTest";
static NSString *kKludgeIdentifierForHeartAgeTaskB = @"APHHeartAgeB-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";

// Introduction Step and Summary Key
static NSString *kHeartAgeIntroduction = @"HeartAgeIntroduction";
static NSString *kHeartAgeSummary = @"HeartAgeSummary";
static NSString *kHeartAgeResult = @"HeartAgeResult";

// RKForm keys
static NSString *kHeartAgeFormStepBiographicAndDemographic = @"biographicAndDemographic";
static NSString *kHeartAgeFormStepSmokingHistory = @"smokingHistory";
static NSString *kHeartAgeFormStepCholesterolHdlSystolic = @"cholesterolHdlSystolic";
static NSString *kHeartAgeTestDataDiastolicBloodPressure = @"cholesterolHdlDiastolic";

static NSString *kHeartAgeFormStepMedicalHistory = @"medicalHistory";

@interface APHHeartAgeTaskViewController ()

@property (nonatomic, strong) NSDictionary *heartAgeInfo;
@property (nonatomic, strong) NSDictionary *heartAgeTaskQuestionIndex;
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
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:kHeartAgeIntroduction];
        step.title = NSLocalizedString(@"Heart Age Test", @"Heart Age Test");
        step.text = NSLocalizedString(@"The following few details about you will be used to calculate your heart age.",
                                      @"Requesting user to provide information to calculate their heart age.");
        

        step.detailText = nil;
        
        
        [steps addObject:step];
    }
    
    // Biographic and Demographic
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        
        
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:kHeartAgeFormStepBiographicAndDemographic title:nil text:NSLocalizedString(@"To calculate your heart age, please enter a few details about yourself.",
                                                                                                                            @"To calculate your heart age, please enter a few details about yourself.")];
        
        step.optional = NO;
        
        {
            ORKHealthKitCharacteristicTypeAnswerFormat *format = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataAge
                                                                 text:NSLocalizedString(@"Date of birth", @"Date of birth")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            ORKHealthKitCharacteristicTypeAnswerFormat *format = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataGender
                                                                 text:NSLocalizedString(@"Gender", @"Gender")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            
            NSArray *choices = @[@"I prefer not to indicate an ethnicity", @"Alaska Native", @"American Indian", @"Asian", @"Black", @"Hispanic", @"Pacific Islander", @"White", @"Other"];
            
            ORKAnswerFormat *format = [ORKTextChoiceAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:choices];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataEthnicity
                                                                 text:NSLocalizedString(@"Ethnicity", @"Ethnicity")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kHeartAgeFormStepSmokingHistory title:NSLocalizedString(@"Smoking History", @"Smoking History") answer:[ORKBooleanAnswerFormat new]];

        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:kHeartAgeFormStepCholesterolHdlSystolic
                                                                title:nil
                                                                 text:NSLocalizedString(@"Cholesterol & Blood Pressure",
                                                                                        @"Cholesterol & Blood Pressure")];
        step.optional = NO;
        
        {
            ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"mg/dl"];
            format.minimum = @(1);
            format.maximum = @(1000);
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataTotalCholesterol
                                                                 text:NSLocalizedString(@"Total Cholesterol",
                                                                                        @"Total Cholesterol")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"mg/dl"];
            format.minimum = @(1);
            format.maximum = @(250);
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataHDL
                                                                 text:NSLocalizedString(@"HDL Cholesterol", @"HDL Cholesterol")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            ORKHealthKitQuantityTypeAnswerFormat *format = [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic]
                                                                                                                           unit:[HKUnit unitFromString:@"mmHg"]
                                                                                                                          style:ORKNumericAnswerStyleInteger];
            
            
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataSystolicBloodPressure
                                                                 text:NSLocalizedString(@"Systolic Blood Pressure",
                                                                                        @"Systolic Blood Pressure")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            ORKHealthKitQuantityTypeAnswerFormat *format = [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic]
                                                                                                                         unit:[HKUnit unitFromString:@"mmHg"]
                                                                                                                        style:ORKNumericAnswerStyleInteger];
            
            
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kHeartAgeTestDataDiastolicBloodPressure
                                                                   text:NSLocalizedString(@"Diastolic Blood Pressure",
                                                                                          @"Diastolic Blood Pressure")
                                                           answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kHeartAgeTestDataDiabetes title:NSLocalizedString(@"Do you have Diabetes?", @"Do you have Diabetes?") answer:[ORKBooleanAnswerFormat new]];
        
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kHeartAgeTestDataHypertension title:NSLocalizedString(@"Are you being treated for Hypertension (High Blood Pressure)?", @"Are you being treated for Hypertension (High Blood Pressure)?") answer:[ORKBooleanAnswerFormat new]];
        
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
                                               kHeartAgeTestDataGender,
                                               kHeartAgeTestDataEthnicity],
                                       kHeartAgeFormStepMedicalHistory: @[
                                               kHeartAgeTestDataDiabetes,
                                               kHeartAgeTestDataHypertension],
                                       kHeartAgeFormStepCholesterolHdlSystolic: @[
                                               kHeartAgeTestDataTotalCholesterol,
                                               kHeartAgeTestDataHDL,
                                               kHeartAgeTestDataSystolicBloodPressure,
                                               kHeartAgeTestDataDiastolicBloodPressure],
                                       kHeartAgeFormStepSmokingHistory: @[
                                               kHeartAgeTestDataSmoke,
                                               kHeartAgeTestDataCurrentlySmoke]
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
                         handler:^(UIAlertAction * action) {
                             [alerVC dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    
    [alerVC addAction:ok];
    
    [self presentViewController:alerVC animated:NO completion:nil];
    
}


/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithResult:(ORKTaskViewControllerResult)result error:(NSError *)error
{
    if (result == ORKTaskViewControllerResultCompleted)
    {
        [self taskViewControllerDidComplete:taskViewController];
        [super taskViewController:taskViewController didFinishWithResult:result error:error];
    }
}

- (void)taskViewControllerDidComplete: (ORKTaskViewController *)taskViewController{
    
    // We need to create three question results that will hold the value of Heart Age,
    // Ten Year Risk, and Lifetime Risk factors. Ideally we would like to simply
    // amend the self.headerAgeInfo dictionary to the results, but an appropriate
    // RKSurveyQuestionType is not available for adding dictionary to the result;
    // thus we create separate question results for each of these data points.
    
    NSMutableArray *questionResultsForSurvey = [NSMutableArray array];
    
    for (ORKStepResult *stepResult in self.result.results) {
        for (ORKQuestionResult *surveyQuestionResult in stepResult.results) {
            [questionResultsForSurvey addObject:surveyQuestionResult];
        }
    }
    
    ORKNumericQuestionResult *qrHeartAge = [[ORKNumericQuestionResult alloc] initWithIdentifier:kSummaryHeartAge];
    qrHeartAge.questionType = ORKQuestionTypeInteger;
    qrHeartAge.numericAnswer = self.heartAgeInfo[kSummaryHeartAge];
    [questionResultsForSurvey addObject:qrHeartAge];
    
    
    ORKNumericQuestionResult *qrTenYearRisk = [[ORKNumericQuestionResult alloc] initWithIdentifier:kSummaryTenYearRisk];
    qrTenYearRisk.questionType = ORKQuestionTypeDecimal;
    qrTenYearRisk.numericAnswer = self.heartAgeInfo[kSummaryTenYearRisk];
    
    [questionResultsForSurvey addObject:qrTenYearRisk];
    
    ORKNumericQuestionResult *qrLifetimeRisk = [[ORKNumericQuestionResult alloc] initWithIdentifier:kSummaryLifetimeRisk];
    qrLifetimeRisk.questionType = ORKQuestionTypeDecimal;
    qrLifetimeRisk.numericAnswer = self.heartAgeInfo[kSummaryLifetimeRisk];
    
    [questionResultsForSurvey addObject:qrLifetimeRisk];
    
    self.result.results = questionResultsForSurvey;
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
                
                [survey.results enumerateObjectsUsingBlock:^(ORKQuestionResult *questionResult, NSUInteger idx, BOOL *stop) {
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
                    } else if ([questionIdentifier isEqualToString:kHeartAgeTestDataAge]) {
                        ORKDateQuestionResult *dob = (ORKDateQuestionResult *) questionResult;
                        
                        //Default date
                        NSDate *dateOfBirth = [NSDate date];
                        
                        if (dob.dateAnswer != nil) {
                            dateOfBirth = dob.dateAnswer;                        // Compute the age of the user.
                        }
                    
                        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                                          fromDate:dateOfBirth
                                                                                            toDate:[NSDate date] // today
                                                                                           options:NSCalendarWrapComponents];
                        
                        NSUInteger usersAge = [ageComponents year];
                        [surveyResultsDictionary setObject:[NSNumber numberWithInteger:usersAge] forKey:questionIdentifier];
                    } else if ([ORKQuestionResult isKindOfClass:[ORKBooleanQuestionResult class]]) {
                        ORKBooleanQuestionResult *numericResult = (ORKBooleanQuestionResult *) questionResult;
                        
                        NSNumber *answer = @(0);
                        
                        if (numericResult.booleanAnswer != nil) {
                            answer = numericResult.booleanAnswer;
                        }
                        
                        [surveyResultsDictionary setObject:answer forKey:questionIdentifier];
                    } else if ([ORKQuestionResult isKindOfClass:[ORKNumericQuestionResult class]]) {
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
        
        stepVC = heartAgeResultsVC;
    }
    
    return stepVC;
}


- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController hasLearnMoreForStep:(ORKStep *)step {
    
    BOOL hasLearnMore = NO;
    
    if ([step.identifier isEqualToString:kHeartAgeIntroduction])
    {
        hasLearnMore = YES;
        
    }
    
    return hasLearnMore;
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController learnMoreForStep:(ORKStepViewController *)stepViewController {
    
    
    if ([stepViewController.step.identifier isEqualToString:kHeartAgeIntroduction]) {
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"APHHeartAgeLearnMoreViewController"
                                                                 bundle:nil];
        
        APHHeartAgeLearnMoreViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"APHHeartAgeLearnMoreViewController"];
        
        controller.taskIdentifier = self.scheduledTask.task.taskID;
    
        
        [self presentViewController:controller animated:YES completion:nil];
    
    }
}


@end
