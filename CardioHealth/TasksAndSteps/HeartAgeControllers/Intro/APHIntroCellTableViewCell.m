//
//  APHIntroCellTableViewCell.m
//  MyHeart Counts
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHIntroCellTableViewCell.h"

@interface APHIntroCellTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *purposeBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthBodyLabel;

@end

@implementation APHIntroCellTableViewCell

- (void)setPurposeBody:(NSString *)purposeBody
{
    _purposeBody = purposeBody;
    
    self.purposeBodyLabel.text = _purposeBody;
}

- (void)setLengthBody:(NSString *)lengthBody
{
    _lengthBody = lengthBody;
    
    self.lengthBodyLabel.text = _lengthBody;
}

@end
