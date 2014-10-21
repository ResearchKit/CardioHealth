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

static NSString *MainStudyIdentifier = @"com.cardiovascular.heartAgeTest";

// Introduction Step Key
static NSString *kHeartAgeIntroduction = @"HeartAgeIntroduction";
static NSString *kHeartAgeSummary = @"HeartAgeSummary";

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
        format.maximum = @(240);

        RKQuestionStep *step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataTotalCholesterol
                                                                     name:@"TotalCholesterol"
                                                                 question:NSLocalizedString(@"What is your Total Cholesterol?", @"What is your Total Cholesterol?")
                                                                   answer:format];
        step.optional = NO;

        [steps addObject:step];
    }

    {
        RKNumericAnswerFormat *format = [RKNumericAnswerFormat integerAnswerWithUnit:nil];
        format.minimum = @(40);

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
        format.maximum = @(180);
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:kHeartAgekHeartAgeTestDataSystolicBloodPressure
                                                                     name:@"SystolicBloodPressure"
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
    
    if ([step.identifier isEqualToString:kHeartAgeSummary]) {
        
        NSMutableDictionary *surveyResultsDictionary = [NSMutableDictionary dictionary];
        
        // Normalize survey results into dictionary.
        for (RKQuestionResult *questionResult in taskViewController.surveyResults) {
            NSString *questionIdentifier = [[questionResult itemIdentifier] stringValue];
            if ([questionIdentifier isEqualToString:kHeartAgekHeartAgeTestDataEthnicity] || [questionIdentifier isEqualToString:kHeartAgekHeartAgeTestDataGender]) {
                [surveyResultsDictionary setObject:(NSString *)questionResult.answer forKey:questionIdentifier];
            } else {
                [surveyResultsDictionary setObject:(NSNumber *)questionResult.answer forKey:questionIdentifier];
            }
        }
        
        // Kickoff heart age calculations
        APHHeartAgeAndRiskFactors *heartAgeAndRiskFactors = [[APHHeartAgeAndRiskFactors alloc] init];
        self.heartAgeInfo = [heartAgeAndRiskFactors calculateHeartAgeAndRiskFactors:surveyResultsDictionary];
        
        UIStoryboard *sbHeartAgeSummary = [UIStoryboard storyboardWithName:@"HeartAgeSummary" bundle:nil];
        APHHeartAgeSummaryViewController *heartAgeResultsVC = [sbHeartAgeSummary instantiateInitialViewController];
        
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


/*********************************************************************************/
#pragma mark - StepViewController Delegate Methods
/*********************************************************************************/

- (void)stepViewControllerWillBePresented:(RKStepViewController *)viewController
{
    
    viewController.skipButton = nil;
    
}


- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKSurveyResult *)result
{
    // We need to create three question results that will hold the value of Heart Age,
    // Ten Year Risk, and Lifetime Risk factors. Ideally we would like to simply
    // amend the self.headerAgeInfo dictionary to the results, but an appropriate
    // RKSurveyQuestionType is not available for adding dictionary to the result;
    // thus we create separate question results for each of these data points.
    
    NSMutableArray *surveyQuestions = [result.surveyResults mutableCopy];
    
    RKQuestionResult *qrHeartAge = [[RKQuestionResult alloc] initWithStep:[[RKStep alloc] initWithIdentifier:kSummaryHeartAge
                                                                                                        name:kSummaryHeartAge]];
    qrHeartAge.questionType = RKSurveyQuestionTypeInteger;
    qrHeartAge.answer = self.heartAgeInfo[kSummaryHeartAge];
    
    [surveyQuestions addObject:qrHeartAge];
    
    RKQuestionResult *qrTenYearRisk = [[RKQuestionResult alloc] initWithStep:[[RKStep alloc] initWithIdentifier:kSummaryTenYearRisk
                                                                                                           name:kSummaryTenYearRisk]];
    qrTenYearRisk.questionType = RKSurveyQuestionTypeDecimal;
    qrTenYearRisk.answer = self.heartAgeInfo[kSummaryTenYearRisk];
    
    [surveyQuestions addObject:qrTenYearRisk];
    
    RKQuestionResult *qrLifetimeRisk = [[RKQuestionResult alloc] initWithStep:[[RKStep alloc] initWithIdentifier:kSummaryLifetimeRisk
                                                                                                            name:kSummaryLifetimeRisk]];
    qrLifetimeRisk.questionType = RKSurveyQuestionTypeDecimal;
    qrLifetimeRisk.answer = self.heartAgeInfo[kSummaryLifetimeRisk];
    
    [surveyQuestions addObject:qrLifetimeRisk];
    
    result.surveyResults = surveyQuestions;
    
    
    if ([result isKindOfClass:[RKSurveyResult class]]) {
        RKSurveyResult* sresult = (RKSurveyResult*)result;
        
        for (RKQuestionResult* qr in sresult.surveyResults) {
            NSLog(@"%@ = [%@] %@ ", [[qr itemIdentifier] stringValue], [qr.answer class], qr.answer);
        }
    }
    
    [self sendResult:result];

    [super taskViewController:taskViewController didProduceResult:result];
}
@end
