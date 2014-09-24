//
//  APHDashboardGraphViewCell.h

//
//  Created by Ramsundar Shandilya on 9/8/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APHDashboardGraphViewCell;

@protocol APHDashboardGraphViewCellDelegate <NSObject>

@required
- (void)dashboardGraphViewCellDidTapExpandForCell:(APHDashboardGraphViewCell *)cell;

@end

@interface APHDashboardGraphViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *graphView;

@property (weak, nonatomic) id <APHDashboardGraphViewCellDelegate> delegate;

@end
