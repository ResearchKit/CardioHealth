// 
//  APHDataPoint.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHDataPoint.h"

@implementation APHDataPoint

- (instancetype)initWithValue:(NSNumber *)value timestamp:(NSDate *)timestamp
{
    self = [super init];
    
    if (self) {
        _value = value;
        _timestamp = timestamp;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@", self.value, self.timestamp];
}

@end
