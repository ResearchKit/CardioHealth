//
//  YMLDataPoint.m
//  Scratch
//
//  Created by Farhan Ahmed on 11/2/14.
//  Copyright (c) 2014 Y Media Labs, Inc. All rights reserved.
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
