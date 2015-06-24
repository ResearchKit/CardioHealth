//
//  APHDailyInsight.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 6/23/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHDailyInsight.h"

@implementation APHDailyInsight

- (void)sharedInit
{
    _dailyInsightCaption    = [[NSMutableAttributedString alloc] initWithString:@""];
    _dailyInsightSubCaption = @"";
    _iconName               = @"";
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCaption:(NSAttributedString*)caption subCaption:(NSString*)subCaption iconName:(NSString*)iconName
{
    self = [super init];
    
    if (self)
    {
        _dailyInsightCaption    = caption;
        _dailyInsightSubCaption = subCaption;
        _iconName               = iconName;
    }
    
    return self;
}

@end
