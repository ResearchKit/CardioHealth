// 
//  NSString+CustomMethods.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 

#import "NSString+CustomMethods.h"

@implementation NSString (CustomMethods)

- (BOOL)hasContent
{
    BOOL  answer = YES;
    if (self.length == 0) {
        answer = NO;
    }
    return  answer;
}

@end
