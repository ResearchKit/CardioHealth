// 
//  APHDataPoint.h 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 <INSTITUTION-NAME-TBD> All rights reserved. 
// 
 
#import <Foundation/Foundation.h>

@interface APHDataPoint : NSObject

@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, strong) NSDate *timestamp;

- (instancetype)initWithValue:(NSNumber *)value timestamp:(NSDate *)timestamp;

@end
