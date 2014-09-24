//
//  APHLearnResourceViewCell.m

//
//  Created by Ramsundar Shandilya on 9/9/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import "APHLearnResourceViewCell.h"
#import "UIColor+CardioHealth.h"

@implementation APHLearnResourceViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.titleLabel setTextColor:[UIColor parkinsonBlackColor]];
    [self.descriptionLabel setTextColor:[UIColor parkinsonLightGrayColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
