//
//  APHHeartAgeRecommendationCell.h
//  MyHeart Counts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import APCAppCore;

@interface APHHeartAgeRecommendationCell : UITableViewCell

@property (nonatomic, strong) NSString *recommendationTitle;
@property (nonatomic, strong) NSString *recommendationContent;
@property (weak, nonatomic) IBOutlet UIButton *ASCVDLinkButton;
@property (weak, nonatomic) IBOutlet UILabel *recommendationText;

@property (nonatomic) BOOL hideLinkButton;

@end
