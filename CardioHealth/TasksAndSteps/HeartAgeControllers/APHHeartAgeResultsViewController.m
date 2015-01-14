// 
//  APHHeartAgeResultsViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHHeartAgeResultsViewController.h"
#import "APHHeartAgeTodaysActivitiesCell.h"
#import "APHHeartAgeSummaryCell.h"
#import "APHHeartAgeRiskEstimateCell.h"
#import "APHHeartAgeRecommendationCell.h"
#import "APHRiskEstimatorWebViewController.h"

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
    APHHeartAgeSummaryNumberOfRows
};

// Cell Identifiers
static NSString *kTodaysActivitiesCellIdentifier = @"TodaysActivitiesCell";
static NSString *kHeartAgeCellIdentifier         = @"HeartAgeCell";
static NSString *kRiskEstimateCellIdenfier       = @"RiskEstimateCell";
static NSString *kRecommendationsCellIdentifier  = @"RecommendationCell";
static NSString *kKludgeIdentifierForHeartAgeTaskB = @"APHHeartAgeB-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";

static CGFloat kSectionHeight = 64.0;

@interface APHHeartAgeResultsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)ASCVDRiskEstimatorActionButton:(id)sender;
@end

@implementation APHHeartAgeResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Task Identifier : %@", self.taskViewController.task.identifier);
    
    UIColor *viewBackgroundColor = [UIColor appSecondaryColor4];
    
    [self.view setBackgroundColor:viewBackgroundColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTapped:)];
    
    // This will trigger self-sizing rows in the tableview
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = NSLocalizedString(@"Activity Complete", @"Activity Complete");
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)doneButtonTapped:(UIBarButtonItem *)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKSTStepViewControllerNavigationDirectionForward];
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
    
    switch (section) {
        case APHHeartAgeSummarySectionHeartAge:
        {
            if ([self.taskViewController.task.identifier isEqualToString:kKludgeIdentifierForHeartAgeTaskB]) {
                rows = 0;
            }
        }
        case APHHeartAgeSummarySectionTodaysActivities:
            break;
        case APHHeartAgeSummarySectionTenYearRiskEstimate:
        {
            if (self.actualAge <= 40) {
                rows = 0;
            } else {
                rows = APHHeartAgeSummaryNumberOfRows;
            }
        }
            break;
        default:
            rows = APHHeartAgeSummaryNumberOfRows;
            break;
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
    
    NSUInteger allScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.countOfAllScheduledTasksForToday;
    NSUInteger completedScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.countOfCompletedScheduledTasksForToday;
    
    completedScheduledTasks = MIN(allScheduledTasks, completedScheduledTasks+1);
    CGFloat percent = (CGFloat) completedScheduledTasks / (CGFloat) allScheduledTasks;
    
    cell.activitiesCount = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)completedScheduledTasks, (unsigned long)allScheduledTasks];
    cell.activitiesProgress = [NSNumber numberWithFloat:percent];
    
    return cell;
}

- (APHHeartAgeSummaryCell *)configureHeartAgeEstimateCellAtIndexPath:(NSIndexPath *)indexPath
{
    APHHeartAgeSummaryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kHeartAgeCellIdentifier];
    
    cell.heartAgeTitle = NSLocalizedString(@"Your Heart Age Estimate", @"Your Heart Age Estimate");
    cell.actualAgeLabel = NSLocalizedString(@"Actual Age", @"Actual Age");
    cell.heartAgeLabel = NSLocalizedString(@"Heart Age", @"Heart Age");
    
    cell.actualAgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)self.actualAge];
    cell.heartAgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)self.heartAge];
    
    return cell;
}

- (APHHeartAgeRiskEstimateCell *)configureRiskEstimateCellAtIndexPath:(NSIndexPath *)indexPath
{
    APHHeartAgeRiskEstimateCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kRiskEstimateCellIdenfier];
    
    cell.calculatedRiskLabel = NSLocalizedString(@"Calculated Risk", @"Calculated risk");
    cell.optimalFactorRiskLabel = NSLocalizedString(@"with Optimal Risk Factors", @"with Optimak Risk Factors");
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [numberFormatter setMaximumFractionDigits:0];
    
    NSString *calculatedRisk = nil;
    NSString *optimalRisk = nil;
    static double kOnePercent = 0.01;
    
    if (indexPath.section == APHHeartAgeSummarySectionTenYearRiskEstimate) {
        cell.riskEstimateTitle = NSLocalizedString(@"10 Year Risk Estimate", @"10 year risk estimate");
        
        
        if ([self.tenYearRisk doubleValue] < kOnePercent) {
            calculatedRisk = @"< 1%";
        } else {
            calculatedRisk = [numberFormatter stringFromNumber:self.tenYearRisk];
        }
        
        if ([self.optimalTenYearRisk doubleValue] < kOnePercent) {
            optimalRisk = @"< 1%";
        } else {
            optimalRisk = [numberFormatter stringFromNumber:self.optimalTenYearRisk];
        }
    } else {
        cell.riskEstimateTitle = NSLocalizedString(@"Lifetime Risk Estimate", @"Lifetime risk estimate");
        calculatedRisk = [NSString stringWithFormat:@"%lu%%", (long)[self.lifetimeRisk integerValue]];
        optimalRisk = [NSString stringWithFormat:@"%lu%%", (long)[self.optimalLifetimeRisk integerValue]];
    }
    
    cell.calculatedRiskValue = calculatedRisk;
    cell.optimalFactorRiskValue = optimalRisk;
    
    return cell;
}

- (APHHeartAgeRecommendationCell *)configureRecommendationCellAtIndexPath:(NSIndexPath *)indexPath
{
    APHHeartAgeRecommendationCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kRecommendationsCellIdentifier];
    
   cell.recommendationTitle = NSLocalizedString(@"What does my risk score mean?", @"What does my risk score mean?");
    
    if (indexPath.section == APHHeartAgeSummarySectionTenYearRiskEstimate) {
        cell.recommendationContent = NSLocalizedString(@"In general, a 10-year risk >7.5% is considered high and warrants discussion with your doctor. There may be other medical or family history that can increase your risk and these should be discussed with your doctor.", @"Placeholder copy");
        
        cell.ASCVDLinkButton.alpha = 0;
        
    } else {
 
        cell.recommendationContent = NSLocalizedString(@"For official recommendations, please refer to the guide from the American College of Cardiology -", @"Placeholder copy");
        
        
    }
    
    return cell;
}

- (IBAction)ASCVDRiskEstimatorActionButton:(id)sender {
    
    APHRiskEstimatorWebViewController *viewController = [[APHRiskEstimatorWebViewController alloc] init];
    

    [self presentViewController:viewController animated:YES completion:nil];
    
}
@end
