//
//  APHParQQuizViewController.m
//  MyHeart Counts
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHParQQuizTaskViewController.h"
#import "APHDynamicParQQuizTask.h"

@interface APHParQQuizTaskViewController ()

@end

@implementation APHParQQuizTaskViewController

+ (id<ORKTask>)createTask:(APCScheduledTask *) __unused scheduledTask
{
    APHDynamicParQQuizTask *task = [[APHDynamicParQQuizTask alloc] init];
    
    return task;
}
@end
