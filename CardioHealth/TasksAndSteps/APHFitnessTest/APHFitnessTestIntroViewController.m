//
//  APHFitnessTestIntroViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTestIntroViewController.h"
#import "APHImportantDetailsViewController.h"

@interface APHFitnessTestIntroViewController ()
@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;
- (IBAction)getStarted:(id)sender;

- (IBAction)viewImportantDetails:(id)sender;
@end

@implementation APHFitnessTestIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)getStarted:(id)sender {
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKStepViewControllerNavigationDirectionForward];
        }
    }
}

- (IBAction)viewImportantDetails:(id)sender {
    APHImportantDetailsViewController *importantDetailsVC = [[APHImportantDetailsViewController alloc] init];
    [self presentViewController:importantDetailsVC animated:YES completion:^{
        NSLog(@"Presented");
    }];
}
@end
