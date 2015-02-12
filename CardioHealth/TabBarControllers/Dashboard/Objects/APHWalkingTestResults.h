//
//  APHWalkingTestResults.h
//  CardioHealth
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APHTableViewItem.h"

@import APCAppCore;

@interface APHWalkingTestResults : NSObject

/*
 Array of APHTableViewDashboardWalkingTestItem
 */
@property (nonatomic, strong) NSArray *results;

@end
