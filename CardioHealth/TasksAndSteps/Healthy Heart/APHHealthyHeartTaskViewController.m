// 
//  Healthy 
//  MyHeart Counts 
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

+ (ORKOrderedTask *)createTask:(APCScheduledTask *) __unused scheduledTask
{
    NSMutableArray *steps = [NSMutableArray array];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:kHealthyHeartIntroduction];
        
        step.title = NSLocalizedString(@"Healthy Heart", @"");
        step.detailText = NSLocalizedString(@"The purpose of this survey is to learn about your heart health.",
                                             @"The purpose of this survey is to learn about your heart health.");
        [steps addObject:step];
    }
    {
        NSArray *choices = @[@"Within the past year",
                             @"Within the past 2 years",
                             @"Within the past 5 years",
                             @"Don't Know",
                             @"Never had it checked."
                             ];
        
        ORKAnswerFormat *format =  [ORKTextChoiceAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:choices];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kBloodPressureChecked
                                                                        title:@"When was the last time you had your blood pressure checked?"
                                                                       answer:format];
        
        [steps addObject:step];
    }
    {
        NSArray *choices = @[@"Normal",
                             @"High",
                             @"Don't Know"];
        
        ORKAnswerFormat *format =  [ORKTextChoiceAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:choices];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kBloodPressureLevel
                                                                        title:@"The Last time you had your blood pressure checked, was it normal or high?"
                                                                       answer:format];
        
        [steps addObject:step];
    }
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kHaveHighBloodPressure
                                                                        title:@"Do you have high blood pressure?"
                                                                       answer:[ORKBooleanAnswerFormat new]];
        [steps addObject:step];
    }
    {
        //Finished
        ORKStep* step = [[ORKStep alloc] initWithIdentifier:kHealthyHeartSummary];
        step.title = NSLocalizedString(@"Good job.", @"");
        step.text = NSLocalizedString(@"Great job.", @"");
        
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:NSLocalizedString(@"Healthy Heart", @"Healthy Heart")
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

- (ORKStepViewController *)taskViewController:(ORKTaskViewController *) __unused taskViewController viewControllerForStep:(ORKStep *)step
{
    ORKStepViewController *stepVC = nil;
    
    if (step.identifier == kHealthyHeartSummary) {
        
        APHHealthyHeartSummaryStepViewController *summaryViewController = [[APHHealthyHeartSummaryStepViewController alloc] initWithNibName:@"APHFitnessTestSummaryViewController" bundle:nil];
        
        summaryViewController.delegate = self;
        summaryViewController.step = step;
        
        stepVC = summaryViewController;
    }
    
    return stepVC;
}

@end
