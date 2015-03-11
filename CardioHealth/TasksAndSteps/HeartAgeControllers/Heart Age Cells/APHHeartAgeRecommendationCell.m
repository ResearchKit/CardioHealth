//
//  APHHeartAgeRecommendationCell.m
//  MyHeart Counts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import "APHHeartAgeRecommendationCell.h"

@interface APHHeartAgeRecommendationCell()

@property (weak, nonatomic) IBOutlet UILabel *recommendationCellTitle;


@end

@implementation APHHeartAgeRecommendationCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHideLinkButton:(BOOL)hideLinkButton
{
    _hideLinkButton = hideLinkButton;
    
    self.ASCVDLinkButton.hidden = hideLinkButton;
}

@end
