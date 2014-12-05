// 
//  APHImportantDetailsViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 <INSTITUTION-NAME-TBD> All rights reserved. 
// 
 
#import "APHImportantDetailsViewController.h"

@interface APHImportantDetailsViewController ()
- (IBAction)dismissModalView:(id)sender;

@end

@implementation APHImportantDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)dismissModalView:(id)sender {
    NSLog(@"CLick");
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
