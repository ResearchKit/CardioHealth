// 
//  APHHeartAgeIntroStepViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHHeartAgeIntroStepViewController.h"
#import "APHIntroPurposeContainedTableTableViewController.h"

static NSString *kKludgeIdentifierForHeartAgeTaskB = @"APHHeartAgeB-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";
@interface APHHeartAgeIntroStepViewController ()
@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;
@property (weak, nonatomic) NSString *purposeText;
@end

@implementation APHHeartAgeIntroStepViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    APCBaseWithProgressTaskViewController *taskVC = (APCBaseWithProgressTaskViewController *) self.parentViewController;
    
    if ([self.taskIdentifier isEqualToString:kKludgeIdentifierForHeartAgeTaskB]) {
        self.purposeText = @"The American Heart Association and the American College of Cardiology developed a risk score for heart disease and stroke as the first step for prevention. It is based on following healthy individuals for many years to understand which risk factors predicted cardiovascular disease. By entering your own data, requiring blood pressure and cholesterol values, the app will provide a personalized estimate of your risk of heart attack or stroke over the next 10 years, as well as over your lifetime. It will also provide optimal risk scores for someone your age, gender, and race. We also calculate a Heart Age by comparing your 10-year risk against the optimal risk, with an older age indicating higher risk.\n\n[Note the 10-year risk score and Heart Age only applies to ages 40-79, while the lifetime risk score is calculated for ages 20-59.]";
        
    } else {
        self.purposeText = @"The American Heart Association and the American College of Cardiology developed a risk score for heart disease and stroke as the first step for prevention. It is based on following healthy individuals for many years to understand which risk factors predicted cardiovascular disease. By entering your own data, requiring blood pressure and cholesterol values, the app will provide a personalized estimate of your risk of heart attack or stroke over the next 10 years, as well as over your lifetime. It will also provide optimal risk scores for someone your age, gender, and race.\n\n[Note the 10-year risk score only applies to ages 40-79, while the lifetime risk score is calculated for ages 20-59.]";
    }
    if ([segue.identifier isEqualToString: @"APHHeartAgeIntroStepViewControllerSegue"]) {
        APHIntroPurposeContainedTableTableViewController * childViewController = (APHIntroPurposeContainedTableTableViewController *) [segue destinationViewController];
        [childViewController setPurposeText:self.purposeText];
    }
}


- (IBAction)getStartedWasTapped:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
