//
//  APHFitnessTestWalkingViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTestWalkingViewController.h"

@interface APHFitnessTestWalkingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *myCounterLabel;
@property (strong, nonatomic) NSTimer *timer;

-(void)updateCounter:(NSTimer *)theTimer;
-(void)countdownTimer;

@end

@implementation APHFitnessTestWalkingViewController

int hours, minutes, seconds;
int secondsLeft;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    secondsLeft = 360;
    [self countdownTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateCounter:(NSTimer *)theTimer {
    if(secondsLeft > 0 ){
        secondsLeft -- ;
        hours = secondsLeft / 3600;
        minutes = (secondsLeft % 3600) / 60;
        seconds = (secondsLeft %3600) % 60;
        self.myCounterLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    else{
        secondsLeft = 0;
    }
}

-(void)countdownTimer{
    
    secondsLeft = hours = minutes = seconds = 360;
    if([self.timer isValid])
    {
        self.timer = nil;
    }

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];

}

@end
