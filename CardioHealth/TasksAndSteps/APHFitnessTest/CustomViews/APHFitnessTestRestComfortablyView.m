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
@property (weak, nonatomic) IBOutlet UIImageView *heartImage;

@property (weak, nonatomic) IBOutlet UILabel *stepCountLbl;
@property (assign) BOOL blinkStatus;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation APHFitnessTestRestComfortablyView

- (void)commonInit
{
    self.blinkStatus = NO;
    
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
    
//    self.stepCountLbl.text = @"--";
//    [self.stepCountLbl setBackgroundColor:[UIColor yellowColor]];
//    [self addSubview:self.stepCountLbl];

    self.distanceTrackerLabel.text = [NSString stringWithFormat:@"%@", self.totalDistance];

//    [self.distanceTrackerLbl setBackgroundColor:[UIColor yellowColor]];
//    [self addSubview:self.distanceTrackerLbl];
}

- (void)setTheTotalDistance:(NSNumber *)totalDistance {
    self.distanceTrackerLabel.text = [NSString stringWithFormat:@"%@", self.totalDistance];
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
    
    if (!self.timer) {
        self.timer = [NSTimer
                      scheduledTimerWithTimeInterval:(NSTimeInterval)(0.5)
                      target:self
                      selector:@selector(blink)
                      userInfo:nil
                      repeats:YES];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.distanceTrackerLabel.alpha = 1;
    }];
}

-(void)blink{
    
    if(self.blinkStatus == NO){
        
        [UIView animateWithDuration:0.1 animations:^{
            self.heartImage.alpha = 0;
        }];
        
        [self.heartImage setImage:[UIImage imageNamed:@"CD-pulsingIcon-1-2"]];
        self.blinkStatus = YES;
    }else {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.heartImage.alpha = 0.9;
        }];
        
        [self.heartImage setImage:[UIImage imageNamed:@"CD-pulsingIcon-1-2"]];
        self.blinkStatus = NO;
    }
}

- (void)receiveStepCountNotification:(NSNotification *)notification {
    NSDictionary *stepCountInfo = notification.userInfo;
    
    self.stepCountLbl.text = [NSString stringWithFormat:@"%@", [stepCountInfo objectForKey:@"stepCount"]];
}

- (void)receiveUpdatedLocationNotification:(NSNotification *)notification {
    //NSDictionary *distanceUpdatedInfo = notification.userInfo;
    
    self.distanceTrackerLabel.text = [NSString stringWithFormat:@"%@ft", self.totalDistance];
}


@end
