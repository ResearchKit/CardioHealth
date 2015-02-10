//
//  APHWalkTestViewController.m
//  CardioHealth
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHWalkTestViewController.h"
#import "APHWalkTestDetailsTableViewCell.h"

static NSInteger const numberOfRows = 3;

@interface APHWalkTestViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation APHWalkTestViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self customizeNavigation];
    
    [self prepareData];
    
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

- (void)prepareData
{
    
#warning Placeholders. Repalce with real walking data form the tasks
    
    NSMutableArray *array = [NSMutableArray new];
    
    {
        APHTableViewDashboardWalkingTestItem *item = [APHTableViewDashboardWalkingTestItem new];
        item.distanceWalked = 1920;
        item.peakHeartRate = 109;
        item.finalHeartRate = 88;
        item.activityDate = [NSDate date];
        [array addObject:item];
    }
    
    {
        APHTableViewDashboardWalkingTestItem *item = [APHTableViewDashboardWalkingTestItem new];
        item.distanceWalked = 1920;
        item.peakHeartRate = 109;
        item.finalHeartRate = 88;
        item.activityDate = [NSDate date];
        [array addObject:item];
    }
    
    {
        APHTableViewDashboardWalkingTestItem *item = [APHTableViewDashboardWalkingTestItem new];
        item.distanceWalked = 1920;
        item.peakHeartRate = 109;
        item.finalHeartRate = 88;
        item.activityDate = [NSDate date];
        [array addObject:item];
    }
    
    self.items = [NSArray arrayWithArray:array];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning replace with number of dates to be displayed
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APHWalkTestDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAPHWalkTestDetailsTableViewCellIdentifier];
    cell.tintColor = self.tintColor;
    
    APHTableViewDashboardWalkingTestItem *item = self.items[indexPath.section];
    
    switch (indexPath.row) {
        case kAPHWalkingTestRowTypeDistanceWalked:
        {
            cell.textLabel.text = NSLocalizedString(@"Distance Walked", @"");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld ft", (long)item.distanceWalked];
        }
            break;
        case kAPHWalkingTestRowTypePeakHeartRate:
        {
            cell.textLabel.text = NSLocalizedString(@"Peak Heart Rate", @"");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld ft", (long)item.peakHeartRate];
        }
            break;
        case kAPHWalkingTestRowTypeFinalHeartRate:
        {
            cell.textLabel.text = NSLocalizedString(@"Final Hear Rate", @"");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld ft", (long)item.finalHeartRate];
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
    
    APHTableViewDashboardWalkingTestItem *item = self.items[section];
    
    headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), tableView.sectionHeaderHeight)];
    headerView.contentView.backgroundColor = [UIColor appSecondaryColor4];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    headerLabel.font = [UIFont appLightFontWithSize:16.0f];
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
