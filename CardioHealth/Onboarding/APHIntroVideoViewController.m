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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kVideoShownKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
}

- (void) skip {
    APHStudyOverviewViewController * vc = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"StudyOverviewVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
