//
//  APHDashboardWalkTestTableViewCell.m
//  MyHeart Counts
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHDashboardWalkTestTableViewCell.h"

NSString * const kAPHDashboardWalkTestTableViewCellIdentifier = @"APHDashboardWalkTestTableViewCell";

static CGFloat kWalkDataLabelFontSize = 15.0f;
static CGFloat kDateLabelFontSize = 13.0f;

@implementation APHDashboardWalkTestTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupAppearance];
}

- (void)setupAppearance
{
    self.distanceLabel.font = [UIFont appLightFontWithSize:kWalkDataLabelFontSize];
    self.distanceLabel.textColor = [UIColor appSecondaryColor2];
    
    self.peakHeartRateLabel.font = [UIFont appLightFontWithSize:kWalkDataLabelFontSize];
    self.peakHeartRateLabel.textColor = [UIColor appSecondaryColor2];
    
    self.finalHeartRateLabel.font = [UIFont appLightFontWithSize:kWalkDataLabelFontSize];
    self.finalHeartRateLabel.textColor = [UIColor appSecondaryColor2];
    
    self.lastPerformedDateLabel.font = [UIFont appLightFontWithSize:kDateLabelFontSize];
    self.lastPerformedDateLabel.textColor = [UIColor appSecondaryColor3];
}

@end
