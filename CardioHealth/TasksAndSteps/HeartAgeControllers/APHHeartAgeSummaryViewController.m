//
//  APHHeartAgeSummaryViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeSummaryViewController.h"

@interface APHHeartAgeSummaryViewController ()

@end

@implementation APHHeartAgeSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Survey Complete";
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTapped:)];
    
    //[self.circularProgress setProgress:self.taskProgress animated:YES];
    
    APCStepProgressBar *progressBar = [[APCStepProgressBar alloc] initWithFrame:CGRectMake(0, 65, self.view.frame.size.width, 10)
                                                                          style:APCStepProgressBarStyleOnlyProgressView];
    progressBar.numberOfSteps = 4;
    [progressBar setCompletedSteps:1 animation:YES];
    [self.view addSubview:progressBar];
    
    //self.ageVersusHeartAge.age = self.actualAge;
    //self.ageVersusHeartAge.heartAge = self.heartAge;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    NSString *tenYearRiskPercentage = [numberFormatter stringFromNumber:self.tenYearRisk];
    NSString *tenYearRiskCaption = [NSString stringWithFormat:@"You have an estimated %@ 10-y risk of ASCVD.", tenYearRiskPercentage];
    
    NSString *lifetimeRiskCaption = [NSString stringWithFormat:@"Your lifetime risk of ASCVD is %lu%%.", [self.lifetimeRisk integerValue]];
    
    //self.tenYearRiskText.text = tenYearRiskCaption;
    //self.improvementText.text = lifetimeRiskCaption;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)doneButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView
#pragma mark Datasource

#pragma mark Delegates

@end
