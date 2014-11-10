//
//  APHHeartAgeSummaryCell.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeSummaryCell.h"

@interface APHHeartAgeSummaryCell()

@property (weak, nonatomic) IBOutlet UILabel *heartAgeCellTitle;
@property (weak, nonatomic) IBOutlet UILabel *actualAgeCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartAgeCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *actualAge;
@property (weak, nonatomic) IBOutlet UILabel *heartAge;

@end

@implementation APHHeartAgeSummaryCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHeartAgeTitle:(NSString *)heartAgeTitle
{
    _heartAgeTitle = heartAgeTitle;
    
    self.heartAgeCellTitle.text = _heartAgeTitle;
}

- (void)setActualAgeLabel:(NSString *)actualAgeLabel
{
    _actualAgeLabel = actualAgeLabel;
    
    self.actualAgeCellLabel.text = _actualAgeLabel;
}

- (void)setActualAgeValue:(NSString *)actualAgeValue
{
    _actualAgeValue = actualAgeValue;
    
    self.actualAge.text = _actualAgeValue;
}

- (void)setHeartAgeLabel:(NSString *)heartAgeLabel
{
    _heartAgeLabel = heartAgeLabel;
    
    self.heartAgeCellLabel.text = _heartAgeLabel;
}

- (void)setHeartAgeValue:(NSString *)heartAgeValue
{
    _heartAgeValue = heartAgeValue;
    
    self.heartAge.text = _heartAgeValue;
}

- (void)drawRect:(CGRect)rect
{
    // General declartions
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Color declarations
    UIColor *lightGray = [UIColor colorWithWhite:0.836 alpha:1.000];
    
    // Box that will enclose the Age and Heart Age
    CGFloat lineWidth = 0.5; //change line width here
    
    // Divider line
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, lightGray.CGColor); //change color here
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context, rect.size.width/2, 50 + (lineWidth * 0.5));
    CGContextAddLineToPoint(context, rect.size.width/2, (rect.size.height - 20) + lineWidth * 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // Bottom border
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, lightGray.CGColor); //change color here
    CGContextSetLineWidth(context, lineWidth*2);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // Filled rect
    CGFloat sidebarWidth = 3.0;
    CGRect sidebar = CGRectMake(0, 0, sidebarWidth, rect.size.height);
    UIColor *sidebarColor = [UIColor colorWithRed:0.757 green:0.094 blue:0.129 alpha:1.000];
    [sidebarColor setFill];
    UIRectFill(sidebar);
}

@end
