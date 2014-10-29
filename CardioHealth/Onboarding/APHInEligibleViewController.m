//
//  APHInEligibleViewController.m
//  Parkinson
//
//  Created by Dhanush Balachandran on 10/16/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APHInEligibleViewController.h"

@interface APHInEligibleViewController ()


@end

@implementation APHInEligibleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Eligibility", @"");
}

- (IBAction)okayButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}



@end
