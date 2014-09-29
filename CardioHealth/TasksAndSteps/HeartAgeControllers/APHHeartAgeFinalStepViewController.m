//
//  APHHeartAgeFinalStepViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 9/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeFinalStepViewController.h"

@interface APHHeartAgeFinalStepViewController ()

@end

@implementation APHHeartAgeFinalStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self.circularProgress setProgress:0.6 animated:YES];
    
    self.ageVersusHeartAge.age = 39;
    self.ageVersusHeartAge.heartAge = 30;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self action:@selector(doneButtonTapped:)];
}

#pragma mark - Actions

- (void)doneButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
        [self.delegate stepViewControllerDidFinish:self navigationDirection:RKStepViewControllerNavigationDirectionForward];
    }
}

@end
