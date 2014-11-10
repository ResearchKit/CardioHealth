//
//  APHHeartAgeRiskEstimateCell.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeRiskEstimateCell.h"

@interface APHHeartAgeRiskEstimateCell()

@property (weak, nonatomic) IBOutlet UILabel *riskCellTitle;
@property (weak, nonatomic) IBOutlet UILabel *calculatedRiskCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *optimalFactorsRiskCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *calculatedRisk;
@property (weak, nonatomic) IBOutlet UILabel *optimalFactorRisk;


@end

@implementation APHHeartAgeRiskEstimateCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setRiskEstimateTitle:(NSString *)riskEstimateTitle
{
    _riskEstimateTitle = riskEstimateTitle;
    
    self.riskCellTitle.text = _riskEstimateTitle;
}

- (void)setCalculatedRiskLabel:(NSString *)calculatedRiskLabel
{
    _calculatedRiskLabel = calculatedRiskLabel;
    
    self.calculatedRiskCellLabel.text = _calculatedRiskLabel;
}

- (void)setCalculatedRiskValue:(NSString *)calculatedRiskValue
{
    _calculatedRiskValue = calculatedRiskValue;
    
    self.calculatedRisk.text = _calculatedRiskValue;
}

- (void)setOptimalFactorRiskLabel:(NSString *)optimalFactorRiskLabel
{
    _optimalFactorRiskLabel = optimalFactorRiskLabel;
    
    self.optimalFactorsRiskCellLabel.text = _optimalFactorRiskLabel;
}

- (void)setOptimalFactorRiskValue:(NSString *)optimalFactorRiskValue
{
    _optimalFactorRiskValue = optimalFactorRiskValue;
    
    self.optimalFactorRisk.text = _optimalFactorRiskValue;
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
