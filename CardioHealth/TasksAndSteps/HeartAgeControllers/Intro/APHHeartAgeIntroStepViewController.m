//
//  APHHeartAgeIntroStepViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeIntroStepViewController.h"

static CGFloat kProgressBarHeight = 10.0;

@interface APHHeartAgeIntroStepViewController ()
@property (nonatomic, strong) APCStepProgressBar *progressBar;
@end

@implementation APHHeartAgeIntroStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect progressBarFrame = CGRectMake(0, 0, self.view.frame.size.width, kProgressBarHeight);
    self.progressBar = [[APCStepProgressBar alloc] initWithFrame:progressBarFrame
                                                           style:APCStepProgressBarStyleOnlyProgressView];
    self.progressBar.numberOfSteps = 14;
    
    [self.view addSubview:self.progressBar];

    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect progressBarRect = CGRectMake(0, 0, self.view.frame.size.width, kProgressBarHeight);
    [self.progressBar setFrame:progressBarRect];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.progressBar setCompletedSteps:1 animation:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getStartedWasTapped:(id)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKStepViewControllerNavigationDirectionForward];
        }
    }
}

@end
