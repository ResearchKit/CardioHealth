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

typedef NS_ENUM(NSUInteger, APHHeartAgeSummarySections)
{
    kHeartAgeSummarySectionTodaysActivites,
    kHeartAgeSummarySectionHeartAgeAndRiskFactors
};

typedef NS_ENUM(NSUInteger, APHHeartAgeAndRiskFactorRows)
{
    kHeartAgeAndRiskFactorsRowHeartAge,
    kHeartAgeAndRiskFactorsRowRiskFactors,
    kHeartAgeAndRiskFactorsRowRoomForImprovement
};

@interface APHHeartAgeSummaryViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation APHHeartAgeSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Survey Complete";
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTapped:)];
    

    APCStepProgressBar *progressBar = [[APCStepProgressBar alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 10)
                                                                          style:APCStepProgressBarStyleOnlyProgressView];
    progressBar.numberOfSteps = 4;
    [progressBar setCompletedSteps:4 animation:YES];
    [self.view addSubview:progressBar];
    
    [self.tableView registerClass:[APHHeartAgeVersusCell class] forCellReuseIdentifier:HeartAgeCell];
    [self.tableView registerClass:[APHHeartAgeTextCell class] forCellReuseIdentifier:RiskCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)doneButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView
#pragma mark Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? 1 : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:ActivityCell forIndexPath:indexPath];
            break;
        
        default:
            if (indexPath.row == 0) {
                APHHeartAgeVersusCell *cell = [tableView dequeueReusableCellWithIdentifier:HeartAgeCell forIndexPath:indexPath];
                cell.age = self.actualAge;
                cell.heartAge = self.heartAge;
                
            } else if (indexPath.row == 1) {
                APHHeartAgeTextCell *cell = [tableView dequeueReusableCellWithIdentifier:RiskCell forIndexPath:indexPath];
                cell.cellTitleText = NSLocalizedString(@"10 Year Risk Factor", @"10 year risk factor.");
                
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
                
                NSString *tenYearRiskPercentage = [numberFormatter stringFromNumber:self.tenYearRisk];
                NSString *tenYearRiskCaption = [NSString stringWithFormat:@"You have an estimated %@ 10-y risk and %lu%% lifetime risk of ASCVD.", tenYearRiskPercentage, [self.lifetimeRisk integerValue]];
                cell.cellDetailText = tenYearRiskCaption;
            } else {
                APHHeartAgeTextCell *cell = [tableView dequeueReusableCellWithIdentifier:RiskCell forIndexPath:indexPath];
                cell.cellTitleText = NSLocalizedString(@"Some Room for Improvement", @"Some Room for Improvement.");
                cell.cellDetailText = NSLocalizedString(@"Yeah, I like animals better than people sometimes... Especially dogs. Dogs are the best.", @"Replace this string with something more informative.");
            }
            break;
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
                    rowHeight = 220.0;
                    break;
                case 1:
                case 2:
                    rowHeight =  120.0;
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
    UILabel *sectionHeader = nil;
    
    if (section == 0) {
        sectionHeader = [[UILabel alloc] initWithFrame:CGRectMake(20, 0.0, 280.0, 42.0)];
        [sectionHeader setNumberOfLines:2];
        [sectionHeader setLineBreakMode:NSLineBreakByWordWrapping];
        [sectionHeader setText:@"Completing more activities increases the effectiveness of the study."];
        [sectionHeader setFont:[UIFont fontWithName:@"Helvetica Neue-Thin" size:15.0]];
    }
    
    return sectionHeader;
    
}

@end
