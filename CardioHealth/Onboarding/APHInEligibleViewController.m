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

- (IBAction)next:(id)sender
{
    APCShareViewController *shareViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"ShareVC"];
    [self.navigationController pushViewController:shareViewController animated:YES];
}

@end
