//
//  APHDashboardWalkTestTableViewCell.m
//  CardioHealth
//
//  Created by Ramsundar Shandilya on 2/2/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHDashboardWalkTestTableViewCell.h"

NSString * const kAPHDashboardWalkTestTableViewCellIdentifier = @"APHDashboardWalkTestTableViewCell";

@implementation APHDashboardWalkTestTableViewCell

@synthesize tintColor = _tintColor;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setupAppearance
{
    self.titleLabel.font = [UIFont appRegularFontWithSize:19.0f];
    
    self.distanceLabel.font = [UIFont appLightFontWithSize:15.0f];
    self.distanceLabel.textColor = [UIColor appSecondaryColor2];
    
    self.peakHeartRateLabel.font = [UIFont appLightFontWithSize:15.0f];
    self.peakHeartRateLabel.textColor = [UIColor appSecondaryColor2];
    
    self.finalHeartRateLabel.font = [UIFont appLightFontWithSize:15.0f];
    self.finalHeartRateLabel.textColor = [UIColor appSecondaryColor2];
    
    self.lastPerformedDateLabel.font = [UIFont appLightFontWithSize:13.0f];
    self.lastPerformedDateLabel.textColor = [UIColor appSecondaryColor3];
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    self.tintView.backgroundColor = tintColor;
    self.titleLabel.textColor = tintColor;
    self.resizeButton.imageView.tintColor = tintColor;
}

- (IBAction)expandTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(dashboardGraphViewCellDidTapExpandForCell:)]) {
        [self.delegate dashboardWalkTestTableViewCellDidTapExpand:self];
    }
}

@end
