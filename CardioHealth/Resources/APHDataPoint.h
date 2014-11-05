//
//  YMLDataPoint.h
//  Scratch
//
//  Created by Farhan Ahmed on 11/2/14.
//  Copyright (c) 2014 Y Media Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APHDataPoint : NSObject

@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, strong) NSDate *timestamp;

- (instancetype)initWithValue:(NSNumber *)value timestamp:(NSDate *)timestamp;

@end
