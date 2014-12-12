//
//  APHRiskEstimatorWebViewController.m
//  MyHeartCounts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//


#import "APHRiskEstimatorWebViewController.h"

static NSString *kASCVDRiskEstimatorLink = @"http://tools.cardiosource.org/ASCVD-Risk-Estimator/#page_reference_patient";

@interface APHRiskEstimatorWebViewController ()
- (IBAction)doneActionButton:(id)sender;

@end

@implementation APHRiskEstimatorWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *url=kASCVDRiskEstimatorLink;
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [self.webView loadRequest:nsrequest];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneActionButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
