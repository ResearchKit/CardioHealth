//
//  APHHeartAgeRiskEstimateCell.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APHHeartAgeRiskEstimateCell : UITableViewCell

@property (nonatomic, strong) NSString *riskEstimateTitle;
@property (nonatomic, strong) NSString *calculatedRiskLabel;
@property (nonatomic, strong) NSString *optimalFactorRiskLabel;
@property (nonatomic, strong) NSString *calculatedRiskValue;
@property (nonatomic, strong) NSString *optimalFactorRiskValue;

@end
