//
//  APHDashboardProgressViewCell.h

//
//  Created by Ramsundar Shandilya on 9/9/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APCCircularProgressView;

@interface APHDashboardProgressViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet APCCircularProgressView *progressView;

@end
