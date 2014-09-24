//
//  APHDashboardMessageViewCell.m

//
//  Created by Ramsundar Shandilya on 9/9/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import "APHDashboardMessageViewCell.h"

@implementation APHDashboardMessageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setType:(APHDashboardMessageViewCellType)type
{
    switch (type) {
        case kDashboardMessageViewCellTypeAlert:
        {
            self.titleLabel.text = NSLocalizedString(@"Alert:", @"Alert:");
        }
            break;
        case kDashboardMessageViewCellTypeInsight:
        {
            self.titleLabel.text = NSLocalizedString(@"Insight:", @"Insight:");
        }
            break;
        default:{
            NSAssert(0, @"Invalid Cell Type");
        }
            break;
    }
}
@end
