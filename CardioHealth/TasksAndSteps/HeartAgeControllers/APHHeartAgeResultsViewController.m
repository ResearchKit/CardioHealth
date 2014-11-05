//
//  APHHeartAgeResultsViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeResultsViewController.h"

@interface APHHeartAgeResultsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *actualAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedTenYearFactorLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedLifetimeFactorLabel;

@property (weak, nonatomic) IBOutlet UIView *circularProgressBar;

@property (nonatomic, strong) APCCircularProgressView *circularProgress;
@end

@implementation APHHeartAgeResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    UIColor *viewBackgroundColor = [UIColor appSecondaryColor4];
    
    [self.view setBackgroundColor:viewBackgroundColor];
    
    self.navigationItem.title = NSLocalizedString(@"Survey Complete", @"Survey Complete");
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTapped:)];
    
    self.circularProgress = [[APCCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.circularProgressBar.frame), CGRectGetHeight(self.circularProgressBar.frame))];
    self.circularProgress.hidesProgressValue = YES;
    NSUInteger allScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.allScheduledTasksForToday;
    NSUInteger completedScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.completedScheduledTasksForToday;
    completedScheduledTasks = MIN(allScheduledTasks, completedScheduledTasks+1);
    CGFloat percent = (CGFloat) completedScheduledTasks / (CGFloat) allScheduledTasks;
    [self.circularProgress setProgress:percent];
    
    [self.circularProgressBar addSubview:self.circularProgress];
}

- (void)viewDidLayoutSubviews {
    
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.circularProgressBar.frame), CGRectGetHeight(self.circularProgressBar.frame));
    [self.circularProgress setFrame:rect];
    
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
