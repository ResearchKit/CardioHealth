// 
//  Healthy 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHHealthyHeartTaskViewController.h"
#import "APHHealthyHeartSummaryStepViewController.h"

static NSString *kHealthyHeartIntroduction = @"healthyHeartIntroduction";
static NSString *kBloodPressureChecked = @"bloodPressureChecked";
static NSString *kBloodPressureLevel = @"bloodPressureLevel";
static NSString *kHaveHighBloodPressure = @"haveHighBloodPressure";
static NSString *kHealthyHeartSummary = @"healthyHeartSummary";

@interface APHHealthyHeartTaskViewController ()

@end

@implementation APHHealthyHeartTaskViewController

#pragma mark - Task

+ (RKSTOrderedTask *)createTask:(APCScheduledTask *)scheduledTask
{
    NSMutableArray *steps = [NSMutableArray array];
    
    {
        RKSTInstructionStep *step = [[RKSTInstructionStep alloc] initWithIdentifier:kHealthyHeartIntroduction];
        
        step.title = NSLocalizedString(@"Healthy Heart", @"");
        step.detailText = NSLocalizedString(@"The purpose of this survey is to learn about your heart health.",
                                             @"The purpose of this survey is to learn about your heart health.");
        [steps addObject:step];
    }
    {
        RKSTAnswerFormat *format = [RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:@[
                                                                                               @"Within the past year",
                                                                                               @"Within the past 2 years",
                                                                                               @"Within the past 5 years",
                                                                                               @"Don't Know",
                                                                                               @"Never had it checked."]
                                                                                       style:RKChoiceAnswerStyleSingleChoice];
        
        RKSTQuestionStep *step = [RKSTQuestionStep questionStepWithIdentifier:kBloodPressureChecked
                                                                        title:@"When was the last time you had your blood pressure checked?"
                                                                       answer:format];
        
        [steps addObject:step];
    }
    {
        RKSTAnswerFormat *format = [RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:@[
                                                                                 @"Normal",
                                                                                 @"High",
                                                                                 @"Don't Know"]
                                                                         style:RKChoiceAnswerStyleSingleChoice];
        
        RKSTQuestionStep *step = [RKSTQuestionStep questionStepWithIdentifier:kBloodPressureLevel
                                                                        title:@"The Last time you had your blood pressure checked, was it normal or high?"
                                                                       answer:format];
        
        [steps addObject:step];
    }
    {
        RKSTQuestionStep *step = [RKSTQuestionStep questionStepWithIdentifier:kHaveHighBloodPressure
                                                                        title:@"Do you have high blood pressure?"
                                                                       answer:[RKSTBooleanAnswerFormat new]];
        [steps addObject:step];
    }
    {
        //Finished
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:kHealthyHeartSummary];
        step.recorderConfigurations = @[];
        step.title = NSLocalizedString(@"Good job.", @"");
        step.text = NSLocalizedString(@"Great job.", @"");
        
        step.shouldUseNextAsSkipButton = NO;
        [steps addObject:step];
    }
    
    RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithIdentifier:NSLocalizedString(@"Healthy Heart", @"Healthy Heart")
                                                                  steps:steps];
    
    return task;
    
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (RKSTStepViewController *)taskViewController:(RKSTTaskViewController *)taskViewController viewControllerForStep:(RKSTStep *)step
{
    RKSTStepViewController *stepVC = nil;
    
    if (step.identifier == kHealthyHeartSummary) {
        
        APHHealthyHeartSummaryStepViewController *summaryViewController = [[APHHealthyHeartSummaryStepViewController alloc] initWithNibName:@"APHFitnessTestSummaryViewController" bundle:nil];
        
        summaryViewController.delegate = self;
        summaryViewController.step = step;
        
        stepVC = summaryViewController;
    }
    
    return stepVC;
}

@end
