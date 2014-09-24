//
//  APHLearnMasterTableViewCell.h
//  BasicTabBar
//
//  Created by Henry McGilton on 9/7/14.
//  Copyright (c) 2014 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APHLearnMasterTableViewCell;

@protocol APHLearnMasterTableViewCellDelegate <NSObject>

@required

- (void)learnMasterTableViewCellDidTapReadMoreForCell:(APHLearnMasterTableViewCell *)cell;

@end


@interface APHLearnMasterTableViewCell : UITableViewCell

@property  (nonatomic, weak)  IBOutlet  UIView    *confirmationView;
@property  (nonatomic, weak)  IBOutlet  UILabel   *titleLabel;
@property  (nonatomic, weak)  IBOutlet  UILabel   *descriptionLabel;

@property (nonatomic, weak) id <APHLearnMasterTableViewCellDelegate> delegate;

@end
