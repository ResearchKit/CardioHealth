//
//  APHActivityTrackingStepViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHActivityTrackingStepViewController.h"

@interface APHActivityTrackingStepViewController ()

@property (weak, nonatomic) IBOutlet UILabel *daysRemaining;

@property (nonatomic, strong) HKHealthStore *healthStore;

@end

@implementation APHActivityTrackingStepViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.daysRemaining.text = @"7 Days Remaining";
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(handleClose:)];
    self.view.layer.backgroundColor = [UIColor colorWithWhite:0.973 alpha:1.000].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)handleToday:(UIButton *)sender
{
    NSLog(@"Tapped Today.");
}

- (IBAction)handleWeek:(UIButton *)sender
{
    NSLog(@"Tapped Week.");
}

- (void)handleClose:(UIBarButtonItem *)sender
{
    NSLog(@"You tapped close.");
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKStepViewControllerNavigationDirectionForward];
        }
    }
}


@end
