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
    self.circularProgress.progressValue = 0.6;
    
    self.ageVersusHeartAge.age = 39;
    self.ageVersusHeartAge.heartAge = 30;
    
//    self.ageVersusHeartAge.layer.borderWidth = 1.0;
//    self.ageVersusHeartAge.layer.borderColor = [[UIColor orangeColor] CGColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
