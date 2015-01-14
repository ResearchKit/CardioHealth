//
//  APHIntroCellTableViewCell.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 1/13/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHIntroCellTableViewCell.h"

@interface APHIntroCellTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *purposeBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthBodyLabel;

@end

@implementation APHIntroCellTableViewCell

//- (void)awakeFromNib
//{
//    // Initialization code
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

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
