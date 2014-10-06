//
//  APHFitnessTestWalkingViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTestWalkingViewController.h"
#import "APHFitnessTestResult.h"

@interface APHFitnessTestWalkingViewController () <APHFitnessTestRecorderDelegate>
@property (weak, nonatomic) IBOutlet UILabel *myCounterLabel;
@property (weak, nonatomic) IBOutlet UILabel *myDistanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *startWalking;

- (IBAction)startWalkingButton:(id)sender;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) APHTimer *countDownTimer;
@property (strong, nonatomic) APHFitnessTestRecorder *recorder;
@property (weak, nonatomic) IBOutlet UILabel *heartRate;

@end

@implementation APHFitnessTestWalkingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.startWalking setEnabled:NO];

    RKActiveStep *step = (RKActiveStep*) self.step;
    APHFitnessTestCustomRecorderConfiguration *configuration = step.recorderConfigurations[0];
    self.recorder = (APHFitnessTestRecorder *) [configuration recorderForStep:step taskInstanceUUID:self.taskViewController.taskInstanceUUID];
    self.recorder.recorderDelegate = self;
    
    [self.recorder viewController:self willStartStepWithView:self.view];

    //Setup file result
    APHFitnessTestResult *fileResult = [[APHFitnessTestResult alloc] initWithStep:self.step];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *fitnessTestFilePath = [documentsPath stringByAppendingPathComponent:@"APHfitnessTest"];
    
    NSURL *fitnessTestFileURL = [NSURL fileURLWithPath:fitnessTestFilePath];
    [fileResult setFileUrl:fitnessTestFileURL];
    [fileResult setTaskInstanceUUID:self.taskViewController.taskInstanceUUID];

    
    //Set the initial text for the counter
    self.myCounterLabel.text = [NSString stringWithFormat:@"00:20"]; //TODO Change back to desired time that shows
    
    //setup Timer
    self.countDownTimer = [[APHTimer alloc] initWithTimeInterval:20.0];
    [self.countDownTimer setDelegate:self];
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
#pragma mark - APHTimer delegate methods
/*********************************************************************************/

- (void)aphTimer:(APHTimer *)timer didUpdateCountDown:(NSString *)countdown {
    self.myCounterLabel.text = countdown;
}

- (void)aphTimer:(APHTimer *)timer didFinishCountingDown:(NSString *)countdown {
    
    
    //self.taskViewController.taskDelegate respondsToSelector:@selector()
    
    NSError *error = nil;
    [self.recorder stop:&error];
    
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            //TODO RKStepViewControllerNavigationDirectionForward is giving me an error
           [self.delegate stepViewControllerDidFinish:self navigationDirection:0];
            
        }
    }
}

/*********************************************************************************/
#pragma mark - APHFitnessRecorder delegate methods
/*********************************************************************************/

- (void)recorder:(APHFitnessTestRecorder *)recorder didRecordData:(NSDictionary *)dictionary {
    NSLog(@"Did Record Data");
}

- (void)recorder:(APHFitnessTestRecorder *)recorder didUpdateHeartRate:(NSInteger)heartRateBPM {
    NSLog(@"heartRateBPM %ld", heartRateBPM);
    self.heartRate.text = [NSString stringWithFormat:@"%ld", (long)heartRateBPM];
}

- (void)recorder:(APHFitnessTestRecorder *)recorder didFinishPrep:(BOOL)finishedPrep {
    [self.startWalking setEnabled:YES];
}

- (void)recorder:(APHFitnessTestRecorder *)recorder didUpdateLocation:(CLLocationDistance)location {
    NSLog(@"Steps Count %f", location);
    self.myDistanceLabel.text = [NSString stringWithFormat:@"%.2f Mi", location];
}

- (void)recorder:(APHFitnessTestRecorder *)recorder didUpdateStepCount:(NSInteger)stepsCount {
     NSLog(@"Steps Count %ld", stepsCount);
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"GPS Signal"
                                          message:[NSString stringWithFormat:@"Step Count %ld", (long)stepsCount]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    [self performSelector:@selector(dismiss:) withObject:alertController afterDelay:1];
}


/*********************************************************************************/
#pragma mark - IBAction methods
/*********************************************************************************/

- (IBAction)startWalkingButton:(id)sender {
    [self.countDownTimer start];
    //[self.distanceTracker start];
    
    [self.startWalking setEnabled:NO];

    //Start the recorder
    NSError *error;

    [self.recorder viewController:self willStartStepWithView:self.view];
    
    BOOL  startedSuccessfully = [self.recorder start:&error];
    
    if (!startedSuccessfully) {
        //TODO handle this.
        [error handle];
    }
}
@end
