//
//  APHHeartAgeResultsViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeResultsViewController.h"

@interface APHHeartAgeResultsViewController ()

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
