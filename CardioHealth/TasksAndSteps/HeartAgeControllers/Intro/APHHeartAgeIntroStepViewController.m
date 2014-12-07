// 
//  APHHeartAgeIntroStepViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHHeartAgeIntroStepViewController.h"

@interface APHHeartAgeIntroStepViewController ()
@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;

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
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKSTStepViewControllerNavigationDirectionForward];
        }
    }
}

@end
