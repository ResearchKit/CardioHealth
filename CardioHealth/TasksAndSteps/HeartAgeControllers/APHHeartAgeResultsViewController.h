// 
//  APHHeartAgeResultsViewController.h 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 <INSTITUTION-NAME-TBD> All rights reserved. 
// 
 
#import <APCAppCore/APCAppCore.h>

@interface APHHeartAgeResultsViewController : APCStepViewController

@property (nonatomic) CGFloat taskProgress;
@property (nonatomic) NSUInteger actualAge;
@property (nonatomic) NSUInteger heartAge;
@property (nonatomic, strong) NSNumber *tenYearRisk;
@property (nonatomic, strong) NSNumber *lifetimeRisk;
@property (nonatomic, strong) NSNumber *optimalTenYearRisk;
@property (nonatomic, strong) NSNumber *optimalLifetimeRisk;

@end
