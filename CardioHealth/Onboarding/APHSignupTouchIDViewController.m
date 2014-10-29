//
//  APHSignupTouchIDViewController.m
//  Parkinson
//
//  Created by Ramsundar Shandilya on 10/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSignupTouchIDViewController.h"
#import "APHSignUpPermissionsViewController.h"

@interface APHSignupTouchIDViewController ()

@end

@implementation APHSignupTouchIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)next
{
    APHSignUpPermissionsViewController *permissionsVC = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"PermissionsVC"];
    permissionsVC.user = self.user;
    [self.navigationController pushViewController:permissionsVC animated:YES];
}

@end
