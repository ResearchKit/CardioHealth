//
//  APHHeartAgeFinalStepViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 9/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeResultsViewController.h"

@interface APHHeartAgeResultsViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *heartAgeResultsNavBar;
@property (weak, nonatomic) IBOutlet APCCircularProgressView *circularProgress;
@property (weak, nonatomic) IBOutlet APHHeartAgeVersusView *ageVersusHeartAge;
@property (weak, nonatomic) IBOutlet UILabel *tenYearRiskText;
@property (weak, nonatomic) IBOutlet UILabel *improvementText;

@end

@implementation APHHeartAgeResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Heart Age Test";
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTapped:)];
    
    [self.circularProgress setProgress:self.taskProgress animated:YES];
    
    self.ageVersusHeartAge.age = self.actualAge;
    self.ageVersusHeartAge.heartAge = self.heartAge;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    NSString *tenYearRiskPercentage = [numberFormatter stringFromNumber:self.tenYearRisk];
    NSString *tenYearRiskCaption = [NSString stringWithFormat:@"You have an estimated %@ 10-y risk of hard Atherosclerotic Cardio Vascular Disease.", tenYearRiskPercentage];
    self.tenYearRiskText.text = tenYearRiskCaption;
    self.improvementText.text = self.someImprovement;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Actions

- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
