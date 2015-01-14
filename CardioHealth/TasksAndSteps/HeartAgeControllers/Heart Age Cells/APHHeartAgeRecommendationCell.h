//
//  APHHeartAgeRecommendationCell.h
//  MyHeartCounts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APHHeartAgeRecommendationCell : UITableViewCell

@property (nonatomic, strong) NSString *recommendationTitle;
@property (nonatomic, strong) NSString *recommendationContent;
@property (weak, nonatomic) IBOutlet UIButton *ASCVDLinkButton;
@end
