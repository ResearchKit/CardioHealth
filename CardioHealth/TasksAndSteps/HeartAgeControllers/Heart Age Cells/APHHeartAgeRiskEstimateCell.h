//
//  APHHeartAgeRiskEstimateCell.h
//  MyHeartCounts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import APCAppCore;

@interface APHHeartAgeRiskEstimateCell : UITableViewCell

@property (nonatomic, strong) NSString *riskEstimateTitle;
@property (nonatomic, strong) NSString *calculatedRiskLabel;
@property (nonatomic, strong) NSString *optimalFactorRiskLabel;
@property (nonatomic, strong) NSString *calculatedRiskValue;
@property (nonatomic, strong) NSString *optimalFactorRiskValue;

@end
