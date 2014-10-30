//
//  APHDashboardMessageViewCell.m
//  Parkinson
//
//  Created by Ramsundar Shandilya on 9/9/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import "APHDashboardMessageViewCell.h"

@implementation APHDashboardMessageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setupAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupAppearance
{
    self.titleLabel.font = [UIFont appLightFontWithSize:19.0f];
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    
    self.messageLabel.font = [UIFont appLightFontWithSize:16.0f];
    self.messageLabel.textColor = [UIColor appSecondaryColor2];
}

- (void)setType:(APHDashboardMessageViewCellType)type
{
    switch (type) {
        case kDashboardMessageViewCellTypeAlert:
        {
            self.titleLabel.text = NSLocalizedString(@"Alert",nil);
        }
            break;
        case kDashboardMessageViewCellTypeInsight:
        {
            self.titleLabel.text = NSLocalizedString(@"Insight", nil);
        }
            break;
        default:{
            NSAssert(0, @"Invalid Cell Type");
        }
            break;
    }
}
@end
