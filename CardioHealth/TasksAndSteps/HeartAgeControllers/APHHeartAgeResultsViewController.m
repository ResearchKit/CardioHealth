//
//  APHHeartAgeResultsViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeResultsViewController.h"
#import "APHHeartAgeTodaysActivitiesCell.h"
#import "APHHeartAgeSummaryCell.h"
#import "APHHeartAgeRiskEstimateCell.h"
#import "APHHeartAgeRecommendationCell.h"

typedef NS_ENUM(NSUInteger, APHHeartAgeSummarySections)
{
    APHHeartAgeSummarySectionTodaysActivities = 0,
    APHHeartAgeSummarySectionHeartAge,
    APHHeartAgeSummarySectionTenYearRiskEstimate,
    APHHeartAgeSummarySectionLifetimeRiskEstimate,
    APHHeartAgeSummaryNumberOfSections
};

typedef NS_ENUM(NSUInteger, APHHeartAgeSummaryRows)
{
    APHHeartAgeSummaryRowBanner = 0,
    APHHeartAgeSummaryRowRecommendation,
    APHHeartAgeSummartNumberOfRows
};

// Cell Identifiers
static NSString *kTodaysActivitiesCellIdentifier = @"TodaysActivitiesCell";
static NSString *kHeartAgeCellIdentifier         = @"HeartAgeCell";
static NSString *kRiskEstimateCellIdenfier       = @"RiskEstimateCell";
static NSString *kRecommendationsCellIdentifier  = @"RecommendationCell";

static CGFloat kSectionHeight = 64.0;

@interface APHHeartAgeResultsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation APHHeartAgeResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *viewBackgroundColor = [UIColor appSecondaryColor4];
    
    [self.view setBackgroundColor:viewBackgroundColor];
    
    self.navigationItem.title = NSLocalizedString(@"Survey Complete", @"Survey Complete");
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTapped:)];
    
    // This will trigger self-sizing rows in the tableview
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)doneButtonTapped:(UIBarButtonItem *)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKStepViewControllerNavigationDirectionForward];
        }
    }
}

#pragma mark - TableView
#pragma mark Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return APHHeartAgeSummaryNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rows = 1;
    
    if (section != APHHeartAgeSummarySectionTodaysActivities) {
        rows = APHHeartAgeSummartNumberOfRows;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case APHHeartAgeSummarySectionTodaysActivities:
        {
            cell = [self configureTodaysActivitiesCellAtIndexPath:indexPath];
        }
        break;
        
        case APHHeartAgeSummarySectionHeartAge:
        {
            if (indexPath.row == APHHeartAgeSummaryRowBanner) {
                cell = [self configureHeartAgeEstimateCellAtIndexPath:indexPath];
            } else {
                cell = [self configureRecommendationCellAtIndexPath:indexPath];
            }
        }
        break;
        
        case APHHeartAgeSummarySectionTenYearRiskEstimate:
        case APHHeartAgeSummarySectionLifetimeRiskEstimate:
        {
            if (indexPath.row == APHHeartAgeSummaryRowBanner) {
                cell = [self configureRiskEstimateCellAtIndexPath:indexPath];
            } else {
                cell = [self configureRecommendationCellAtIndexPath:indexPath];
            }
            
        }
        break;
        
        default:
            NSAssert(YES, @"Extra section encountered.");
        break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerHeight;
    
    if (section == APHHeartAgeSummarySectionTodaysActivities) {
        headerHeight = kSectionHeight;
    } else {
        headerHeight = tableView.sectionHeaderHeight;
    }
    
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = nil;
    
    if (section == APHHeartAgeSummarySectionTodaysActivities) {
        sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionHeaderHeight)];
        
        UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionHeaderHeight)];
        [sectionLabel setNumberOfLines:2];
        [sectionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [sectionLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [sectionLabel setFont:[UIFont systemFontOfSize:15.0]];
        [sectionLabel setTextColor:[UIColor grayColor]];
        [sectionLabel setText:NSLocalizedString(@"Completing more activities increases the effectiveness of the study.",
                                                @"Completing more activities increases the effectiveness of the study.")];
        
        [sectionHeaderView addSubview:sectionLabel];
        
        // Top constraint
        [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:sectionLabel
                                                                      attribute:NSLayoutAttributeTopMargin
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:sectionHeaderView
                                                                      attribute:NSLayoutAttributeTopMargin
                                                                     multiplier:1.0
                                                                       constant:15.0]];
        
        // Leading/Trailing constraints
        [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:sectionLabel
                                                                      attribute:NSLayoutAttributeLeadingMargin
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:sectionHeaderView
                                                                      attribute:NSLayoutAttributeLeadingMargin
                                                                     multiplier:1.0
                                                                       constant:20.0]];
        
        [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:sectionHeaderView
                                                                      attribute:NSLayoutAttributeTrailingMargin
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:sectionLabel
                                                                      attribute:NSLayoutAttributeTrailingMargin
                                                                     multiplier:1.0
                                                                       constant:20.0]];
    }
    
    return sectionHeaderView;
}

#pragma mark Cell Configurations

- (APHHeartAgeTodaysActivitiesCell *)configureTodaysActivitiesCellAtIndexPath:(NSIndexPath *)indexPath
{
    APHHeartAgeTodaysActivitiesCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kTodaysActivitiesCellIdentifier];
    
    cell.caption = NSLocalizedString(@"Today's Activities", @"Today's Activities");
    
    NSUInteger allScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.allScheduledTasksForToday;
    NSUInteger completedScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.completedScheduledTasksForToday;
    
    completedScheduledTasks = MIN(allScheduledTasks, completedScheduledTasks+1);
    CGFloat percent = (CGFloat) completedScheduledTasks / (CGFloat) allScheduledTasks;
    
    cell.activitiesCount = [NSString stringWithFormat:@"%lu/%lu", completedScheduledTasks, allScheduledTasks];
    cell.activitiesProgress = [NSNumber numberWithFloat:percent];
    
    return cell;
}

- (APHHeartAgeSummaryCell *)configureHeartAgeEstimateCellAtIndexPath:(NSIndexPath *)indexPath
{
    APHHeartAgeSummaryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kHeartAgeCellIdentifier];
    
    cell.heartAgeTitle = NSLocalizedString(@"Your Heart Age Estimate", @"Your Heart Age Estimate");
    cell.actualAgeLabel = NSLocalizedString(@"Actual Age", @"Actual Age");
    cell.heartAgeLabel = NSLocalizedString(@"Heart Age", @"Heart Age");
    
    cell.actualAgeValue = [NSString stringWithFormat:@"%lu", self.actualAge];
    cell.heartAgeValue = [NSString stringWithFormat:@"%lu", self.heartAge];
    
    return cell;
}

- (APHHeartAgeRiskEstimateCell *)configureRiskEstimateCellAtIndexPath:(NSIndexPath *)indexPath
{
    APHHeartAgeRiskEstimateCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kRiskEstimateCellIdenfier];
    
    cell.calculatedRiskLabel = NSLocalizedString(@"Calculated Risk", @"Calculated risk");
    cell.optimalFactorRiskLabel = NSLocalizedString(@"with Optimal Risk Factors", @"with Optimak Risk Factors");
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [numberFormatter setMaximumFractionDigits:2];
    
    NSString *calculatedRisk = nil;
    NSString *optimalRisk = nil;
    
    if (indexPath.section == APHHeartAgeSummarySectionTenYearRiskEstimate) {
        cell.riskEstimateTitle = NSLocalizedString(@"10 Year Risk Estimate", @"10 year risk estimate");
        calculatedRisk = [numberFormatter stringFromNumber:self.tenYearRisk];
        optimalRisk = [numberFormatter stringFromNumber:self.optimalTenYearRisk];
    } else {
        cell.riskEstimateTitle = NSLocalizedString(@"Lifetime Risk Estimate", @"Lifetime risk estimate");
        calculatedRisk = [NSString stringWithFormat:@"%lu%%", [self.lifetimeRisk integerValue]];
        optimalRisk = [NSString stringWithFormat:@"%lu%%", [self.lifetimeRisk integerValue]];
    }
    
    cell.calculatedRiskValue = calculatedRisk;
    cell.optimalFactorRiskValue = optimalRisk;
    
    return cell;
}

- (APHHeartAgeRecommendationCell *)configureRecommendationCellAtIndexPath:(NSIndexPath *)indexPath
{
    APHHeartAgeRecommendationCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kRecommendationsCellIdentifier];
    
    if (indexPath.section == APHHeartAgeSummarySectionHeartAge) {
        cell.recommendationTitle = NSLocalizedString(@"Time to Make a Change", @"Time to make a change");
        cell.recommendationContent = NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", @"Placeholder copy");
    } else {
        cell.recommendationTitle = NSLocalizedString(@"Recommendations", @"Recommendations");
        cell.recommendationContent = NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", @"Placeholder copy");
    }
    
    return cell;
}

@end
