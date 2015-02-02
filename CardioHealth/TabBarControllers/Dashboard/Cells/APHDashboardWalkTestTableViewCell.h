//
//  APHDashboardWalkTestTableViewCell.h
//  MyHeartCounts
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import APCAppCore;

FOUNDATION_EXPORT NSString *const kAPHDashboardWalkTestTableViewCellIdentifier;

@class APHDashboardWalkTestTableViewCell;

@protocol APHDashboardWalkTestTableViewCellDelegate <NSObject>

- (void)dashboardWalkTestTableViewCellDidTapExpand:(APHDashboardWalkTestTableViewCell *)cell;

@end

@interface APHDashboardWalkTestTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *tintView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *peakHeartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *finalHeartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastPerformedDateLabel;
@property (strong, nonatomic) UIColor *tintColor;
@property (weak, nonatomic) IBOutlet UIButton *resizeButton;

@property (weak, nonatomic) id <APHDashboardWalkTestTableViewCellDelegate> delegate;

@end
