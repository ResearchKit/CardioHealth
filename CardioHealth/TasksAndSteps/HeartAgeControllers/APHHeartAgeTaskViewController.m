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

//TODO added by Justin
#import "APHHeartAgeResultsViewController.h"
#import "APHHeartAgeIntroStepViewController.h"

static NSString *MainStudyIdentifier = @"com.cardiovascular.heartAgeTest";

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
@property (strong, nonatomic) RKDataArchive *taskArchive;

@end

@implementation APHHeartAgeTaskViewController

/*********************************************************************************/
#pragma  mark  -  View Controller Methods
/*********************************************************************************/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self beginTask];
}

/*********************************************************************************/
#pragma mark - Initialize
/*********************************************************************************/

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
    
    // Biographic and Demogrphic
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        RKFormStep *step = [[RKFormStep alloc] initWithIdentifier:kHeartAgeFormStepBiographicAndDemographic
                                                             name:@"BioDemo"
                                                            title:nil
                                                         subtitle:NSLocalizedString(@"To calculate your heart age, please enter a few details about yourself.",
                                                                                    @"To calculate your heart age, please enter a few details about yourself.")];
        step.optional = NO;
        {
            RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
            format.minimum = @(1);
            
            RKFormItem *item = [[RKFormItem alloc] initWithIdentifier:kHeartAgeTestDataAge
                                                                 text:NSLocalizedString(@"Date of birth", @"Date of birth")
                                                         answerFormat:[RKHealthAnswerFormat healthAnswerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]]];
            [stepQuestions addObject:item];
        }
        
        {
            RKFormItem *item = [[RKFormItem alloc] initWithIdentifier:kHeartAgeTestDataGender
                                                                 text:NSLocalizedString(@"Gender", @"Gender")
                                                         answerFormat:[RKHealthAnswerFormat healthAnswerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]]];
            [stepQuestions addObject:item];
        }
        
        {
            RKAnswerFormat *format = [RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"African-American", @"Other"]
                                                                             style:RKChoiceAnswerStyleSingleChoice];
            
            RKFormItem *item = [[RKFormItem alloc] initWithIdentifier:kHeartAgeTestDataEthnicity
                                                                 text:NSLocalizedString(@"Ethnicity", @"Ethnicity")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        RKFormStep *step = [[RKFormStep alloc] initWithIdentifier:kHeartAgeFormStepSmokingHistory
                                                             name:@"smokingHistory"
                                                            title:NSLocalizedString(@"Smoking History",
                                                                                    @"Smoking History")
                                                         subtitle:nil];
        step.optional = NO;
        {
            RKFormItem *item = [[RKFormItem alloc] initWithIdentifier:kHeartAgeTestDataSmoke
                                                                 text:NSLocalizedString(@"Have you ever smoked?",
                                                                                        @"Have you ever smoked?")
                                                         answerFormat:[RKBooleanAnswerFormat new]];
            [stepQuestions addObject:item];
        }
        
        {
            RKFormItem *item = [[RKFormItem alloc] initWithIdentifier:kHeartAgeTestDataCurrentlySmoke
                                                                 text:NSLocalizedString(@"Do you still smoke?",
                                                                                        @"Do you still smoke?")
                                                         answerFormat:[RKBooleanAnswerFormat new]];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        RKFormStep *step = [[RKFormStep alloc] initWithIdentifier:kHeartAgeFormStepCholesterolHdlSystolic
                                                             name:@"cholesterolHdlSystolic"
                                                            title:nil
                                                         subtitle:NSLocalizedString(@"Cholesterol & Blood Pressure",
                                                                                    @"Cholesterol & Blood Pressure")];
        step.optional = NO;
        
        {
            RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:@"mg/dl"];
            format.minimum = @(0);
            format.maximum = @(240);
            
            RKFormItem *item = [[RKFormItem alloc] initWithIdentifier:kHeartAgeTestDataTotalCholesterol
                                                                 text:NSLocalizedString(@"Total Cholesterol",
                                                                                        @"Total Cholesterol")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:@"mg/dl"];
            format.minimum = @(40);
            
            RKFormItem *item = [[RKFormItem alloc] initWithIdentifier:kHeartAgeTestDataHDL
                                                                 text:NSLocalizedString(@"HDL", @"HDL")
                                                         answerFormat:format];
            [stepQuestions addObject:item];
        }
        
        {
            RKHealthAnswerFormat *healthFormat = [RKHealthAnswerFormat healthAnswerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic]
                                                                                                     unit:[HKUnit unitFromString:@"mmHg"]
                                                                                                    style:RKNumericAnswerStyleInteger];
            
            RKFormItem *item = [[RKFormItem alloc] initWithIdentifier:kHeartAgeTestDataSystolicBloodPressure
                                                                 text:NSLocalizedString(@"Systolic Blood Pressure",
                                                                                        @"Systolic Blood Pressure")
                                                         answerFormat:healthFormat];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    {
        NSMutableArray *stepQuestions = [NSMutableArray array];
        RKFormStep *step = [[RKFormStep alloc] initWithIdentifier:kHeartAgeFormStepMedicalHistory
                                                             name:@"medicalHistory"
                                                            title:nil
                                                         subtitle:NSLocalizedString(@"Your medical history.",
                                                                                    @"Your medical history.")];
        step.optional = NO;
        {
            RKFormItem *item = [[RKFormItem alloc] initWithIdentifier:kHeartAgeTestDataDiabetes
                                                                 text:NSLocalizedString(@"Do you have Diabetes?",
                                                                                        @"Do you have Diabetes?")
                                                         answerFormat:[RKBooleanAnswerFormat new]];
            [stepQuestions addObject:item];
        }
        
        {
            RKFormItem *item = [[RKFormItem alloc] initWithIdentifier:kHeartAgeTestDataHypertension
                                                                 text:NSLocalizedString(@"Are you being treated for Hypertension?",
                                                                                        @"Are you being treated for Hypertension?")
                                                         answerFormat:[RKBooleanAnswerFormat new]];
            [stepQuestions addObject:item];
        }
        
        [step setFormItems:stepQuestions];
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgeResult
                                                                     name:NSLocalizedString(@"Heart Age Summary", @"Heart age summary")
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

/*********************************************************************************/
#pragma  mark  - Private methods
/*********************************************************************************/

- (void)beginTask
{
    if (self.taskArchive)
    {
        [self.taskArchive resetContent];
    }
    
    self.taskArchive = [[RKDataArchive alloc] initWithItemIdentifier:[RKItemIdentifier itemIdentifierForTask:self.task] studyIdentifier:MainStudyIdentifier taskInstanceUUID:self.taskInstanceUUID extraMetadata:nil fileProtection:RKFileProtectionCompleteUnlessOpen];
    
}

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/

-(void)sendResult:(RKResult*)result
{
    // In a real application, consider adding to the archive on a concurrent queue.
    NSError *err = nil;
    if (![result addToArchive:self.taskArchive error:&err])
    {
        // Error adding the result to the archive; archive may be invalid. Tell
        // the user there's been a problem and stop the task.
        NSLog(@"Error adding %@ to archive: %@", result, err);
    }
}


/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/

- (void)taskViewControllerDidFail: (RKTaskViewController *)taskViewController withError:(NSError*)error{
    
    [self.taskArchive resetContent];
    self.taskArchive = nil;
    
}

- (void)taskViewControllerDidCancel:(RKTaskViewController *)taskViewController{
    
    [taskViewController suspend];
    
    [self.taskArchive resetContent];
    self.taskArchive = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewControllerDidComplete: (RKTaskViewController *)taskViewController{
    
    [taskViewController suspend];
    
    NSError *err = nil;
    NSURL *archiveFileURL = [self.taskArchive archiveURLWithError:&err];
    if (archiveFileURL)
    {
        NSURL *documents = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        NSURL *outputUrl = [documents URLByAppendingPathComponent:[archiveFileURL lastPathComponent]];
        
        // This is where you would queue the archive for upload. In this demo, we move it
        // to the documents directory, where you could copy it off using iTunes, for instance.
        [[NSFileManager defaultManager] moveItemAtURL:archiveFileURL toURL:outputUrl error:nil];
        
        NSLog(@"outputUrl= %@", outputUrl);
        
        // When done, clean up:
        self.taskArchive = nil;
        if (archiveFileURL)
        {
            [[NSFileManager defaultManager] removeItemAtURL:archiveFileURL error:nil];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [super taskViewControllerDidComplete:taskViewController];
    
}

- (RKStepViewController *)taskViewController:(RKTaskViewController *)taskViewController viewControllerForStep:(RKStep *)step
{
    
    RKStepViewController *stepVC = nil;
    
    if ([step.identifier isEqualToString:kHeartAgeIntroduction]) {
        
        NSDictionary  *controllers = @{ kHeartAgeIntroduction : [APHHeartAgeIntroStepViewController class] };
        
        Class  aClass = [controllers objectForKey:step.identifier];
        APCStepViewController  *controller = [[aClass alloc] initWithNibName:nil bundle:nil];
        controller.resultCollector = self;
        controller.delegate = self;
        controller.title = @"Interval Tapping";
        controller.step = step;
        
        stepVC = controller;
    
    } else if ([step.identifier isEqualToString:kHeartAgeResult]) {
        
        NSMutableDictionary *surveyResultsDictionary = [NSMutableDictionary dictionary];
        
        // Normalize survey results into dictionary.
        for (RKSurveyResult *survey in taskViewController.surveyResults) {
            for (RKQuestionResult *questionResult in survey.surveyResults) {
                // Since we are using form steps and form items, the identifiers
                // for a question are now in a formStepIdentifier.formItemIdentifier format.
                NSString *formStepAndFormItemIdentifier = [[questionResult itemIdentifier] stringValue];
                
                // we will only use the last part of the identifier, that is the 'formItemIdentifier'
                // because it is the unique identifier that is provided by the Heart Age Calculations
                // class and the methods in that class expect this identifier as the element key of the
                // dictionary that is passed to it.
                NSString *questionIdentifier = [[formStepAndFormItemIdentifier componentsSeparatedByString:@"."] lastObject];
                
                if ([questionIdentifier isEqualToString:kHeartAgeTestDataEthnicity]) {
                    [surveyResultsDictionary setObject:(NSString *)questionResult.answer forKey:questionIdentifier];
                } else if ([questionIdentifier isEqualToString:kHeartAgeTestDataGender]) {
                    [surveyResultsDictionary setObject:((NSInteger)questionResult.answer == HKBiologicalSexFemale) ? kHeartAgeTestDataGenderFemale : kHeartAgeTestDataGenderMale
                                                forKey:questionIdentifier];
                } else if ([questionIdentifier isEqualToString:kHeartAgeTestDataAge]) {
                    NSDate *dateOfBirth = [[NSCalendar currentCalendar] dateFromComponents:(NSDateComponents *)questionResult.answer];
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
            }
        }
        
        // Kickoff heart age calculations
        APHHeartAgeAndRiskFactors *heartAgeAndRiskFactors = [[APHHeartAgeAndRiskFactors alloc] init];
        self.heartAgeInfo = [heartAgeAndRiskFactors calculateHeartAgeAndRiskFactors:surveyResultsDictionary];
        
        APHHeartAgeResultsViewController *heartAgeResultsVC = [[APHHeartAgeResultsViewController alloc] initWithNibName:@"APHHeartAgeResultsViewController" bundle:nil];
        
        heartAgeResultsVC.resultCollector = self;
        heartAgeResultsVC.delegate = self;
        heartAgeResultsVC.step = step;
        heartAgeResultsVC.taskProgress = 0.25;
        heartAgeResultsVC.actualAge = [surveyResultsDictionary[kHeartAgeTestDataAge] integerValue];
        heartAgeResultsVC.heartAge = [self.heartAgeInfo[kSummaryHeartAge] integerValue];
        heartAgeResultsVC.tenYearRisk = self.heartAgeInfo[kSummaryTenYearRisk];
        heartAgeResultsVC.lifetimeRisk = self.heartAgeInfo[kSummaryLifetimeRisk];
        
        stepVC = heartAgeResultsVC;
    }
    
    return stepVC;
}

- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKSurveyResult *)result
{
    // We need to create three question results that will hold the value of Heart Age,
    // Ten Year Risk, and Lifetime Risk factors. Ideally we would like to simply
    // amend the self.headerAgeInfo dictionary to the results, but an appropriate
    // RKSurveyQuestionType is not available for adding dictionary to the result;
    // thus we create separate question results for each of these data points.
    
    NSMutableArray *questionResultsForSurvey = [NSMutableArray array];
    
    for (RKSurveyResult *miniSurvey in result.surveyResults) {
        for (RKQuestionResult *surveyQuestionResult in miniSurvey.surveyResults) {
            [questionResultsForSurvey addObject:surveyQuestionResult];
        }
    }
    
    RKQuestionResult *qrHeartAge = [[RKQuestionResult alloc] initWithStep:[[RKStep alloc] initWithIdentifier:kSummaryHeartAge
                                                                                                        name:kSummaryHeartAge]];
    qrHeartAge.questionType = RKSurveyQuestionTypeInteger;
    qrHeartAge.answer = self.heartAgeInfo[kSummaryHeartAge];
    
    [questionResultsForSurvey addObject:qrHeartAge];
    
    RKQuestionResult *qrTenYearRisk = [[RKQuestionResult alloc] initWithStep:[[RKStep alloc] initWithIdentifier:kSummaryTenYearRisk
                                                                                                           name:kSummaryTenYearRisk]];
    qrTenYearRisk.questionType = RKSurveyQuestionTypeDecimal;
    qrTenYearRisk.answer = self.heartAgeInfo[kSummaryTenYearRisk];
    
    [questionResultsForSurvey addObject:qrTenYearRisk];
    
    RKQuestionResult *qrLifetimeRisk = [[RKQuestionResult alloc] initWithStep:[[RKStep alloc] initWithIdentifier:kSummaryLifetimeRisk
                                                                                                            name:kSummaryLifetimeRisk]];
    qrLifetimeRisk.questionType = RKSurveyQuestionTypeDecimal;
    qrLifetimeRisk.answer = self.heartAgeInfo[kSummaryLifetimeRisk];
    
    [questionResultsForSurvey addObject:qrLifetimeRisk];
    
    result.surveyResults = questionResultsForSurvey;
    
    [self sendResult:result];
    
    [super taskViewController:taskViewController didProduceResult:result];
}

/*********************************************************************************/
#pragma mark - StepViewController Delegate Methods
/*********************************************************************************/

- (void)stepViewControllerWillBePresented:(RKStepViewController *)viewController
{
    viewController.skipButton = nil;
}


@end
