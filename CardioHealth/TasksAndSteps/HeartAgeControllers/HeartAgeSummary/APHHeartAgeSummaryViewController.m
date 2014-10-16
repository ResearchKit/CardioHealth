//
//  APHHeartAgeSummaryViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHHeartAgeSummaryViewController.h"
#import "APHHeartAgeVersusCell.h"
#import "APHHeartAgeTextCell.h"

static NSString *ActivityCell = @"ActivityProgressCell";
static NSString *HeartAgeCell = @"HeartAgeCell";
static NSString *InformationCell = @"InformationCell";

static CGFloat kVersusCellHeight = 220.0;
static CGFloat kInfomationCellHeight = 110.0;
static CGFloat kProgressBarHeight = 10.0;
static CGFloat kHeaderHeightForFirstSection = 42.0;

typedef NS_ENUM(NSUInteger, APHHeartAgeSummarySections)
{
    kHeartAgeSummarySectionTodaysActivites,
    kHeartAgeSummarySectionHeartAgeAndRiskFactors
};

typedef NS_ENUM(NSUInteger, APHHeartAgeAndRiskFactorRows)
{
    kHeartAgeAndRiskFactorsRowHeartAge,
    kHeartAgeAndRiskFactorsRowTenYearRiskFactor,
    kHeartAgeAndRiskFactorsRowLifetimeRiskFactor
};

@interface APHHeartAgeSummaryViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation APHHeartAgeSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Survey Complete", @"Survey Complete");
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTapped:)];
    

    APCStepProgressBar *progressBar = [[APCStepProgressBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kProgressBarHeight)
                                                                          style:APCStepProgressBarStyleOnlyProgressView];
    progressBar.numberOfSteps = 4;
    [progressBar setCompletedSteps:4 animation:YES];
    
    [self.view addSubview:progressBar];
    
    [self.tableView registerClass:[APHHeartAgeVersusCell class] forCellReuseIdentifier:HeartAgeCell];
    [self.tableView registerClass:[APHHeartAgeTextCell class] forCellReuseIdentifier:InformationCell];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == kHeartAgeSummarySectionTodaysActivites) ? 1 : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case kHeartAgeSummarySectionTodaysActivites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:ActivityCell forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Today's Activities", @"Today's activities");
            cell.detailTextLabel.text = NSLocalizedString(@"1/3", @"One of three");
            
            APCCircularProgressView *circularProgress = [[APCCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
            circularProgress.hidesProgressValue = YES;
            [circularProgress setProgress:0.33];
            
            cell.accessoryView = circularProgress;
        }
            break;
        
        default:
        {
            if (indexPath.row == kHeartAgeAndRiskFactorsRowHeartAge) {
                APHHeartAgeVersusCell *versusCell;
                
                versusCell = (APHHeartAgeVersusCell *)[tableView dequeueReusableCellWithIdentifier:HeartAgeCell forIndexPath:indexPath];
                versusCell.age = self.actualAge;
                versusCell.heartAge = self.heartAge;
                cell = versusCell;
            } else if (indexPath.row == kHeartAgeAndRiskFactorsRowTenYearRiskFactor) {
                APHHeartAgeTextCell *tenYearRiskCell;
                tenYearRiskCell = (APHHeartAgeTextCell *)[tableView dequeueReusableCellWithIdentifier:InformationCell forIndexPath:indexPath];
                tenYearRiskCell.cellTitleText = NSLocalizedString(@"10 Year Risk Factor", @"10 year risk factor.");
                
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
                
                NSString *tenYearRiskPercentage = [numberFormatter stringFromNumber:self.tenYearRisk];
                NSString *tenYearRiskCaption = [NSString stringWithFormat:@"You have an estimated %@ 10-year risk of ASCVD.", tenYearRiskPercentage];
                tenYearRiskCell.cellDetailText = tenYearRiskCaption;
                cell = tenYearRiskCell;
            } else {
                APHHeartAgeTextCell *lifetimeRiskCell;
                
                lifetimeRiskCell = (APHHeartAgeTextCell *)[tableView dequeueReusableCellWithIdentifier:InformationCell forIndexPath:indexPath];
                lifetimeRiskCell.cellTitleText = NSLocalizedString(@"Lifetime Risk Factor", @"Lifetime Risk Factor");
                lifetimeRiskCell.cellDetailText = [NSString stringWithFormat:@"You have an estimated %lu%% lifetime risk of ASCVD.", [self.lifetimeRisk integerValue]];
                cell = lifetimeRiskCell;
            }
        }
    }
    
    return cell;
}

#pragma mark Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     CGFloat rowHeight;
    
    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case 0:
                    rowHeight = kVersusCellHeight;
                    break;
                case 1:
                case 2:
                    rowHeight =  kInfomationCellHeight;
                    break;
                default:
                    rowHeight = self.tableView.rowHeight;
                    break;
            }
            break;
            
        default:
            rowHeight = self.tableView.rowHeight;
            break;
    }
    
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 64.0 : self.tableView.sectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = nil;
    
    if (section == 0) {
        sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kHeaderHeightForFirstSection)];
        
        UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kHeaderHeightForFirstSection)];
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

@end
