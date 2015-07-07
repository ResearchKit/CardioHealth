//
//  APHDietSurveyViewController.m
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

#import "APHDietSurveyViewController.h"

NSString *const kDietSurveyStepIdentifierFruits      = @"fruit";
NSString *const kDietSurveyStepIdentifierVegetables  = @"vegetable";
NSString *const kDietSurveyStepIdentifierFish        = @"fish";
NSString *const kDietSurveyStepIdentifierGrains      = @"grains";
NSString *const kDietSurveyStepIdentifierSugarDrinks = @"sugar_drinks";
NSString *const kDietSurveyStepIdentifierSodium      = @"sodium";

@interface APHDietSurveyViewController ()

@end

@implementation APHDietSurveyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString *)createResultSummary
{
    NSError *error = nil;
    NSString *dietSurveySummary = nil;
    NSMutableDictionary *dietSurveyResults = [NSMutableDictionary new];
    
    for (ORKStepResult *survey in self.result.results) {
        [survey.results enumerateObjectsUsingBlock:^(ORKQuestionResult *questionResult, NSUInteger __unused idx, BOOL * __unused stop)
         {
             switch (questionResult.questionType) {
                 case ORKQuestionTypeInteger:
                 {
                     ORKNumericQuestionResult *numericResult = (ORKNumericQuestionResult *) questionResult;
                     
                     id answer = [NSNull null];
                     
                     if (numericResult.numericAnswer != nil) {
                         answer = (NSNumber *)numericResult.numericAnswer;
                     }
                     
                     [dietSurveyResults setObject:answer forKey:questionResult.identifier];
                 }
                     break;
                 case ORKQuestionTypeMultipleChoice:
                 {
                     ORKChoiceQuestionResult *choiceResult = (ORKChoiceQuestionResult *) questionResult;
                     
                     NSArray *answer = nil;
                     
                     if (choiceResult.choiceAnswers.count > 0) {
                         answer = [NSArray arrayWithArray:choiceResult.choiceAnswers];
                     } else {
                         answer = @[];
                     }
                     
                     [dietSurveyResults setObject:answer forKey:questionResult.identifier];
                 }
                     break;
                     
                 default:
                     APCLogError(@"Encountered and unexpected question result type. %@", questionResult.class);
                     break;
             }
         }];
    }
    
    NSData *dietSurveyData = [NSJSONSerialization dataWithJSONObject:dietSurveyResults options:0 error:&error];
    
    if (dietSurveyData) {
        dietSurveySummary = [[NSString alloc] initWithData:dietSurveyData encoding:NSUTF8StringEncoding];
    } else {
        APCLogError2(error);
    }
    
    return dietSurveySummary;
}

@end
