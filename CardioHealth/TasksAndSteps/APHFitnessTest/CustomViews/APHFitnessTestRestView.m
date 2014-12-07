// 
//  APHFitnessTestRestView.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHFitnessTestRestView.h"

@interface APHFitnessTestRestView ()

@property (weak, nonatomic) IBOutlet UILabel *heartRateBPMLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepCountLabel;

@end

@implementation APHFitnessTestRestView

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

    
    self.heartRateBPMLabel.text = @"--";
    [self.heartRateBPMLabel setBackgroundColor:[UIColor yellowColor]];
    [self addSubview:self.heartRateBPMLabel];
    
    self.stepCountLabel.text = @"--";
    [self.stepCountLabel setBackgroundColor:[UIColor yellowColor]];
    [self addSubview:self.stepCountLabel];
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
}

- (void)receiveHeartBPMNotification:(NSNotification *)notification {
    NSDictionary *heartBeatInfo = notification.userInfo;
    NSLog(@"Custom View Heart Beat Info %@", heartBeatInfo);
    
    
    self.heartRateBPMLabel.text = [NSString stringWithFormat:@"%@", [heartBeatInfo objectForKey:@"heartBPM"]];
}

- (void)receiveStepCountNotification:(NSNotification *)notification {
    NSDictionary *stepCountInfo = notification.userInfo;
    NSLog(@"Custom View Step Count Info %@", stepCountInfo);
    
    self.stepCountLabel.text = [NSString stringWithFormat:@"%@", [stepCountInfo objectForKey:@"stepCount"]];
}


@end
