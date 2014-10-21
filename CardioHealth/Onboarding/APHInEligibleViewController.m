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

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *okayButton;


@end

@implementation APHInEligibleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Eligibility", @"");
    
    [self setUpAppearance];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"<", @"") style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backBarButton;
}


- (void) setUpAppearance
{
    self.label.font = [UIFont appRegularFontWithSize: 17];
    self.label.textColor = [UIColor appSecondaryColor1];
    [self.okayButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
    [self.okayButton setTitleColor:[UIColor appSecondaryColor4] forState:UIControlStateNormal];
}

- (IBAction)okayButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
