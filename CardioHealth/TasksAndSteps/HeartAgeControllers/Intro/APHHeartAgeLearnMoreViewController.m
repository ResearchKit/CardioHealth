// 
//  APHHeartAgeIntroStepViewController.m 
//  MyHeart Counts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHHeartAgeLearnMoreViewController.h"
#import "APHIntroPurposeContainedTableTableViewController.h"

static NSString *kKludgeIdentifierForHeartAgeTaskB = @"APHHeartAgeB-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";
@interface APHHeartAgeLearnMoreViewController ()
@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;
@property (weak, nonatomic) NSString *purposeText;
@end

@implementation APHHeartAgeLearnMoreViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id) __unused sender {
        
    if ([self.taskIdentifier isEqualToString:kKludgeIdentifierForHeartAgeTaskB]) {
        self.purposeText = @"The American Heart Association and the American College of Cardiology developed a risk score for future heart disease and stroke as the first step for prevention. It is based on following healthy individuals for many years to understand which risk factors predicted cardiovascular disease. By entering your own data, requiring blood pressure and cholesterol values, the app will provide a personalized estimate of your risk of heart attack or stroke over the next 10 years, as well as over your lifetime. It will also provide optimal risk scores for someone your age, gender, and race. We also calculate a Heart Age by comparing your 10-year risk against the optimal risk, with an older age indicating higher risk. This does not apply to people with existing cardiovascular disease. It also does not apply to people with LDL>190mg/dL, who should consult with their doctor. The estimated risk score and heart age can be affected in people taking cholesterol medications.\n\n[Note the 10-year risk score and Heart Age only applies to ages 40-79, while the lifetime risk score is calculated for ages 20-59.]\n\nOptimal risk factors: total cholesterol 170mg/dL, HDL 50mg/dL, systolic blood pressure 110mmHg, no smoking, no diabetes, no medication for high blood pressure.";
        
    } else {
        self.purposeText = @"The American Heart Association and the American College of Cardiology developed a risk score for future heart disease and stroke as the first step for prevention. By entering your own data the app will provide a personalized estimate of your risk of heart attack or stroke over the next 10 years, as well as over your lifetime. It will also provide optimal risk scores for someone your age, gender, and race, which are used to estimate your relative ‘heart age.’\n\n[Note the 10-year risk score and heart age only applies to ages 40-79, while the lifetime risk score is calculated for ages 20-59. This does not apply to people with existing cardiovascular disease and the values can be affected in people already taking cholesterol medications.]";
    }
    if ([segue.identifier isEqualToString: @"APHHeartAgeIntroStepViewControllerSegue"]) {
        APHIntroPurposeContainedTableTableViewController * childViewController = (APHIntroPurposeContainedTableTableViewController *) [segue destinationViewController];
        [childViewController setPurposeText:self.purposeText];
    }
}


- (IBAction)getStartedWasTapped:(id) __unused sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
