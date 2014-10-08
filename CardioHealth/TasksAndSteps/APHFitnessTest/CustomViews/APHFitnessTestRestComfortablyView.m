//
//  APHFitnessTestRestComfortablyView.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/7/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTestRestComfortablyView.h"
@interface APHFitnessTestRestComfortablyView ()

@property (weak, nonatomic) IBOutlet UILabel *heartRateBPMLbl;
@property (weak, nonatomic) IBOutlet UILabel *distanceTrackerLbl;
@property (weak, nonatomic) IBOutlet UILabel *stepCountLbl;

@end

@implementation APHFitnessTestRestComfortablyView

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
    
    self.heartRateBPMLbl.text = @"--";
    [self.heartRateBPMLbl setBackgroundColor:[UIColor yellowColor]];
    [self addSubview:self.heartRateBPMLbl];
    
    self.stepCountLbl.text = @"--";
    [self.stepCountLbl setBackgroundColor:[UIColor yellowColor]];
    [self addSubview:self.stepCountLbl];
    
    self.distanceTrackerLbl.text = @"--";
    [self.distanceTrackerLbl setBackgroundColor:[UIColor yellowColor]];
    [self addSubview:self.distanceTrackerLbl];
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

- (void)receiveHeartBPMNotification:(NSNotification *)notification {
    NSDictionary *heartBeatInfo = notification.userInfo;
    
    self.heartRateBPMLbl.text = [NSString stringWithFormat:@"%@", [heartBeatInfo objectForKey:@"heartBPM"]];
}

- (void)receiveStepCountNotification:(NSNotification *)notification {
    NSDictionary *stepCountInfo = notification.userInfo;
    
    self.stepCountLbl.text = [NSString stringWithFormat:@"%@", [stepCountInfo objectForKey:@"stepCount"]];
}

- (void)receiveUpdatedLocationNotification:(NSNotification *)notification {
    NSDictionary *distanceUpdatedInfo = notification.userInfo;
    
    self.distanceTrackerLbl.text = [NSString stringWithFormat:@"%@", [distanceUpdatedInfo objectForKey:@"distance"]];
}


@end
