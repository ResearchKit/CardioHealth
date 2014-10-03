//
//  APHHeartAgeFinalStepViewController.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 9/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <APCAppleCore/APCAppleCore.h>
#import "APHHeartAgeVersusView.h"

@interface APHHeartAgeResultsViewController : UIViewController

@property (nonatomic) CGFloat taskProgress;
@property (nonatomic) NSUInteger actualAge;
@property (nonatomic) NSUInteger heartAge;
@property (nonatomic, strong) NSNumber *tenYearRisk;
@property (nonatomic, strong) NSString *someImprovement;

@end
