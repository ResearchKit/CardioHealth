// 
//  APHAppDelegate.h 
//  MyHeart Counts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
@import APCAppCore;
#import <UIKit/UIKit.h>

@class APHFitnessAllocation;

@interface APHAppDelegate : APCAppDelegate

@property (nonatomic, strong) APHFitnessAllocation *sevenDayFitnessAllocationData;

@end

