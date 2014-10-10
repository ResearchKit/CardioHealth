//
//  APHIntroVideoViewController.m
//  Parkinson
//
//  Created by Karthik Keyan on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHIntroVideoViewController.h"
#import "APHStudyOverviewViewController.h"
static NSString *const kVideoShownKey = @"VideoShown";
@interface APHIntroVideoViewController ()

@end

@implementation APHIntroVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kVideoShownKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void) skip {
    
    [self.navigationController pushViewController:[APHStudyOverviewViewController new] animated:YES];
}

@end
