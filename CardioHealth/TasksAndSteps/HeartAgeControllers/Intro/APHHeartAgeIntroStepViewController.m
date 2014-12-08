// 
//  APHHeartAgeIntroStepViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHHeartAgeIntroStepViewController.h"
static NSString *kKludgeIdentifierForHeartAgeTaskB = @"APHHeartAgeB-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";
@interface APHHeartAgeIntroStepViewController ()
@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;

@property (weak, nonatomic) IBOutlet UITextView *purposeTextView;
@end

@implementation APHHeartAgeIntroStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(cancelButtonTapped:)];
    
    UIColor *viewBackgroundColor = [UIColor appSecondaryColor4];
    
    [self.view setBackgroundColor:viewBackgroundColor];

  [self.getStartedButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
    
    if ([self.taskViewController.task.identifier isEqualToString:kKludgeIdentifierForHeartAgeTaskB]) {
        self.purposeTextView.text = @"The American Heart Association and the American College of Cardiology developed a risk score for heart disease and stroke as the first step for prevention. It is based on following healthy individuals for many years to understand which risk factors predicted cardiovascular disease. By entering your own data, requiring blood pressure and cholesterol values, the app will provide a personalized estimate of your risk of heart attack or stroke over the next 10 years, as well as over your lifetime. It will also provide optimal risk scores for someone your age, gender, and race. We also calculate a Heart Age by comparing your 10-year risk against the optimal risk, with an older age indicating higher risk.\n\n[Note the 10-year risk score and Heart Age only applies to ages 40-79, while the lifetime risk score is calculated for ages 20-59.]";
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonTapped:(id)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidCancel:)] == YES) {
            [self.delegate stepViewControllerDidCancel:self];
        }
    }
}

- (IBAction)getStartedWasTapped:(id)sender
{
    [self.getStartedButton setEnabled:NO];
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKSTStepViewControllerNavigationDirectionForward];
        }
    }
}

@end
