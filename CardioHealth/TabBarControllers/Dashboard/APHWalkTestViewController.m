//
//  APHWalkTestViewController.m
//  CardioHealth
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHWalkTestViewController.h"
#import "APHWalkTestDetailsTableViewCell.h"

static NSInteger const numberOfRows = 3;

static CGFloat kHeaderFontSize = 16.0f;

@interface APHWalkTestViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation APHWalkTestViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self customizeNavigation];
    
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateFormat = @"MMMM d";
    
}

- (void)customizeNavigation
{
    
    UIButton *collapseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [collapseButton setImage:[[UIImage imageNamed:@"collapse_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    collapseButton.frame = CGRectMake(0, 0, 30, 30);
    [collapseButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    collapseButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    collapseButton.tintColor = self.tintColor;
    
    UIBarButtonItem *collapseItem = [[UIBarButtonItem alloc] initWithCustomView:collapseButton];
    self.navigationItem.rightBarButtonItem = collapseItem;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView
{
    return self.results.count;
}

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger) __unused section {
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APHWalkTestDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAPHWalkTestDetailsTableViewCellIdentifier];
    cell.tintColor = self.tintColor;
    
    APHTableViewDashboardWalkingTestItem *item = self.results[indexPath.section];
    
    switch (indexPath.row) {
        case kAPHWalkingTestRowTypeDistanceWalked:
        {
            cell.textLabel.text = NSLocalizedString(@"Distance Walked", @"");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld yd", (long)item.distanceWalked];
            cell.imageView.image = [[UIImage imageNamed:@"6min_distance_walked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
            break;
        case kAPHWalkingTestRowTypePeakHeartRate:
        {
            cell.textLabel.text = NSLocalizedString(@"Peak Heart Rate", @"");
            cell.detailTextLabel.text = (item.peakHeartRate != 0) ? [NSString stringWithFormat:@"%ld bpm", (long)item.peakHeartRate] : @"N/A";
            cell.imageView.image = [[UIImage imageNamed:@"6min_peak_heartrate"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
            break;
        case kAPHWalkingTestRowTypeFinalHeartRate:
        {
            cell.textLabel.text = NSLocalizedString(@"Final Heart Rate", @"");
            cell.detailTextLabel.text = (item.finalHeartRate != 0) ? [NSString stringWithFormat:@"%ld bpm", (long)item.finalHeartRate] : @"N/A";
            cell.imageView.image = [[UIImage imageNamed:@"6min_resting_heartrate"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
            break;
            
            
        default:
            break;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView;
    
    APHTableViewDashboardWalkingTestItem *item = self.results[section];
    
    headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), tableView.sectionHeaderHeight)];
    headerView.contentView.backgroundColor = [UIColor appSecondaryColor4];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    headerLabel.font = [UIFont appLightFontWithSize:kHeaderFontSize];
    headerLabel.textColor = [UIColor appSecondaryColor3];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = [self.dateFormatter stringFromDate:item.activityDate];
    [headerView addSubview:headerLabel];
    [headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    return headerView;
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
