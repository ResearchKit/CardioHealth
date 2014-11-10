//
//  APHWithdrawSurveyViewController.m
//  CardioHealth
//
//  Created by Ramsundar Shandilya on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHWithdrawSurveyViewController.h"

@interface APHWithdrawSurveyViewController ()

@end

@implementation APHWithdrawSurveyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareContent
{
    [self surveyFromJSONFile:@"WithdrawStudy"];
    [self.tableView reloadData];
}

@end
