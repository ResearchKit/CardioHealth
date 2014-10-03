//
//  APHFitnessTestWalkingViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTestWalkingViewController.h"

static CGFloat APHFitnessTestWalkingDuractionInSeconds = 20;

@interface APHFitnessTestWalkingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *myCounterLabel;
@property (weak, nonatomic) IBOutlet UILabel *myDistanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *startWalking;

- (IBAction)startWalkingButton:(id)sender;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) APHFitnessTestDistanceTracker *distanceTracker;
@property (strong, nonatomic) APHFitnessTestHeartRateTracker *heartRateTracker;
@property (strong, nonatomic) APHTimer *countDownTimer;

@property (weak, nonatomic) IBOutlet UILabel *heartRate;

@end

@implementation APHFitnessTestWalkingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.startWalking setEnabled:NO];
    
    //Set the initial text for the counter
    self.myCounterLabel.text = [NSString stringWithFormat:@"00:20"]; //Change back to 6
    
    //setup Timer
    self.countDownTimer = [[APHTimer alloc] initWithTimeInterval:20.0];
    [self.countDownTimer setDelegate:self];
    
    //setup distance tracker
    self.distanceTracker = [[APHFitnessTestDistanceTracker alloc] init];
    [self.distanceTracker setDelegate:self];
    [self.distanceTracker prepLocationUpdates];

    //setup heart rate tracker
    self.heartRateTracker = [[APHFitnessTestHeartRateTracker alloc] init];
    [self.heartRateTracker setDelegate:self];
    [self.heartRateTracker prepHeartRateUpdate];
    
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

    double foo = distance / 1609.34;
    self.myDistanceLabel.text = [NSString stringWithFormat:@"%.2f Mi", foo];
}

- (void)locationManager:(CLLocationManager *)locationManager finishedPrepLocation:(BOOL)finishedPrep {
    if (finishedPrep) {
        [self.startWalking setEnabled:YES];
    }
}

/**
 * @brief Signal strength changed
 */
- (void)locationManager:(CLLocationManager*)locationManager signalStrengthChanged:(CLLocationAccuracy)signalStrength {
    
}

/**
 * @brief GPS is consistently weak
 */
- (void)locationManagerSignalConsistentlyWeak:(CLLocationManager*)manager {
    
}

- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)distanceTracker weakGPSSignal:(NSString *)message {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"GPS Signal"
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];

    [self presentViewController:alertController animated:YES completion:nil];

    [self performSelector:@selector(dismiss:) withObject:alertController afterDelay:4];
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
    [self.distanceTracker stop];
    [self.heartRateTracker stop];

    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKStepViewControllerNavigationDirectionForward];
        }
    }
}



/*********************************************************************************/
#pragma mark - IBAction methods
/*********************************************************************************/

- (IBAction)startWalkingButton:(id)sender {
    [self.countDownTimer start];
    [self.distanceTracker start];
    
    [self.startWalking setEnabled:NO];
}
@end
