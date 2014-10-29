//
//  APHDashboardProgressViewCell.m
//  Parkinson
//
//  Created by Ramsundar Shandilya on 9/9/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import "APHDashboardProgressViewCell.h"


@implementation APHDashboardProgressViewCell

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
    self.progressView.progress = 0.75;
    self.progressView.lineWidth = 3.0f;
    self.progressView.progressLabel.textColor = [UIColor appTertiaryColor1];
    self.progressView.tintColor = [UIColor appTertiaryColor1];
    
    self.titleLabel.font = [UIFont appRegularFontWithSize:14.0f];
    self.titleLabel.textColor = [UIColor appSecondaryColor2];
}

@end
