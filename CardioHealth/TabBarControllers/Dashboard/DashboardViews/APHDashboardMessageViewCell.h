//
//  APHDashboardMessageViewCell.h
//  Parkinson
//
//  Created by Ramsundar Shandilya on 9/9/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, APHDashboardMessageViewCellType) {
    kDashboardMessageViewCellTypeAlert,
    kDashboardMessageViewCellTypeInsight,
};

@interface APHDashboardMessageViewCell : UITableViewCell

@property (nonatomic) APHDashboardMessageViewCellType type;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end
