//
//  APHHeartAgeResultsViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeResultsViewController.h"

@interface APHHeartAgeResultsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *actualAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedTenYearFactorLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedLifetimeFactorLabel;

@end

@implementation APHHeartAgeResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    UIColor *viewBackgroundColor = [UIColor colorWithRed:220.0f/255.0f
                                                   green:225.0f/255.0f
                                                    blue:215.0f/255.0f
                                                   alpha:1.0f];
    
    [self.view setBackgroundColor:viewBackgroundColor];
}

- (void)viewDidLayoutSubviews {
    self.actualAgeLabel.text = [NSString stringWithFormat:@"%lu", self.actualAge];
    self.heartAgeLabel.text = [NSString stringWithFormat:@"%lu", self.heartAge];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    NSString *tenYearRiskPercentage = [numberFormatter stringFromNumber:self.tenYearRisk];
    
    self.estimatedTenYearFactorLabel.text = [NSString stringWithFormat:@"You have an estimated %@ 10-year risk of ASCVD.", tenYearRiskPercentage];
    
    self.estimatedLifetimeFactorLabel.text = [NSString stringWithFormat:@"You have an estimated %lu%% lifetime risk of ASCVD.", [self.lifetimeRisk integerValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
