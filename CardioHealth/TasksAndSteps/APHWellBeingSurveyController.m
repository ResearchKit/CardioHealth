//
//  APHWellBeingSurveyController.m
//  MyHeartCounts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import "APHWellBeingSurveyController.h"

@interface APHWellBeingSurveyController ()

@end

@implementation APHWellBeingSurveyController

- (void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];

    self.navigationBar.topItem.title = NSLocalizedString(@"Well-Being Survey", nil);
}



@end
