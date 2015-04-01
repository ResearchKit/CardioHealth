// 
//  APHWalkTestViewController.m 
//  MyHeart Counts 
// 
// Copyright (c) 2015, Stanford Medical. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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
