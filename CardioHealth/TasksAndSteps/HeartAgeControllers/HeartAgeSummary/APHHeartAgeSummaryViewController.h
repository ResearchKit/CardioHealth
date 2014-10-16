//
//  APHHeartAgeSummaryViewController.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@import APCAppleCore;

@interface APHHeartAgeSummaryViewController : APCStepViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) CGFloat taskProgress;
@property (nonatomic) NSUInteger actualAge;
@property (nonatomic) NSUInteger heartAge;
@property (nonatomic, strong) NSNumber *tenYearRisk;
@property (nonatomic, strong) NSNumber *lifetimeRisk;

@end
