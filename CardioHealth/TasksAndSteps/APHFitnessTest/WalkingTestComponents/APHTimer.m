//
//  APHTimer.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHTimer.h"

@interface  APHTimer()

@property (assign) NSInteger hours;
@property (assign) NSInteger minutes;
@property (assign) NSInteger seconds;
@property (assign) NSInteger secondsLeft;

@property (strong, nonatomic) NSTimer *timer;
@end

@implementation APHTimer

- (instancetype) initWithTimeInterval:(NSTimeInterval)totalSeconds {
    self = [super init];
    
    if (self) {
        //setup the timer
        _secondsLeft = totalSeconds;
        
        _hours = _secondsLeft / 3600;
        _minutes = (_secondsLeft % 3600) / 60;
        _seconds = (_secondsLeft % 3600) % 60;
        
    }
    
    return self;
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

- (void)start {
    [self countdownTimer];
}

- (void)pause {
    
}

- (void)updateCounter:(NSTimer *)theTimer {
    if(self.secondsLeft > 0 ){
        self.secondsLeft -- ;
        self.hours = self.secondsLeft / 3600;
        self.minutes = (self.secondsLeft % 3600) / 60;
        self.seconds = (self.secondsLeft %3600) % 60;
        
        //TODO delegate call and send this to the label
//        self.myCounterLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        [self SendUpdateCounterString:[NSString stringWithFormat:@"%02ld:%02ld", (long)self.minutes, (long)self.seconds]];
    }
    else{
        self.secondsLeft = 0;
        
        [self sendStopString:@"Finished"];        
    }
}

-(void)countdownTimer{
    
    self.secondsLeft = self.hours = self.minutes = self.seconds = self.secondsLeft;
    if([self.timer isValid])
    {
        self.timer = nil;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
    
}

/*********************************************************************************/
#pragma mark - Delegate Methods
/*********************************************************************************/

- (void)SendUpdateCounterString:(NSString*)countDownMessage {
    
    if ([self.delegate respondsToSelector:@selector(aphTimer:didUpdateCountDown:)]) {
        [self.delegate aphTimer:self didUpdateCountDown:countDownMessage];
    }
}

- (void)sendStopString:(NSString*)countDownMessage {
    
    if ([self.delegate respondsToSelector:@selector(aphTimer:didFinishCountingDown:)]) {
        [self.delegate aphTimer:self didFinishCountingDown:countDownMessage];
    }
}


@end
