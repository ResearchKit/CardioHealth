//
//  APHWalkTestDetailsTableViewCell.m
//  CardioHealth
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHWalkTestDetailsTableViewCell.h"

NSString * const kAPHWalkTestDetailsTableViewCellIdentifier = @"APHWalkTestDetailsTableViewCell";

@implementation APHWalkTestDetailsTableViewCell

@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;
@synthesize detailTextLabel = _detailTextLabel;

- (void)awakeFromNib {
    // Initialization code
    
    self.textLabel.textColor = [UIColor appSecondaryColor1];
    self.textLabel.font = [UIFont appRegularFontWithSize:16.0f];
    
    self.detailTextLabel.textColor = self.tintColor;
    self.detailTextLabel.font = [UIFont appRegularFontWithSize:24.0f];
    
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    self.tintView.backgroundColor = tintColor;
    self.detailTextLabel.textColor = tintColor;
    self.imageView.tintColor = tintColor;
}

@end
