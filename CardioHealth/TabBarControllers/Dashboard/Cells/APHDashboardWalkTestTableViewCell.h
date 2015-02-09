//
//  APHDashboardWalkTestTableViewCell.h
//  MyHeartCounts
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import APCAppCore;

FOUNDATION_EXPORT NSString *const kAPHDashboardWalkTestTableViewCellIdentifier;

@interface APHDashboardWalkTestTableViewCell : APCDashboardTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *peakHeartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *finalHeartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastPerformedDateLabel;

@end
