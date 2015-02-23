//
//  APHHeartAgeRiskEstimateCell.h
//  MyHeart Counts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import APCAppCore;

@interface APHHeartAgeRiskEstimateCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *riskEstimateDescription;
@property (weak, nonatomic) IBOutlet UILabel *riskCellTitle;
@property (weak, nonatomic) IBOutlet UILabel *calculatedRisk;
@property (weak, nonatomic) IBOutlet UILabel *optimalFactorRisk;
@end
