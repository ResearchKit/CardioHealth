//
//  APHDashboardEditViewController.m
//  CardioHealth
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
                    item.caption = NSLocalizedString(@"Distance", @"");
                    
                    [self.items addObject:item];
                    
                }
                    break;
                case kAPHDashboardItemTypeHeartRate:{
                    
                    APCTableViewDashboardItem *item = [APCTableViewDashboardItem new];
                    item.caption = NSLocalizedString(@"Heart Rate", @"");
                    
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
                default:
                    break;
            }
        }
        
    }
}

@end
