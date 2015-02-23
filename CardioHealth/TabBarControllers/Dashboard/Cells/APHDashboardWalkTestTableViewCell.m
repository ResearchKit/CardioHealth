//
//  APHDashboardWalkTestTableViewCell.m
//  MyHeart Counts
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHDashboardWalkTestTableViewCell.h"

NSString * const kAPHDashboardWalkTestTableViewCellIdentifier = @"APHDashboardWalkTestTableViewCell";

@implementation APHDashboardWalkTestTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupAppearance];
}

- (void)setupAppearance
{
    self.distanceLabel.font = [UIFont appLightFontWithSize:15.0f];
    self.distanceLabel.textColor = [UIColor appSecondaryColor2];
    
    self.peakHeartRateLabel.font = [UIFont appLightFontWithSize:15.0f];
    self.peakHeartRateLabel.textColor = [UIColor appSecondaryColor2];
    
    self.finalHeartRateLabel.font = [UIFont appLightFontWithSize:15.0f];
    self.finalHeartRateLabel.textColor = [UIColor appSecondaryColor2];
    
    self.lastPerformedDateLabel.font = [UIFont appLightFontWithSize:13.0f];
    self.lastPerformedDateLabel.textColor = [UIColor appSecondaryColor3];
}

@end
