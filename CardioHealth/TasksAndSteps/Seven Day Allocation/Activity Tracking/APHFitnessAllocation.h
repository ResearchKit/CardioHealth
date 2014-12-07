//
//  APHFitnessAllocation.h
//  MyHeartCounts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kDatasetDateKey;
extern NSString *const kDatasetValueKey;
extern NSString *const kDatasetSegmentNameKey;
extern NSString *const kDatasetSegmentColorKey;
extern NSString *const kDatasetSegmentKey;
extern NSString *const kDatasetDateHourKey;
extern NSString *const kSegmentSumKey;
extern NSString *const APHSevenDayAllocationDataIsReadyNotification;

@protocol APHFitnessAllocationDelegate <NSObject>

@required
- (void)datasetDidUpdate:(NSArray *)dataset forKind:(NSInteger)kind;

@end

@interface APHFitnessAllocation : NSObject

@property (nonatomic, weak) id <APHFitnessAllocationDelegate> delegate;

- (instancetype)initWithAllocationStartDate:(NSDate *)startDate;
- (void)allocationForDays:(NSInteger)days;
- (void)reloadAllocationDatasets;

@end
