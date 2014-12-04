//
//  APHFitnessAllocation.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 12/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kDatasetDateKey;
extern NSString *const kDatasetValueKey;
extern NSString *const kDatasetSegmentNameKey;
extern NSString *const kDatasetSegmentColorKey;
extern NSString *const kDatasetSegmentKey;
extern NSString *const kDatasetDateHourKey;
extern NSString *const kSegmentSumKey;

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
