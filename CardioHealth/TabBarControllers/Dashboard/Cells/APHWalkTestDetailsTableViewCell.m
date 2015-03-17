//
//  APHWalkTestDetailsTableViewCell.m
//  CardioHealth
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHWalkTestDetailsTableViewCell.h"

NSString * const kAPHWalkTestDetailsTableViewCellIdentifier = @"APHWalkTestDetailsTableViewCell";

static CGFloat kTextFontSize = 16.0f;
static CGFloat kDetailFontSize = 24.0f;

@implementation APHWalkTestDetailsTableViewCell

@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;
@synthesize detailTextLabel = _detailTextLabel;

- (void)awakeFromNib {
    // Initialization code
    
    self.textLabel.textColor = [UIColor appSecondaryColor1];
    self.textLabel.font = [UIFont appRegularFontWithSize:kTextFontSize];
    
    self.detailTextLabel.textColor = self.tintColor;
    self.detailTextLabel.font = [UIFont appRegularFontWithSize:kDetailFontSize];
    
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    self.tintView.backgroundColor = tintColor;
    self.detailTextLabel.textColor = tintColor;
    self.imageView.tintColor = tintColor;
}

@end
