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

static CGFloat kProgressBarHeight = 10.0;

@interface APHFitnessTestSummaryViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;


@property (weak, nonatomic) IBOutlet UIView *circularProgressBar;

@property (nonatomic, strong) APCCircularProgressView *circularProgress;
@property (nonatomic, strong) APCStepProgressBar *progressBar;
@end

@implementation APHFitnessTestSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //If iPhone plus then make the phone larger. Constraints have aspect ratio set.
    NSArray *labelArray = @[self.label1, self.label2, self.label3, self.label4, self.label5];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]){
        if ([UIScreen mainScreen].nativeScale > 2.1) { // Nativescale is always 3 for iPhone 6 Plus, even when running in scaled mode
            for (UILabel *label in labelArray) {
                [label setFont:[UIFont systemFontOfSize:20]];
            }
            
        } else if ([UIScreen mainScreen].nativeScale == 2.1) {
            
        }
    }
        
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
    self.progressBar.numberOfSteps = 6;
    
    [self.view addSubview:self.progressBar];
    
    self.circularProgress = [[APCCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.circularProgressBar.frame), CGRectGetHeight(self.circularProgressBar.frame))];
    self.circularProgress.hidesProgressValue = YES;
    [self.circularProgress setProgress:0.33];
    
    [self.circularProgressBar addSubview:self.circularProgress];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.circularProgressBar.frame), CGRectGetHeight(self.circularProgressBar.frame));
    [self.circularProgress setFrame:rect];
    
    CGRect progressBarRect = CGRectMake(0, 0, self.view.frame.size.width, kProgressBarHeight);
    [self.progressBar setFrame:progressBarRect];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.progressBar setCompletedSteps:6 animation:YES];
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
