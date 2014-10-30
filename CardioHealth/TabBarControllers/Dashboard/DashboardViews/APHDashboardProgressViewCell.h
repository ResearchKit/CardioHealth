//
//  APHDashboardProgressViewCell.h
//  Parkinson
//
//  Created by Ramsundar Shandilya on 9/9/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

@import APCAppleCore;
#import <UIKit/UIKit.h>

@interface APHDashboardProgressViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet APCCircularProgressView *progressView;

@end
