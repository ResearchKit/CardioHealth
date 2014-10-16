//
//  APHHeartAgeTextCell.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 10/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeTextCell.h"

@interface APHHeartAgeTextCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentTextLabel;

@end

@implementation APHHeartAgeTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 21)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.contentTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 63)];
        self.contentTextLabel.textColor = [UIColor grayColor];
        self.contentTextLabel.numberOfLines = 3;
        self.contentTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.contentTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentTextLabel];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[title]-10-[text]"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:@{
                                                                                                @"title": self.titleLabel,
                                                                                                @"text": self.contentTextLabel
                                                                                                }]];
        
        // Leading/Trailing margins
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentTextLabel
                                                                     attribute:NSLayoutAttributeLeadingMargin
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeLeadingMargin
                                                                    multiplier:1.0
                                                                      constant:20.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeTrailingMargin
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentTextLabel
                                                                     attribute:NSLayoutAttributeTrailingMargin
                                                                    multiplier:1.0
                                                                      constant:20.0]];
        // Leading/Trailing margins
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                     attribute:NSLayoutAttributeLeadingMargin
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeLeadingMargin
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                     attribute:NSLayoutAttributeTrailingMargin
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeTrailingMargin
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        // Top constraint
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                     attribute:NSLayoutAttributeTopMargin
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeTopMargin
                                                                    multiplier:1.0
                                                                      constant:10.0]];
    }
    
    return self;
}

- (void)setCellTitleText:(NSString *)cellTitleText
{
    self.titleLabel.text = cellTitleText;
}

- (void)setCellDetailText:(NSString *)cellDetailText
{
    self.contentTextLabel.text = cellDetailText;
}

- (void)drawRect:(CGRect)rect
{
    // General declartions
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Box that will enclose the Age and Heart Age
    CGFloat lineWidth = 1.0; //change line width here
    
    // Divider line
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor); //change color here
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
