//
//  APHCardioInsightCell.m
//  MyHeart Counts
//
// Copyright (c) 2015, Stanford Medical. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "APHCardioInsightCell.h"

NSString *const kAPHDashboardDailyInsightHeaderCellIdentifier = @"APHCardioInsightHeaderCell";
NSString *const kAPHDashboardDailyInsightCellIdentifier = @"APHDashboardDailyInsightCell";

@interface APHCardioInsightCell()

@property (nonatomic, weak) IBOutlet UILabel *cellTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *cellSubtitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *cellImageView;

@end

@implementation APHCardioInsightCell

- (void)awakeFromNib {
    // Initialization code
    
    self.textLabel.textColor = [UIColor appSecondaryColor1];
    self.textLabel.font = [UIFont appRegularFontWithSize:16.0];
    
    self.detailTextLabel.textColor = self.tintColor;
    self.detailTextLabel.font = [UIFont appRegularFontWithSize:24.0];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    
    self.cellTitleLabel.textColor = tintColor;
    self.infoButton.tintColor = tintColor;
}

- (void)setCellTitle:(NSString *)cellTitle
{
    _cellTitle = cellTitle;
    
    self.cellTitleLabel.text = cellTitle;
}

- (void)setCellAttributedTitle:(NSAttributedString *)cellAttributedTitle
{
    _cellAttributedTitle = cellAttributedTitle;
    self.cellTitleLabel.attributedText = cellAttributedTitle;
}

- (void)setCellSubtitle:(NSString *)cellSubtitle
{
    _cellSubtitle = cellSubtitle;
    
    self.cellSubtitleLabel.text = cellSubtitle;
}

- (void)setCellAttributedSubtitle:(NSAttributedString *)cellAttributedSubtitle
{
    _cellAttributedSubtitle = cellAttributedSubtitle;
    
    self.cellSubtitleLabel.attributedText = cellAttributedSubtitle;
}

- (void)setCellImage:(UIImage *)cellImage
{
    _cellImage = cellImage;
    
    self.cellImageView.image = cellImage;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat borderWidth = 1.0;
    
    UIColor *borderColor = [UIColor appTertiaryGrayColor];
    
    // Bottom border
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, borderWidth);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // Sidebar
    CGFloat sidebarWidth = 4.0;
    CGFloat sidbarHeight = rect.size.height;
    CGRect sidebar = CGRectMake(0, 0, sidebarWidth, sidbarHeight);
    
    UIColor *sidebarColor = self.tintColor;
    [sidebarColor setFill];
    UIRectFill(sidebar);
}

@end
