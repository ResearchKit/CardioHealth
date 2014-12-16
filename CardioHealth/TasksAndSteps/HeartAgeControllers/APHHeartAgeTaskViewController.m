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
    
    // Biographic and Demogrphic
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        RKSTFormStep *step = [[RKSTFormStep alloc] initWithIdentifier:kHeartAgeFormStepBiographicAndDemographic
                                                            title:nil
                                                         subtitle:NSLocalizedString(@"To calculate your heart age, please enter a few details about yourself.",
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
            RKSTAnswerFormat *format = [RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:@[@"I prefer not to indicate an ethnicity", @"Alaska Native", @"American Indian", @"Asian", @"Black", @"Hispanic", @"Pacific Islander", @"White", @"Other"]
                                                                                     style:RKChoiceAnswerStyleSingleChoice];
            
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
                                                         subtitle:NSLocalizedString(@"Smoking History",
                                                                                    @"Smoking History")];
        step.optional = NO;
        
        {
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kHeartAgeTestDataCurrentlySmoke
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
                                                             subtitle:NSLocalizedString(@"Cholesterol & Blood Pressure",
                                                                                        @"Cholesterol & Blood Pressure")];
        step.optional = NO;
        
        {
            RKSTNumericAnswerFormat *format = [RKSTNumericAnswerFormat integerAnswerWithUnit:@"mg/dl"];
            format.minimum = @(0);
            format.maximum = @(240);
            
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kHeartAgeTestDataTotalCholesterol
                                                                 text:NSLocalizedString(@"Total Cholesterol",
                                                                                        @"Total Cholesterol")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            RKSTNumericAnswerFormat *format = [RKSTNumericAnswerFormat integerAnswerWithUnit:@"mg/dl"];
            format.minimum = @(40);
            
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
                                                             subtitle:NSLocalizedString(@"Your Medical History",
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
    
    RKSTOrderedTask  *task = nil;
    
    if ([self.task isKindOfClass:[RKSTOrderedTask class]]) {
        task =  (RKSTOrderedTask *)self.task;
    }
    
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
    UIAlertController* alerVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(title,
                                                                                              title)
                                                                    message:NSLocalizedString(message,
                                                                                              message)
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                             [alerVC dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    
    [alerVC addAction:ok];
    
    [self presentViewController:alerVC animated:NO completion:nil];
    
}

- (BOOL)questionStepResultFieldsAreComplete:(NSString *)stepIdentifier {

    BOOL returnValue = YES;

    RKSTStepResult *stepResult = [self.result stepResultForStepIdentifier:stepIdentifier];
    
    NSArray *questionsFields = stepResult.results;
    
    for (RKSTQuestionResult *questionResult in questionsFields) {
    
        if (questionResult.answer == [NSNull null]) {
            returnValue = NO;
        }
    }
    
    return returnValue;
}


/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/

- (void)taskViewControllerDidComplete: (RKSTTaskViewController *)taskViewController{
    
    [taskViewController suspend];
    
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
    
    RKSTQuestionResult *qrHeartAge = [[RKSTQuestionResult alloc] initWithIdentifier:kSummaryHeartAge];
    qrHeartAge.questionType = RKSurveyQuestionTypeInteger;
    qrHeartAge.answer = self.heartAgeInfo[kSummaryHeartAge];
    
    [questionResultsForSurvey addObject:qrHeartAge];
    
    RKSTQuestionResult *qrTenYearRisk = [[RKSTQuestionResult alloc] initWithIdentifier:kSummaryTenYearRisk];
    qrTenYearRisk.questionType = RKSurveyQuestionTypeDecimal;
    qrTenYearRisk.answer = self.heartAgeInfo[kSummaryTenYearRisk];
    
    [questionResultsForSurvey addObject:qrTenYearRisk];
    
    RKSTQuestionResult *qrLifetimeRisk = [[RKSTQuestionResult alloc] initWithIdentifier:kSummaryLifetimeRisk];
    qrLifetimeRisk.questionType = RKSurveyQuestionTypeDecimal;
    qrLifetimeRisk.answer = self.heartAgeInfo[kSummaryLifetimeRisk];
    
    [questionResultsForSurvey addObject:qrLifetimeRisk];
    
    self.result.results = questionResultsForSurvey;
    
    [super taskViewControllerDidComplete:taskViewController];
}


- (BOOL)taskViewController:(RKSTTaskViewController *)taskViewController shouldPresentStep:(RKSTStep *)step
{
    BOOL shouldShowStep = YES;
    
    taskViewController.navigationBar.topItem.title = NSLocalizedString(@"Heart Age Test", @"Heart Age Test");

    if ([step.identifier isEqualToString:@"HeartAgeResult"]) {
        
        shouldShowStep = [self questionStepResultFieldsAreComplete:self.currentStepViewController.step.identifier];
        
        if (!shouldShowStep) {
            [self showAlert:@"Missing Information" andMessage:@"An answer is required."];
        } else if (!self.shouldShowResultsStep) {
            [self showAlert:@"There are missing answers from the previous step." andMessage:@"All fields are required."];
            
            //Set shouldShowStep to NO so we do not show the next step.
            shouldShowStep = self.shouldShowResultsStep;
        } else {
            taskViewController.navigationBar.topItem.title = NSLocalizedString(@"Activity Complete", @"Activity Complete");
        }

    } else if (![step.identifier isEqualToString:kHeartAgeIntroduction] && ![step.identifier isEqualToString:kHeartAgeFormStepBiographicAndDemographic]) {
        
        shouldShowStep = [self questionStepResultFieldsAreComplete:self.currentStepViewController.step.identifier];
        
        if (!shouldShowStep) {
            
            [self showAlert:@"Missing Information" andMessage:@"An answer is required."];
        }
    }

    return shouldShowStep;
}

- (RKSTStepViewController *)taskViewController:(RKSTTaskViewController *)taskViewController viewControllerForStep:(RKSTStep *)step
{
    
    RKSTStepViewController *stepVC = nil;
    
    if ([step.identifier isEqualToString:kHeartAgeIntroduction]) {
        
        NSDictionary  *controllers = @{ kHeartAgeIntroduction : [APHHeartAgeIntroStepViewController class] };
        
        Class  aClass = [controllers objectForKey:step.identifier];
        APCStepViewController  *controller = [[aClass alloc] initWithNibName:nil bundle:nil];
        
        controller.delegate = self;
        controller.step = step;
        
        stepVC = controller;
    
    } else if ([step.identifier isEqualToString:kHeartAgeResult]) {
        
        NSMutableDictionary *surveyResultsDictionary = [NSMutableDictionary dictionary];
        
        // Normalize survey results into dictionary.
        for (RKSTStepResult *survey in taskViewController.result.results) {
            if (![survey.identifier isEqualToString:kHeartAgeIntroduction]) {
                NSArray *qrIdentifiers = self.heartAgeTaskQuestionIndex[survey.identifier];
                
                [survey.results enumerateObjectsUsingBlock:^(RKSTQuestionResult *questionResult, NSUInteger idx, BOOL *stop) {
                    NSString *questionIdentifier = [qrIdentifiers objectAtIndex:idx];
                    
                    if ([questionIdentifier isEqualToString:kHeartAgeTestDataEthnicity]) {
                        APCAppDelegate *apcDelegate = (APCAppDelegate*)[[UIApplication sharedApplication] delegate];
                        NSString *ethnicity = (NSString *)questionResult.answer;
                        
                        // persist ethnicity to the datastore
                        [apcDelegate.dataSubstrate.currentUser setEthnicity:ethnicity];
                        
                        [surveyResultsDictionary setObject:ethnicity forKey:questionIdentifier];
                    } else if ([questionIdentifier isEqualToString:kHeartAgeTestDataGender]) {
                        NSString *selectedGender = ([(NSString *)questionResult.answer isEqualToString:@"HKBiologicalSexFemale"]) ? kHeartAgeTestDataGenderFemale :kHeartAgeTestDataGenderMale;
                        [surveyResultsDictionary setObject:selectedGender
                                                    forKey:questionIdentifier];
                    } else if ([questionIdentifier isEqualToString:kHeartAgeTestDataAge]) {
                        RKSTDateAnswer *dob = questionResult.answer;
                        NSDate *dateOfBirth = [[NSCalendar currentCalendar] dateFromComponents:[dob dateComponents]];
                        // Compute the age of the user.
                        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                                          fromDate:dateOfBirth
                                                                                            toDate:[NSDate date] // today
                                                                                           options:NSCalendarWrapComponents];
                        
                        NSUInteger usersAge = [ageComponents year];
                        [surveyResultsDictionary setObject:[NSNumber numberWithInteger:usersAge] forKey:questionIdentifier];
                    } else {
                        [surveyResultsDictionary setObject:(NSNumber *)questionResult.answer forKey:questionIdentifier];
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

- (void)taskViewController:(RKSTTaskViewController *)taskViewController stepViewControllerWillAppear:(RKSTStepViewController *)stepViewController {
    
    self.shouldShowResultsStep = YES;
    
    if ([stepViewController.step.identifier isEqualToString:kHeartAgeFormStepMedicalHistory] ) {
        
        self.shouldShowResultsStep = [self questionStepResultFieldsAreComplete:kHeartAgeFormStepCholesterolHdlSystolic];
        
        if (!self.shouldShowResultsStep) {
            
            [self showAlert:@"There are missing answers from the previous step." andMessage:@"All fields are required."];
        }
    }
}

@end
