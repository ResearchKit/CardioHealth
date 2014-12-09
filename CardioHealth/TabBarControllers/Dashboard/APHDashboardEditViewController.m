// 
//  APHDashboardEditViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHDashboardEditViewController.h"

@implementation APHDashboardEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareData];
}

- (void)prepareData
{
    [self.items removeAllObjects];
    
    {
        for (NSNumber *typeNumber in self.rowItemsOrder) {
            
            APHDashboardItemType rowType = typeNumber.integerValue;
            
            switch (rowType) {
                case kAPHDashboardItemTypeDistance:
                {
                    APCTableViewDashboardItem *item = [APCTableViewDashboardItem new];
                    item.caption = NSLocalizedString(@"Steps", @"");
                    item.tintColor = [UIColor appTertiaryPurpleColor];
                    
                    [self.items addObject:item];
                    
                }
                    break;
                case kAPHDashboardItemTypeHeartRate:{
                    
                    APCTableViewDashboardItem *item = [APCTableViewDashboardItem new];
                    item.caption = NSLocalizedString(@"Heart Rate", @"");
                    item.tintColor = [UIColor appTertiaryYellowColor];
                    
                    [self.items addObject:item];
                }
                    break;
                case kAPHDashboardItemTypeAlerts:{
                    
                    APCTableViewDashboardItem *item = [APCTableViewDashboardItem new];
                    item.caption = NSLocalizedString(@"Alerts", @"");
                    
                    [self.items addObject:item];
                }
                    break;
                case kAPHDashboardItemTypeInsights:{
                    
                    APCTableViewDashboardItem *item = [APCTableViewDashboardItem new];
                    item.caption = NSLocalizedString(@"Insights", @"");
                    
                    [self.items addObject:item];
                }
                    break;
                
                case kAPHDashboardItemTypeSevenDayFitness:
                {
                    
                    APCTableViewDashboardItem *item = [APCTableViewDashboardItem new];
                    item.caption = NSLocalizedString(@"Seven Day Fitness", @"");
                    item.tintColor = [UIColor appTertiaryGreenColor];
                    [self.items addObject:item];
                }
                    break;
                default:
                    break;
            }
        }
        
    }
}

@end
