//
//  APHHeartAgeTodaysActivitiesCell.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeTodaysActivitiesCell.h"

@import APCAppleCore;

@interface APHHeartAgeTodaysActivitiesCell()

@property (weak, nonatomic) IBOutlet UILabel *todaysActivitiesCaption;
@property (weak, nonatomic) IBOutlet UILabel *activitiesStatus;
@property (weak, nonatomic) IBOutlet APCCircularProgressView *circularProgress;

@end

@implementation APHHeartAgeTodaysActivitiesCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _circularProgress.hidesProgressValue = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCaption:(NSString *)caption
{
    _caption = caption;
    
    self.todaysActivitiesCaption.text = _caption;
}

- (void)setActivitiesCount:(NSString *)activitiesCount
{
    _activitiesCount = activitiesCount;
    
    self.activitiesStatus.text = _activitiesCount;
}

- (void)setActivitiesProgress:(NSNumber *)activitiesProgress
{
    _activitiesProgress = activitiesProgress;
    
    [self.circularProgress setProgress:[_activitiesProgress doubleValue] animated:YES];
}

@end
