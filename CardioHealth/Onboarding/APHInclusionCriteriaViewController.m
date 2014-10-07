//
//  APHInclusionCriteriaViewController.m
//  Parkinson
//
//  Created by Ramsundar Shandilya on 9/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHInclusionCriteriaViewController.h"
#import "APHSignUpGeneralInfoViewController.h"

@interface APHInclusionCriteriaViewController ()

@end

@implementation APHInclusionCriteriaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startSignUp
{
    [self.navigationController pushViewController:[APHSignUpGeneralInfoViewController new] animated:YES];
}

@end
