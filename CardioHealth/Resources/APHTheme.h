// 
//  APHTheme.h 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@interface APHTheme : NSObject

+ (UIColor *)colorForRightCellBorder;
+ (CGFloat)widthForRightCellBorder;

+ (UIColor *)colorForDividerLine;
+ (CGFloat)widthForDividerLine;

+ (UIColor *)colorForActivityOutline;
+ (UIColor *)colorForActivitySleep;
+ (UIColor *)colorForActivityInactive;
+ (UIColor *)colorForActivitySedentary;
+ (UIColor *)colorForActivityModerate;
+ (UIColor *)colorForActivityVigorous;

@end
