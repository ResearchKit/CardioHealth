//
//  APHEditSectionsViewController.h
//  Parkinson
//
//  Created by Ramsundar Shandilya on 9/8/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import <UIKit/UIKit.h>
@import APCAppleCore;

static NSString * const kDashboardSectionsOrder = @"DashboardSectionsOrderKey";

typedef NS_ENUM(NSUInteger, APHDashboardSection) {
    kDashboardSectionStudyOverView = 0,
    kDashboardSectionActivity,
    kDashboardSectionBloodCount,
    kDashboardSectionMedications,
    kDashboardSectionInsights,
    kDashboardSectionAlerts
};

@interface APHEditSectionsViewController : UIViewController

@end
