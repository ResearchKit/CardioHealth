//
//  APHHeartAgeSummaryCell.h
//  MyHeart Counts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import APCAppCore;

@interface APHHeartAgeSummaryCell : UITableViewCell

@property (nonatomic, strong) NSString *heartAgeTitle;
@property (nonatomic, strong) NSString *actualAgeLabel;
@property (nonatomic, strong) NSString *heartAgeLabel;
@property (nonatomic, strong) NSString *actualAgeValue;
@property (nonatomic, strong) NSString *heartAgeValue;

@property (weak, nonatomic) IBOutlet UILabel *actualAge;
@property (weak, nonatomic) IBOutlet UILabel *heartAge;

@end
