//
//  APHImportantDetailsViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHImportantDetailsViewController.h"

@interface APHImportantDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)close:(id)sender;

@end

@implementation APHImportantDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect deviceScreenRect = [[UIScreen mainScreen] bounds];
    [self.scrollView setDelegate:self];
    self.scrollView.contentSize = CGSizeMake(deviceScreenRect.size.width, 1400.0);
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

- (IBAction)close:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismissed");
    }];
}
@end
