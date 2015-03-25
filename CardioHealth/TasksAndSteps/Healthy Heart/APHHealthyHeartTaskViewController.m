// 
//  Healthy 
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
