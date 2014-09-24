//
//  APHIntroVideoViewController.m

//
//  Created by Karthik Keyan on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHIntroVideoViewController.h"
#import "APHSignupOptionsViewController.h"

@interface APHIntroVideoViewController ()

@end

@implementation APHIntroVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) skip {
    APHSignupOptionsViewController *optionsViewController = [[APHSignupOptionsViewController alloc] initWithNibName:@"APHSignupOptionsViewController" bundle:nil];
    
    [self.navigationController pushViewController:optionsViewController animated:YES];
}

@end
