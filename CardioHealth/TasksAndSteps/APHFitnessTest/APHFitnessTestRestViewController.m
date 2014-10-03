//
//  APHFitnessTestRestViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTestRestViewController.h"

@interface APHFitnessTestRestViewController ()
@property (weak, nonatomic) IBOutlet UILabel *myCounterLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRate;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) APHFitnessTestHeartRateTracker *heartRateTracker;
@property (strong, nonatomic) APHTimer *countDownTimer;

@end

@implementation APHFitnessTestRestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set the initial text for the counter
    self.myCounterLabel.text = [NSString stringWithFormat:@"00:20"]; //Change back to 6
    
    //setup Timer
    self.countDownTimer = [[APHTimer alloc] initWithTimeInterval:20.0];
    [self.countDownTimer setDelegate:self];
    
    //setup heart rate tracker
    self.heartRateTracker = [[APHFitnessTestHeartRateTracker alloc] init];
    [self.heartRateTracker setDelegate:self];
    [self.heartRateTracker prepHeartRateUpdate];
    
    
    [self.countDownTimer start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

-(void)dismiss:(UIAlertController*)alert
{
    [alert dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismissing gps signal strength");
    }];
}

/*********************************************************************************/
#pragma mark - APHFitnessTestHeartRateTrackerDelegate delegate methods
/*********************************************************************************/

- (void)fitnessTestHeartRateTracker:(APHFitnessTestHeartRateTracker *)heartRateTracker didUpdateHeartRate:(NSInteger)heartBPM {
    self.heartRate.text = [NSString stringWithFormat:@"%ld", (long)heartBPM];
}

/*********************************************************************************/
#pragma mark - APHTimer delegate methods
/*********************************************************************************/

- (void)aphTimer:(APHTimer *)timer didUpdateCountDown:(NSString *)countdown {
    self.myCounterLabel.text = countdown;
}

- (void)aphTimer:(APHTimer *)timer didFinishCountingDown:(NSString *)countdown {
    [self.heartRateTracker stop];
    
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKStepViewControllerNavigationDirectionForward];
        }
    }
}

@end
