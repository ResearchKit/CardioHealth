//
//  APHDashboardProgressViewCell.m

//
//  Created by Ramsundar Shandilya on 9/9/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

@import APCAppleCore;
#import "APHDashboardProgressViewCell.h"

@implementation APHDashboardProgressViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    //TODO: Sammple Value. Remove later.
    self.progressView.progress = 0.75;
    self.progressView.progressLabel.textColor = [UIColor blackColor];
    self.progressView.tintColor = [UIColor appPrimaryColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
