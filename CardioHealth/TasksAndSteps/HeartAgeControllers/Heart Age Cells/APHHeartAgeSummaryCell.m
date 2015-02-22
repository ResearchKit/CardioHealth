//
//  APHHeartAgeSummaryCell.m
//  MyHeartCounts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import "APHHeartAgeSummaryCell.h"
#import "APHTheme.h"

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


@end
