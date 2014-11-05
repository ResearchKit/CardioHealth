//
//  APHFitnessTestCustomView.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/7/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessSixMinuteFitnessTestView.h"
#import <CoreLocation/CoreLocation.h>

static CGFloat kAPHFitnessTestMetersToFeetConversion = 3.28084;

@interface APHFitnessSixMinuteFitnessTestView ()
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceTotalLabel;


@property (assign) CLLocationDistance totalDistance;
@end

@implementation APHFitnessSixMinuteFitnessTestView

- (void)commonInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveHeartBPMNotification:)
                                                 name:@"APHFitnessHeartRateBPMUpdated"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveStepCountNotification:)
                                                 name:@"APHFitnessStepCountUpdated"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveUpdatedLocationNotification:)
                                                 name:@"APHFitnessDistanceUpdated"
                                               object:nil];

    self.heartRateLabel.text = @"--";
    [self.heartRateLabel setBackgroundColor:[UIColor yellowColor]];
    [self addSubview:self.heartRateLabel];
    
    self.stepCountLabel.text = @"--";
    [self.stepCountLabel setBackgroundColor:[UIColor yellowColor]];
    [self addSubview:self.stepCountLabel];
    
    [self.distanceTotalLabel setBackgroundColor:[UIColor yellowColor]];
    [self addSubview:self.distanceTotalLabel];
    
    //Initialize to 0
    self.totalDistance = 0;
}

- (id)initWithFrame:(CGRect)aRect
{
    if ((self = [super initWithFrame:aRect])) {
        [self commonInit];
        
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"APHFitnessHeartRateBPMUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"APHFitnessStepCountUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"APHFitnessDistanceUpdated" object:nil];
}

/*********************************************************************************/
#pragma mark - NSNotification Methods
/*********************************************************************************/

- (void)receiveHeartBPMNotification:(NSNotification *)notification {
    NSDictionary *heartBeatInfo = notification.userInfo;
    
    self.heartRateLabel.text = [NSString stringWithFormat:@"%@", [heartBeatInfo objectForKey:@"heartBPM"]];
}

- (void)receiveStepCountNotification:(NSNotification *)notification {
    NSDictionary *stepCountInfo = notification.userInfo;

    self.stepCountLabel.text = [NSString stringWithFormat:@"%@", [stepCountInfo objectForKey:@"stepCount"]];
}

- (void)receiveUpdatedLocationNotification:(NSNotification *)notification {
    
    NSMutableDictionary *distanceUpdatedInfo = [notification.userInfo mutableCopy];
    
    CLLocationDistance distance = [[distanceUpdatedInfo objectForKey:@"distance"] doubleValue];
    
    self.totalDistance += distance;
    
    CLLocationDistance distanceInFeet = self.totalDistance * kAPHFitnessTestMetersToFeetConversion;
    
    self.distanceTotalLabel.text = [NSString stringWithFormat:@"%f", distanceInFeet];
}

@end
