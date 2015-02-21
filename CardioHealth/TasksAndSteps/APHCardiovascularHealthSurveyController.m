//
//  APHCardiovascularHealthSurveyController.m
//  MyHeartCounts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import "APHCardiovascularHealthSurveyController.h"

static NSString *const kHeartAgeQuestionIdentifier = @"heart_disease_q";
@interface APHCardiovascularHealthSurveyController ()

@end

@implementation APHCardiovascularHealthSurveyController

- (void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];

}

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithResult:(ORKTaskViewControllerResult)result error:(NSError *)error {
    
    switch (result) {
        case ORKTaskViewControllerResultCompleted:
        {
            APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            ORKStepResult *stepResult = [self.result stepResultForStepIdentifier:kHeartAgeQuestionIdentifier];
            NSNumber *boolAnswer = [stepResult.results.firstObject booleanAnswer];
            
            appDelegate.dataSubstrate.currentUser.hasHeartDisease = [boolAnswer integerValue];
        }
            break;
        case ORKTaskViewControllerResultDiscarded:
            break;
        case ORKTaskViewControllerResultSaved:
            break;
        case ORKTaskViewControllerResultFailed:
            break;
    }
    
    [super taskViewController:taskViewController didFinishWithResult:result error:error];
}


@end
