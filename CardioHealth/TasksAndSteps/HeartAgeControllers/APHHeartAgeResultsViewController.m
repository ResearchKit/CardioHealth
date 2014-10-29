//
//  APHHeartAgeResultsViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeResultsViewController.h"

static CGFloat kProgressBarHeight = 10.0;

@interface APHHeartAgeResultsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *actualAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedTenYearFactorLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedLifetimeFactorLabel;

@property (weak, nonatomic) IBOutlet UIView *circularProgressBar;

@property (nonatomic, strong) APCCircularProgressView *circularProgress;
@property (nonatomic, strong) APCStepProgressBar *progressBar;
@end

@implementation APHHeartAgeResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    UIColor *viewBackgroundColor = [UIColor colorWithRed:220.0f/255.0f
                                                   green:225.0f/255.0f
                                                    blue:215.0f/255.0f
                                                   alpha:1.0f];
    
    [self.view setBackgroundColor:viewBackgroundColor];
    
    self.navigationItem.title = NSLocalizedString(@"Survey Complete", @"Survey Complete");
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTapped:)];

    
    CGRect progressBarFrame = CGRectMake(0, 0, self.view.frame.size.width, kProgressBarHeight);
    self.progressBar = [[APCStepProgressBar alloc] initWithFrame:progressBarFrame
                                                           style:APCStepProgressBarStyleOnlyProgressView];
    self.progressBar.numberOfSteps = 14;
    
    [self.view addSubview:self.progressBar];
    
    self.circularProgress = [[APCCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.circularProgressBar.frame), CGRectGetHeight(self.circularProgressBar.frame))];
    self.circularProgress.hidesProgressValue = YES;
    [self.circularProgress setProgress:0.33];
    
    [self.circularProgressBar addSubview:self.circularProgress];
}

- (void)viewDidLayoutSubviews {
    
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.circularProgressBar.frame), CGRectGetHeight(self.circularProgressBar.frame));
    [self.circularProgress setFrame:rect];
    
    CGRect progressBarRect = CGRectMake(0, 0, self.view.frame.size.width, kProgressBarHeight);
    [self.progressBar setFrame:progressBarRect];
    
    self.actualAgeLabel.text = [NSString stringWithFormat:@"%lu", self.actualAge];
    self.heartAgeLabel.text = [NSString stringWithFormat:@"%lu", self.heartAge];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    NSString *tenYearRiskPercentage = [numberFormatter stringFromNumber:self.tenYearRisk];
    
    self.estimatedTenYearFactorLabel.text = [NSString stringWithFormat:@"You have an estimated %@ 10-year risk of ASCVD.", tenYearRiskPercentage];
    
    self.estimatedLifetimeFactorLabel.text = [NSString stringWithFormat:@"You have an estimated %lu%% lifetime risk of ASCVD.", [self.lifetimeRisk integerValue]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.progressBar setCompletedSteps:14 animation:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)doneButtonTapped:(UIBarButtonItem *)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKStepViewControllerNavigationDirectionForward];
        }
    }
}

@end
