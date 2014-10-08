//
//  APHHeartAgeVersusCell.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeVersusCell.h"

@implementation APHHeartAgeVersusCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    
    // General declartions
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Color declarations
    UIColor *fillColor = [UIColor whiteColor];
    
    // Box that will enclose the Age and Heart Age
    CGFloat lineWidth = 1.0; //change line width here
    
    UIBezierPath *bgRect = [UIBezierPath bezierPathWithRect:rect];
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, lineWidth);
    [fillColor setFill];
    [bgRect fill];
    CGContextRestoreGState(context);
    
    // Divider line
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor); //change color here
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context, rect.size.width/2, 80);
    CGContextAddLineToPoint(context, rect.size.width/2, rect.size.height - 30);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    NSString *yourAgeCaption = NSLocalizedString(@"Actual Age", @"Actual age of the person taking the survey. (title case)");
    NSString *yourHeartAgeCaption = NSLocalizedString(@"Heart Age", @"Heart age of the person taking the survey. (title case)");
    NSString *heartAgeTitle = NSLocalizedString(@"Your Heart Age Estimate", @"Your Heart Age Estimate (title case)");
    
    NSString *actualAge = [NSString stringWithFormat:@"%lu", self.age];
    NSString *heartAge = [NSString stringWithFormat:@"%lu", self.heartAge];
    
    // Text drawing
    CGRect heartAgeTitleRect = CGRectMake(0, 30, rect.size.width, 21);
    
    CGRect yourAgeCaptionRect = CGRectMake(0, 83, rect.size.width/2, 21);
    CGRect ageTextRect = CGRectMake(0, 104, rect.size.width/2, 86);
    
    CGRect yourHeartAgeCaptionRect = CGRectMake(rect.size.width/2, 83, rect.size.width/2, 21);
    CGRect heartAgeTextRect = CGRectMake(rect.size.width/2, 104, rect.size.width/2, 86);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    CGContextSaveGState(context);
    
    [heartAgeTitle drawInRect:heartAgeTitleRect
               withAttributes:@{
                                NSFontAttributeName: [UIFont systemFontOfSize:17.0],
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSForegroundColorAttributeName: [UIColor blackColor]
                                }];
    
    [yourAgeCaption drawInRect:yourAgeCaptionRect
                withAttributes:@{
                                 NSFontAttributeName: [UIFont systemFontOfSize:17.0],
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: [UIColor grayColor]
                                 }];
    
    [actualAge drawInRect:ageTextRect
           withAttributes:@{
                            NSFontAttributeName: [UIFont systemFontOfSize:72.0],
                            NSParagraphStyleAttributeName: paragraphStyle,
                            NSForegroundColorAttributeName: [UIColor grayColor]
                            }];
    
    [yourHeartAgeCaption drawInRect:yourHeartAgeCaptionRect
                     withAttributes:@{
                                      NSFontAttributeName: [UIFont systemFontOfSize:17.0],
                                      NSParagraphStyleAttributeName: paragraphStyle,
                                      NSForegroundColorAttributeName: [UIColor orangeColor]
                                      }];
    
    [heartAge drawInRect:heartAgeTextRect
          withAttributes:@{
                           NSFontAttributeName: [UIFont systemFontOfSize:72.0],
                           NSParagraphStyleAttributeName: paragraphStyle,
                           NSForegroundColorAttributeName: [UIColor orangeColor]
                           }];
    
    CGContextRestoreGState(context);
}

@end
