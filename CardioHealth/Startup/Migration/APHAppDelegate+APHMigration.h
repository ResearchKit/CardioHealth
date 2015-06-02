//
//  APHAppDelegate+APHMigration.h
//  MyHeart Counts 
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHAppDelegate.h"
@import APCAppCore;



@interface APHAppDelegate (APHMigration)

- (BOOL) performMigrationFromOneToTwoWithError:(NSError * __autoreleasing *)error;
- (BOOL) performMigrationFromThreeToFourWithError:(NSError * __autoreleasing *)error;
@end
