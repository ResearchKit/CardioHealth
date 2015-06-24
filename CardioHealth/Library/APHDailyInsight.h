//
//  APHDailyInsight.h
//  CardioHealth
//
//  Created by Justin Warmkessel on 6/23/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APHDailyInsight : NSObject

@property (nonatomic, strong) NSAttributedString* dailyInsightCaption;
@property (nonatomic, strong) NSString* dailyInsightSubCaption;
@property (nonatomic, strong) NSString* iconName; 

- (instancetype)initWithCaption:(NSAttributedString*)caption subCaption:(NSString*)subCaption iconName:(NSString*)iconName;

@end
