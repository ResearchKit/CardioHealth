//
//  APHFitnessTestRestComfortablyView.h
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/7/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import APCAppCore;
#import <UIKit/UIKit.h>

@interface APHFitnessTestRestComfortablyView : UIView

@property (weak, nonatomic) IBOutlet UILabel *distanceTrackerLabel;


@property (strong, nonatomic) NSNumber *totalDistance;

@end
