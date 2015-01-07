//
//  APHFitnessAllocation.h
//  MyHeartCounts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import APCAppCore;

@import APCAppCore;

extern NSString *const kDatasetDateKey;
extern NSString *const kDatasetValueKey;
extern NSString *const kDatasetSegmentNameKey;
extern NSString *const kDatasetSegmentColorKey;
extern NSString *const kDatasetSegmentKey;
extern NSString *const kDatasetDateHourKey;
extern NSString *const kSegmentSumKey;
extern NSString *const kSevenDayFitnessStartDateKey;
extern NSString *const APHSevenDayAllocationDataIsReadyNotification;

@interface APHFitnessAllocation : NSObject

- (instancetype)initWithAllocationStartDate:(NSDate *)startDate;
- (NSArray *)allocationData;
- (NSNumber *)totalDistanceForDays:(NSInteger)days;
- (void) startDataCollection;
@end
