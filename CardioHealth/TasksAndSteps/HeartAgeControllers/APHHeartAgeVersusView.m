//
//  APHHeartAgeVersusView.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeVersusView.h"

@implementation APHHeartAgeVersusView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    // General declartions
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Color declarations
    UIColor *fillColor = [UIColor colorWithRed:1
                                         green:1
                                          blue:1
                                         alpha:1];
    UIColor *strokeColor = [UIColor colorWithRed:0
                                           green:0
                                            blue:0
                                           alpha:0.5];
    
    // Box that will enclose the Age and Heart Age
    CGFloat lineWidth = 1.0; //change line width here
    
    UIBezierPath *bgRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:0];
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, lineWidth);
    [fillColor setFill];
    [bgRect fill];
    [strokeColor setStroke];
    [bgRect stroke];
    CGContextRestoreGState(context);
    
    // Divider line
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor); //change color here
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context, rect.size.width/2, 0);
    CGContextAddLineToPoint(context, rect.size.width/2, rect.size.height);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // Versus Circle
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2 + 20);
    CGFloat radius = 15;
    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = (2 * (float)M_PI) + startAngle;
    
    UIBezierPath *versusCircle = [UIBezierPath bezierPathWithArcCenter:center
                                                                radius:radius
                                                            startAngle:startAngle
                                                              endAngle:endAngle
                                                             clockwise:YES];
    CGContextSaveGState(context);
    [fillColor setFill];
    [versusCircle fill];
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] set];
    [versusCircle stroke];
    CGContextRestoreGState(context);
    
    NSString *versusCaption = NSLocalizedString(@"vs", @"Abbreviation for the word 'Versus'.");
    
    NSString *yourAgeCaption = NSLocalizedString(@"Your Age", @"Your age.");
    NSString *yourHeartAgeCaption = NSLocalizedString(@"Your Heart Age", @"Your heart age.");
    
    NSString *actualAge = [NSString stringWithFormat:@"%lu", self.age];
    NSString *heartAge = [NSString stringWithFormat:@"%lu", self.heartAge];
    
    // Text drawing
    CGRect versusCaptionRect = CGRectMake(rect.size.width/2 - 7, rect.size.height/2 + 11, radius, radius);
    
    CGRect yourAgeCaptionRect = CGRectMake(0, 14, 140, 21);
    CGRect ageTextRect = CGRectMake(0, 29, 140, 86);
    
    CGRect yourHeartAgeCaptionRect = CGRectMake(140, 14, 140, 21);
    CGRect heartAgeTextRect = CGRectMake(140, 29, 140, 86);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    CGContextSaveGState(context);
    
    [versusCaption drawInRect:versusCaptionRect
               withAttributes:@{
                                NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                NSParagraphStyleAttributeName: paragraphStyle
                               }];
    
    [yourAgeCaption drawInRect:yourAgeCaptionRect
                withAttributes:@{
                                 NSFontAttributeName: [UIFont systemFontOfSize:17.0],
                                 NSParagraphStyleAttributeName: paragraphStyle
                                }];
    
    [yourHeartAgeCaption drawInRect:yourHeartAgeCaptionRect
                     withAttributes:@{
                                      NSFontAttributeName: [UIFont systemFontOfSize:17.0],
                                      NSParagraphStyleAttributeName: paragraphStyle
                                     }];
    
    [actualAge drawInRect:ageTextRect
           withAttributes:@{
                            NSFontAttributeName: [UIFont systemFontOfSize:72.0],
                            NSParagraphStyleAttributeName: paragraphStyle
                           }];
    
    [heartAge drawInRect:heartAgeTextRect
          withAttributes:@{
                           NSFontAttributeName: [UIFont systemFontOfSize:72.0],
                           NSParagraphStyleAttributeName: paragraphStyle
                          }];
    
    CGContextRestoreGState(context);
}

@end
