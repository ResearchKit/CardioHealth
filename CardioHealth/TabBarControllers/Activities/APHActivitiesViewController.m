//
//  APHActivitiesViewController.m

//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

/* ViewControllers */
#import "APHActivitiesViewController.h"

/* Other Classes */
#import "APHAppDelegate.h"

@implementation APHActivitiesViewController

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView*) [super tableView:tableView viewForHeaderInSection:section];
    [headerView.contentView setBackgroundColor:[UIColor appSecondaryColor3]];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCActivitiesTableViewCell * cell = (APCActivitiesTableViewCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

@end