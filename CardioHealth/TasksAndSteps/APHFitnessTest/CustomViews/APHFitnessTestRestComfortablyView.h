// 
//  APHFitnessTestRestComfortablyView.h 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
@import APCAppCore;
#import <UIKit/UIKit.h>

@interface APHFitnessTestRestComfortablyView : UIView

@property (weak, nonatomic) IBOutlet UILabel *distanceTrackerLabel;


@property (strong, nonatomic) NSNumber *totalDistance;

@end
