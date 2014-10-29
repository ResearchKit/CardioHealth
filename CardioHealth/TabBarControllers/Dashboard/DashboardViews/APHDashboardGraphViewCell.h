//
//  APHDashboardGraphViewCell.h
//  Parkinson
//
//  Created by Ramsundar Shandilya on 9/8/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import <UIKit/UIKit.h>
@import APCAppleCore;

@class APHDashboardGraphViewCell;

@protocol APHDashboardGraphViewCellDelegate <NSObject>

@required
- (void)dashboardGraphViewCellDidTapExpandForCell:(APHDashboardGraphViewCell *)cell;

@end

@interface APHDashboardGraphViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *graphContainerView;

@property (weak, nonatomic) id <APHDashboardGraphViewCellDelegate> delegate;

@end
