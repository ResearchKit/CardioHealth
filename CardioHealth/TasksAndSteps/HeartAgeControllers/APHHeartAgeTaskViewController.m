// 
//  APHHeartAgeTaskViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 

#import "APHHeartAgeTaskViewController.h"
#import "APHHeartAgeAndRiskFactors.h"
#import "APHHeartAgeResultsViewController.h"
#import "APHHeartAgeIntroStepViewController.h"

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
    
    self.navigationBar.topItem.title = NSLocalizedString(@"Heart Age Test", nil);
    
    if ([self.task.identifier isEqualToString:kKludgeIdentifierForHeartAgeTaskB]) {
        
        self.navigationBar.topItem.title = NSLocalizedString(@"Heart and Stroke Risk", nil);
    }
}

/*********************************************************************************/
#pragma mark - Initialize
/*********************************************************************************/

+ (RKSTOrderedTask *)createTask:(APCScheduledTask *)scheduledTask
{
    NSMutableArray *steps = [NSMutableArray array];
    
    {
        RKSTInstructionStep *step = [[RKSTInstructionStep alloc] initWithIdentifier:kHeartAgeIntroduction];
        step.title = NSLocalizedString(@"Heart Age Test", @"Heart Age Test");
        step.text = NSLocalizedString(@"The following few details about you will be used to calculate your heart age.",
                                      @"Requesting user to provide information to calculate their heart age.");
        

        step.detailText = nil;
        
        
        [steps addObject:step];
    }
    
    // Biographic and Demographic
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        
        
        RKSTFormStep *step = [[RKSTFormStep alloc] initWithIdentifier:kHeartAgeFormStepBiographicAndDemographic title:nil text:NSLocalizedString(@"To calculate your heart age, please enter a few details about yourself.",
                                                                                                                            @"To calculate your heart age, please enter a few details about yourself.")];
        
        step.optional = NO;
        
        {
            RKSTHealthKitCharacteristicTypeAnswerFormat *format = [RKSTHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]];
            
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kHeartAgeTestDataAge
                                                                 text:NSLocalizedString(@"Date of birth", @"Date of birth")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            RKSTHealthKitCharacteristicTypeAnswerFormat *format = [RKSTHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]];
            
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kHeartAgeTestDataGender
                                                                 text:NSLocalizedString(@"Gender", @"Gender")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            
            NSArray *choices = @[@"I prefer not to indicate an ethnicity", @"Alaska Native", @"American Indian", @"Asian", @"Black", @"Hispanic", @"Pacific Islander", @"White", @"Other"];
            
            RKSTAnswerFormat *format = [RKSTTextChoiceAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice textChoices:choices];
            
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kHeartAgeTestDataEthnicity
                                                                 text:NSLocalizedString(@"Ethnicity", @"Ethnicity")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        RKSTFormStep *step = [[RKSTFormStep alloc] initWithIdentifier:kHeartAgeFormStepSmokingHistory
                                                            title:nil
                                                             text:NSLocalizedString(@"Smoking History",
                                                                                    @"Smoking History")];
        step.optional = NO;
        
        {
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kHeartAgeTestDataSmoke
                                                                 text:NSLocalizedString(@"Do you smoke cigarettes?",
                                                                                        @"Do you smoke cigarettes?")
                                                         answerFormat:[RKSTBooleanAnswerFormat new]];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        RKSTFormStep *step = [[RKSTFormStep alloc] initWithIdentifier:kHeartAgeFormStepCholesterolHdlSystolic
                                                                title:nil
                                                                 text:NSLocalizedString(@"Cholesterol & Blood Pressure",
                                                                                        @"Cholesterol & Blood Pressure")];
        step.optional = NO;
        
        {
            RKSTNumericAnswerFormat *format = [RKSTNumericAnswerFormat integerAnswerFormatWithUnit:@"mg/dl"];
            format.minimum = @(0);
            format.maximum = @(1000);
            
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kHeartAgeTestDataTotalCholesterol
                                                                 text:NSLocalizedString(@"Total Cholesterol",
                                                                                        @"Total Cholesterol")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            RKSTNumericAnswerFormat *format = [RKSTNumericAnswerFormat integerAnswerFormatWithUnit:@"mg/dl"];
            format.minimum = @(0);
            format.maximum = @(1000);
            
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kHeartAgeTestDataHDL
                                                                 text:NSLocalizedString(@"HDL Cholesterol", @"HDL Cholesterol")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            RKSTHealthKitQuantityTypeAnswerFormat *format = [RKSTHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic]
                                                                                                                           unit:[HKUnit unitFromString:@"mmHg"]
                                                                                                                          style:RKNumericAnswerStyleInteger];
            
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kHeartAgeTestDataSystolicBloodPressure
                                                                 text:NSLocalizedString(@"Systolic Blood Pressure",
                                                                                        @"Systolic Blood Pressure")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        RKSTFormStep *step = [[RKSTFormStep alloc] initWithIdentifier:kHeartAgeFormStepMedicalHistory
                                                                title:nil
                                                                 text:NSLocalizedString(@"Your Medical History",
                                                                                        @"Your medical history")];
        step.optional = NO;
        {
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kHeartAgeTestDataDiabetes
                                                                 text:NSLocalizedString(@"Do you have Diabetes?",
                                                                                        @"Do you have Diabetes?")
                                                         answerFormat:[RKSTBooleanAnswerFormat new]];
            [stepQuestions addObject:item];
        }
        
        {
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kHeartAgeTestDataHypertension
                                                                 text:NSLocalizedString(@"Are you being treated for Hypertension (High Blood Pressure)?",
                                                                                        @"Are you being treated for Hypertension (High Blood Pressure)?")
                                                         answerFormat:[RKSTBooleanAnswerFormat new]];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep *step = [RKSTQuestionStep questionStepWithIdentifier:kHeartAgeResult
                                                                        title:@"No question"
                                                                       answer:[RKSTBooleanAnswerFormat new]];
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithIdentifier:scheduledTask.task.taskID steps:steps];
    
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
                                               kHeartAgeTestDataSystolicBloodPressure],
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

- (void)taskViewControllerDidComplete: (RKSTTaskViewController *)taskViewController{
    
    // We need to create three question results that will hold the value of Heart Age,
    // Ten Year Risk, and Lifetime Risk factors. Ideally we would like to simply
    // amend the self.headerAgeInfo dictionary to the results, but an appropriate
    // RKSurveyQuestionType is not available for adding dictionary to the result;
    // thus we create separate question results for each of these data points.
    
    NSMutableArray *questionResultsForSurvey = [NSMutableArray array];
    
    for (RKSTStepResult *stepResult in self.result.results) {
        for (RKSTQuestionResult *surveyQuestionResult in stepResult.results) {
            [questionResultsForSurvey addObject:surveyQuestionResult];
        }
    }
    
    RKSTNumericQuestionResult *qrHeartAge = [[RKSTNumericQuestionResult alloc] initWithIdentifier:kSummaryHeartAge];
    qrHeartAge.questionType = RKQuestionTypeInteger;
    qrHeartAge.numericAnswer = self.heartAgeInfo[kSummaryHeartAge];
    [questionResultsForSurvey addObject:qrHeartAge];
    
    
    RKSTNumericQuestionResult *qrTenYearRisk = [[RKSTNumericQuestionResult alloc] initWithIdentifier:kSummaryTenYearRisk];
    qrTenYearRisk.questionType = RKQuestionTypeDecimal;
    qrTenYearRisk.numericAnswer = self.heartAgeInfo[kSummaryTenYearRisk];
    
    [questionResultsForSurvey addObject:qrTenYearRisk];
    
    RKSTNumericQuestionResult *qrLifetimeRisk = [[RKSTNumericQuestionResult alloc] initWithIdentifier:kSummaryLifetimeRisk];
    qrLifetimeRisk.questionType = RKQuestionTypeDecimal;
    qrLifetimeRisk.numericAnswer = self.heartAgeInfo[kSummaryLifetimeRisk];
    
    [questionResultsForSurvey addObject:qrLifetimeRisk];
    
    self.result.results = questionResultsForSurvey;
    
    [super taskViewControllerDidComplete:taskViewController];
}

- (RKSTStepViewController *)taskViewController:(RKSTTaskViewController *)taskViewController viewControllerForStep:(RKSTStep *)step
{
    
    RKSTStepViewController *stepVC = nil;
    
 if ([step.identifier isEqualToString:kHeartAgeResult]) {
        
        NSMutableDictionary *surveyResultsDictionary = [NSMutableDictionary dictionary];
        
        // Normalize survey results into dictionary.
        for (RKSTStepResult *survey in taskViewController.result.results) {
            if (![survey.identifier isEqualToString:kHeartAgeIntroduction]) {
                NSArray *qrIdentifiers = self.heartAgeTaskQuestionIndex[survey.identifier];
                
                [survey.results enumerateObjectsUsingBlock:^(RKSTQuestionResult *questionResult, NSUInteger idx, BOOL *stop) {
                    NSString *questionIdentifier = [qrIdentifiers objectAtIndex:idx];
                    
                    if ([questionIdentifier isEqualToString:kHeartAgeTestDataEthnicity]) {
                        APCAppDelegate *apcDelegate = (APCAppDelegate*)[[UIApplication sharedApplication] delegate];

                        RKSTChoiceQuestionResult *textResult = (RKSTChoiceQuestionResult *) questionResult;
                        NSString *ethnicity = (NSString *)[textResult.choiceAnswers firstObject];
                        
                        // persist ethnicity to the datastore
                        [apcDelegate.dataSubstrate.currentUser setEthnicity:ethnicity];
                        
                        [surveyResultsDictionary setObject:ethnicity forKey:questionIdentifier];
                    } else if ([questionIdentifier isEqualToString:kHeartAgeTestDataGender]) {
                        RKSTChoiceQuestionResult *textResult = (RKSTChoiceQuestionResult *) questionResult;
                        
                        NSString *selectedGender = ([(NSString *)[textResult.choiceAnswers firstObject] isEqualToString:@"HKBiologicalSexFemale"]) ? kHeartAgeTestDataGenderFemale :kHeartAgeTestDataGenderMale;

                        [surveyResultsDictionary setObject:selectedGender
                                                    forKey:questionIdentifier];
                    } else if ([questionIdentifier isEqualToString:kHeartAgeTestDataAge]) {
                        RKSTDateQuestionResult *dob = (RKSTDateQuestionResult *) questionResult;
                        
                    
                        NSDate *dateOfBirth = dob.dateAnswer;                        // Compute the age of the user.
                        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                                          fromDate:dateOfBirth
                                                                                            toDate:[NSDate date] // today
                                                                                           options:NSCalendarWrapComponents];
                        
                        NSUInteger usersAge = [ageComponents year];
                        [surveyResultsDictionary setObject:[NSNumber numberWithInteger:usersAge] forKey:questionIdentifier];
                    } else if ([questionResult isKindOfClass:[RKSTBooleanQuestionResult class]]) {
                        RKSTBooleanQuestionResult *numericResult = (RKSTBooleanQuestionResult *) questionResult;
                        
                        [surveyResultsDictionary setObject:numericResult.booleanAnswer forKey:questionIdentifier];
                    } else if ([questionResult isKindOfClass:[RKSTNumericQuestionResult class]]) {
                        RKSTNumericQuestionResult *numericResult = (RKSTNumericQuestionResult *) questionResult;
                        
                        [surveyResultsDictionary setObject:numericResult.numericAnswer forKey:questionIdentifier];
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


- (BOOL)taskViewController:(RKSTTaskViewController *)taskViewController hasLearnMoreForStep:(RKSTStep *)step {
    
    BOOL hasLearnMore = NO;
    
    if ([step.identifier isEqualToString:kHeartAgeIntroduction])
    {
        hasLearnMore = YES;
        
    }
    
    return hasLearnMore;
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController learnMoreForStep:(RKSTStepViewController *)stepViewController {
    
    
    if ([stepViewController.step.identifier isEqualToString:kHeartAgeIntroduction]) {
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"APHHeartAgeIntroStepViewController"
                                                                 bundle:nil];
        
        APHHeartAgeIntroStepViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"APHHeartAgeIntroStepViewController"];
        
        controller.taskIdentifier = self.scheduledTask.task.taskID;
    
        
        [self presentViewController:controller animated:YES completion:nil];
    
    }
}


@end
