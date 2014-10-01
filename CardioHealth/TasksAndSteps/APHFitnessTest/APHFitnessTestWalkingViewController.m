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
@property (weak, nonatomic) IBOutlet UILabel *myDistanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *startWalking;

- (IBAction)startWalkingButton:(id)sender;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) APHFitnessTestDistanceTracker *distanceTracker;

-(void)updateCounter:(NSTimer *)theTimer;
-(void)countdownTimer;

@end

@implementation APHFitnessTestWalkingViewController

int hours, minutes, seconds;
int secondsLeft;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.startWalking setEnabled:NO];

    //setup the timer
    secondsLeft = 360;
    
    secondsLeft -- ;
    hours = secondsLeft / 3600;
    minutes = (secondsLeft % 3600) / 60;
    seconds = (secondsLeft %3600) % 60;
    self.myCounterLabel.text = [NSString stringWithFormat:@"06:00"];
    
    //setup distnace tracker
    self.distanceTracker = [[APHFitnessTestDistanceTracker alloc] init];
    [self.distanceTracker setDelegate:self];
    [self.distanceTracker prepLocationUpdates];
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
        [self.distanceTracker stop];
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

/*********************************************************************************/
#pragma mark - APHFitnessTestDistanceTrackerDelegate delegate methods
/*********************************************************************************/
/**
 * @brief Location has failed to update.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)parameters didFailToUpdateLocationWithError:(NSError *)error {
    
}

/**
 * @brief Location updates did pause.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)parameters didPauseLocationTracking:(CLLocationManager *)manager {
    
}

/**
 * @brief Location updates did resume.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)parameters didResumeLocationTracking:(CLLocationManager *)manager {
    
}

/**
 * @brief Did update locations.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)parameters didUpdateLocations:(CLLocationDistance)distance {
//    UIAlertController *alertController = [UIAlertController
//                                          alertControllerWithTitle:@"Updates"
//                                          message:[NSString stringWithFormat:@"%f", location]
//                                          preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction
//                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
//                                   style:UIAlertActionStyleCancel
//                                   handler:^(UIAlertAction *action)
//                                   {
//                                       NSLog(@"Cancel action");
//                                   }];
//    
//    UIAlertAction *okAction = [UIAlertAction
//                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction *action)
//                               {
//                                   NSLog(@"OK action");
//                               }];
//    
//    [alertController addAction:cancelAction];
//    [alertController addAction:okAction];
//    
//    [self presentViewController:alertController animated:YES completion:nil];
    
    self.myDistanceLabel.text = [NSString stringWithFormat:@"%.2f Meters", distance];
}

- (void)locationManager:(CLLocationManager *)locationManager finishedPrepLocation:(BOOL)finishedPrep {
    if (finishedPrep) {
        [self.startWalking setEnabled:YES];
    }
}

/**
 * @brief Signal strength changed
 */
- (void)locationManager:(CLLocationManager*)locationManager signalStrengthChanged:(APHLocationManagerGPSSignalStrenght)signalStrength {
    
}

/**
 * @brief GPS is consistently weak
 */
- (void)locationManagerSignalConsistentlyWeak:(CLLocationManager*)manager {
    
}

/**
 * @brief Debug text
 */
- (void)locationManager:(CLLocationManager *)locationManager debugText:(NSString *)text {
    
}

/*********************************************************************************/
#pragma mark - IBAction methods
/*********************************************************************************/

- (IBAction)startWalkingButton:(id)sender {
    [self countdownTimer];
    [self.distanceTracker start];
    
    self.startWalking.titleLabel.text = @"Stop Walking";
}
@end
