//
//  APHHeartAgeRecommendationCell.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeRecommendationCell.h"

@interface APHHeartAgeRecommendationCell()

@property (weak, nonatomic) IBOutlet UILabel *recommendationCellTitle;
@property (weak, nonatomic) IBOutlet UILabel *recommendationCellContent;

@end

@implementation APHHeartAgeRecommendationCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setRecommendationTitle:(NSString *)recommendationTitle
{
    _recommendationTitle = recommendationTitle;
    
    self.recommendationCellTitle.text = _recommendationTitle;
}

- (void)setRecommendationContent:(NSString *)recommendationContent
{
    _recommendationContent = recommendationContent;
    
    self.recommendationCellContent.text = _recommendationContent;
}

@end
