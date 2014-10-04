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
static NSString *RiskCell = @"RiskCell";
static NSString *RoomForImprovementCell = @"RoomForImprovementCell";

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
    switch (section) {
        case 0:
            return 1;
            break;
            
        default:
            return 3;
            break;
    }
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
                APHHeartAgeVersusCell *versusCell = [tableView dequeueReusableCellWithIdentifier:HeartAgeCell forIndexPath:indexPath];
                versusCell.age = self.actualAge;
                versusCell.heartAge = self.heartAge;
                
                return versusCell;
            } else if (indexPath.row == 1) {
                APHHeartAgeTextCell *tenYearRiskCell = [tableView dequeueReusableCellWithIdentifier:RiskCell forIndexPath:indexPath];
                tenYearRiskCell.cellTitleText = NSLocalizedString(@"10 Year Risk Factor", @"10 year risk factor.");
                
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
                
                NSString *tenYearRiskPercentage = [numberFormatter stringFromNumber:self.tenYearRisk];
                NSString *tenYearRiskCaption = [NSString stringWithFormat:@"You have an estimated %@ 10-y risk of ASCVD. You have an estimated XX 10-y risk of ASCVD.", tenYearRiskPercentage];
                tenYearRiskCell.cellDetailText = tenYearRiskCaption;
                
                return tenYearRiskCell;
            } else {
                APHHeartAgeTextCell *roomForImprovementCell = [tableView dequeueReusableCellWithIdentifier:RiskCell forIndexPath:indexPath];
                roomForImprovementCell.cellTitleText = NSLocalizedString(@"Some Room for Improvement", @"Some Room for Improvement.");
                roomForImprovementCell.cellDetailText = [NSString stringWithFormat:@"Your lifetime risk of ASCVD is %lu%%. Your lifetime risk of ASCVD, Your lifetime risk of ASCVD.", [self.lifetimeRisk integerValue]];
                
                return roomForImprovementCell;
            }
            break;
    }
    
    return cell;
}

#pragma mark Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case 0:
                    return 220.0;
                    break;
                case 1:
                case 2:
                    return 120.0;
                    break;
                default:
                    return self.tableView.rowHeight;
                    break;
            }
            break;
            
        default:
            return self.tableView.rowHeight;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 64.0;
    } else {
        return self.tableView.sectionHeaderHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UILabel *sectionHeader = [[UILabel alloc] initWithFrame:CGRectMake(20, 0.0, 280.0, 42.0)];
        [sectionHeader setNumberOfLines:2];
        [sectionHeader setLineBreakMode:NSLineBreakByWordWrapping];
        [sectionHeader setText:@"Completing more activities increases the effectiveness of the study."];
        [sectionHeader setFont:[UIFont fontWithName:@"Helvetica Neue-Thin" size:15.0]];
        
        return sectionHeader;
    } else {
        return nil;
    }
    
}

@end
