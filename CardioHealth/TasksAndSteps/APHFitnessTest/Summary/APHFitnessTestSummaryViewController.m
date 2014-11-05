//
//  APHFitnessTestSummaryViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTestSummaryViewController.h"

static NSString *ActivityCell = @"ActivityProgressCell";
static NSString *HeartAgeCell = @"HeartAgeCell";
static NSString *InformationCell = @"InformationCell";

@interface APHFitnessTestSummaryViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;


@property (weak, nonatomic) IBOutlet UIView *circularProgressBar;

@property (nonatomic, strong) APCCircularProgressView *circularProgress;
@end

@implementation APHFitnessTestSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
            
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
    self.label3.text = [NSString stringWithFormat:@"%lu/%lu", completedScheduledTasks, allScheduledTasks];
    
    [self.circularProgressBar addSubview:self.circularProgress];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.circularProgressBar.frame), CGRectGetHeight(self.circularProgressBar.frame));
    [self.circularProgress setFrame:rect];
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
