//
//  APHTheme.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
