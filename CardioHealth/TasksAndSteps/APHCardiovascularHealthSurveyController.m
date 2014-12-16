//
//  APHCardiovascularHealthSurveyController.m
//  MyHeartCounts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import "APHCardiovascularHealthSurveyController.h"

@interface APHCardiovascularHealthSurveyController ()

@end

@implementation APHCardiovascularHealthSurveyController

- (void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    
    self.navigationBar.topItem.title = NSLocalizedString(@"Health Survey", nil);
}

@end
