// 
//  APHTheme.h 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 <INSTITUTION-NAME-TBD> All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@interface APHTheme : NSObject

+ (UIColor *)colorForRightCellBorder;
+ (CGFloat)widthForRightCellBorder;

+ (UIColor *)colorForDividerLine;
+ (CGFloat)widthForDividerLine;

+ (UIColor *)colorForActivityOutline;
+ (UIColor *)colorForActivityInactive;
+ (UIColor *)colorForActivitySedentary;
+ (UIColor *)colorForActivityModerate;
+ (UIColor *)colorForActivityVigorous;

@end
