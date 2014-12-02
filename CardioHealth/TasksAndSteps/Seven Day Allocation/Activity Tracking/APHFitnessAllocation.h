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

@interface APHFitnessAllocation : NSObject

- (instancetype)initWithAllocationStartDate:(NSDate *)startDate;
- (NSArray *)allocationForDays:(NSInteger)days;
- (void)reloadAllocationDatasets;

@end
