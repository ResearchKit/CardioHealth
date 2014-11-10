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

@end
