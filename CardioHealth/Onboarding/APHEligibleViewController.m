//
//  APHEligibleViewController.m
//  Parkinson
//
//  Created by Dhanush Balachandran on 10/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHEligibleViewController.h"
#import "APHSignUpGeneralInfoViewController.h"

@interface APHEligibleViewController ()


@end

@implementation APHEligibleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Eligibility", @"");
    
    [self.consentButton addTarget:self action:@selector(showConsent) forControlEvents:UIControlEventTouchUpInside];

}

- (void) startSignUp
{
    APHSignUpGeneralInfoViewController *signUpVC = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpGeneralInfoVC"];
    [self.navigationController pushViewController:signUpVC animated:YES];
}

@end
