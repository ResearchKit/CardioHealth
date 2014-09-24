//
//  OnBoardingOptionsViewController.m
//  OnBoarding
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import APCAppleCore;
#import "APHSignInViewController.h"
#import "APHSignupOptionsViewController.h"
#import "APHSignUpGeneralInfoViewController.h"

@interface APHSignupOptionsViewController ()

@end

@implementation APHSignupOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"Welcome", @"");
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


#pragma mark - IBActions

- (IBAction) signUp {
    [self.navigationController pushViewController:[APHSignUpGeneralInfoViewController new] animated:YES];
}

- (IBAction) signIn {
    APCSignInViewController *signInViewController = [[APHSignInViewController alloc] initWithNibName:@"APCSignInViewController" bundle:[NSBundle appleCoreBundle]];
    [self.navigationController pushViewController:signInViewController animated:YES];
}

@end
