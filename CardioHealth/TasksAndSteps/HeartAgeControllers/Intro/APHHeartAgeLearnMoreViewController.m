// 
//  APHHeartAgeLearnMoreViewController.m 
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
        self.purposeText = NSLocalizedString(@"The American Heart Association and the American College of Cardiology developed a risk score for future heart disease and stroke as the first step for prevention. It is based on following healthy individuals for many years to understand which risk factors predicted cardiovascular disease. By entering your own data, requiring blood pressure and cholesterol values, the app will provide a personalized estimate of your risk of heart attack or stroke over the next 10 years, as well as over your lifetime. It will also provide optimal risk scores for someone your age, gender, and race. We also calculate a Heart Age by comparing your 10-year risk against the optimal risk, with an older age indicating higher risk. This does not apply to people with existing cardiovascular disease. It also does not apply to people with LDL>190mg/dL, who should consult with their doctor. The estimated risk score and heart age can be affected in people taking cholesterol medications.\n\n[Note the 10-year risk score and Heart Age only applies to ages 40-79, while the lifetime risk score is calculated for ages 20-59.]\n\nOptimal risk factors: total cholesterol 170mg/dL, HDL 50mg/dL, systolic blood pressure 110mmHg, no smoking, no diabetes, no medication for high blood pressure.", nil);
        
    } else {
        self.purposeText = NSLocalizedString(@"The American Heart Association and the American College of Cardiology developed a risk score for future heart disease and stroke as the first step for prevention. By entering your own data the app will provide a personalized estimate of your risk of heart attack or stroke over the next 10 years, as well as over your lifetime. It will also provide optimal risk scores for someone your age, gender, and race, which are used to estimate your relative ‘heart age.’ This does not apply to people with existing cardiovascular disease. It also does not apply to people with LDL>190mg/dL, who should consult with their doctor. The estimated risk score and heart age can be affected in people taking cholesterol medications.\n\n[Note the 10-year risk score and heart age only applies to ages 40-79, while the lifetime risk score is calculated for ages 20-59.]\n\nOptimal risk factors: total cholesterol 170mg/dL, HDL 50mg/dL, systolic blood pressure 110mmHg, no smoking, no diabetes, no medication for high blood pressure.", nil);
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
