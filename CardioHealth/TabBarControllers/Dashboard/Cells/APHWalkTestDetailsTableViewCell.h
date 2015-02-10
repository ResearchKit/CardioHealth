//
//  APHWalkTestDetailsTableViewCell.h
//  CardioHealth
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import APCAppCore;

FOUNDATION_EXPORT NSString *const kAPHWalkTestDetailsTableViewCellIdentifier;

@interface APHWalkTestDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *tintView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;
@property (strong, nonatomic) UIColor *tintColor;

@end
