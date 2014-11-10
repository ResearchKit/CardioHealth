//
//  APHHeartAgeResultsViewController.h
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <APCAppleCore/APCAppleCore.h>

@interface APHHeartAgeResultsViewController : APCStepViewController

@property (nonatomic) CGFloat taskProgress;
@property (nonatomic) NSUInteger actualAge;
@property (nonatomic) NSUInteger heartAge;
@property (nonatomic, strong) NSNumber *tenYearRisk;
@property (nonatomic, strong) NSNumber *lifetimeRisk;
@property (nonatomic, strong) NSNumber *optimalTenYearRisk;
@property (nonatomic, strong) NSNumber *optimalLifetimeRisk;

@end
