//
//  APHOverviewViewController.m
//  BasicTabBar
//
//  Created by Henry McGilton on 9/7/14.
//  Copyright (c) 2014 Trilithon Software. All rights reserved.
//

/* Controllers */
#import "APHDashboardViewController.h"
#import "APHEditSectionsViewController.h"

/* Views */
#import "APHDashboardGraphViewCell.h"
#import "APHDashboardMessageViewCell.h"
#import "APHDashboardProgressViewCell.h"

/* Scoring */
#import "APHScoring.h"

static NSString * const kDashboardRightDetailCellIdentifier = @"DashboardRightDetailCellIdentifier";
static NSString * const kDashboardGraphCellIdentifier       = @"DashboardGraphCellIdentifier";
static NSString * const kDashboardProgressCellIdentifier    = @"DashboardProgressCellIdentifier";
static NSString * const kDashboardMessagesCellIdentifier    = @"DashboardMessageCellIdentifier";

@interface APHDashboardViewController () <APCLineGraphViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *sectionsOrder;

@property (nonatomic, strong) NSMutableArray *lineCharts;

@property (nonatomic, strong) APHScoring *distanceScore;
@property (nonatomic, strong) APHScoring *heartRateScore;

@end

@implementation APHDashboardViewController

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _sectionsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kDashboardSectionsOrder]];
        
        if (!_sectionsOrder.count) {
            _sectionsOrder = [[NSMutableArray alloc] initWithArray:@[
                                                                     @(kDashboardSectionActivity),
                                                                     @(kDashboardSectionBloodCount),
                                                                     @(kDashboardSectionInsights),
                                                                     @(kDashboardSectionAlerts)]];
            
            [defaults setObject:[NSArray arrayWithArray:_sectionsOrder] forKey:kDashboardSectionsOrder];
            [defaults synchronize];
            
        }
        
        self.title = NSLocalizedString(@"Dashboard", @"Dashboard");
        _lineCharts = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(editTapped)];
    [self.navigationItem setRightBarButtonItem:editButton];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.distanceScore = [[APHScoring alloc] initWithKind:APHDataKindWalk
                                             numberOfDays:5
                                        correlateWithKind:APHDataKindNone];
    
    self.heartRateScore = [[APHScoring alloc] initWithKind:APHDataKindHeartRate
                                              numberOfDays:5
                                         correlateWithKind:APHDataKindNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.sectionsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kDashboardSectionsOrder]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![gestureRecognizer isEqual:self.tableView.panGestureRecognizer] && ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture velocityInView:self.tableView];
        return fabs(translation.x) > fabs(translation.y);
    }
    return YES;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount;
    
    if (section == 0) {
        rowCount = 2;
    } else{
        rowCount = self.sectionsOrder.count;
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:kDashboardRightDetailCellIdentifier];
            
            cell.textLabel.text = NSLocalizedString(@"Activities", nil);
            cell.textLabel.textColor = [UIColor appSecondaryColor1];
            cell.textLabel.font = [UIFont appRegularFontWithSize:14.0f];
            
            cell.detailTextLabel.text = @"5/6";
            cell.detailTextLabel.textColor = [UIColor appSecondaryColor3];
            cell.detailTextLabel.font = [UIFont appRegularFontWithSize:17.0f];
            
        } else if (indexPath.row == 1){
            cell = [tableView dequeueReusableCellWithIdentifier:kDashboardProgressCellIdentifier];
        }
    } else {
        NSInteger cellType = ((NSNumber *)[self.sectionsOrder objectAtIndex:indexPath.row]).integerValue;
        
        switch (cellType) {
            case kDashboardSectionActivity:
            {
                cell = (APHDashboardGraphViewCell *)[tableView dequeueReusableCellWithIdentifier:kDashboardGraphCellIdentifier forIndexPath:indexPath];
                APHDashboardGraphViewCell * graphCell = (APHDashboardGraphViewCell *) cell;
                if (graphCell.graphContainerView.subviews.count == 0) {
                    APCLineGraphView *lineGraphView = [[APCLineGraphView alloc] initWithFrame:graphCell.graphContainerView.frame];
                    lineGraphView.datasource = self.distanceScore;
                    lineGraphView.delegate = self;
                    lineGraphView.titleLabel.text = NSLocalizedString(@"Distance", @"Distance");
                    lineGraphView.subTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Average : %lu ft",
                                                                                                    @"Average: {value} ft"), [[self.distanceScore averageDataPoint] integerValue]];
                    lineGraphView.tintColor = [UIColor appPrimaryColor];
                    [graphCell.graphContainerView addSubview:lineGraphView];
                    lineGraphView.panGestureRecognizer.delegate = self;
                    [self.lineCharts addObject:lineGraphView];
                }
            }
                break;
            case kDashboardSectionBloodCount:
            {
                cell = (APHDashboardGraphViewCell *)[tableView dequeueReusableCellWithIdentifier:kDashboardGraphCellIdentifier forIndexPath:indexPath];
                APHDashboardGraphViewCell * graphCell = (APHDashboardGraphViewCell *) cell;
                if (graphCell.graphContainerView.subviews.count == 0) {
                    APCLineGraphView *lineGraphView = [[APCLineGraphView alloc] initWithFrame:graphCell.graphContainerView.frame];
                    lineGraphView.datasource = self.heartRateScore;
                    lineGraphView.delegate = self;
                    lineGraphView.titleLabel.text = NSLocalizedString(@"Heart Rate", @"Heart Rate");
                    lineGraphView.subTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Average : %lu bpm",
                                                                                                    @"Average: {value} bpm"), [[self.heartRateScore averageDataPoint] integerValue]];
                    [graphCell.graphContainerView addSubview:lineGraphView];
                    lineGraphView.tintColor = [UIColor appPrimaryColor];
                    lineGraphView.panGestureRecognizer.delegate = self;
                    [self.lineCharts addObject:lineGraphView];
                }
                
            }
                break;
            case kDashboardSectionInsights:
            {
                cell = (APHDashboardMessageViewCell *)[tableView dequeueReusableCellWithIdentifier:kDashboardMessagesCellIdentifier forIndexPath:indexPath];
                ((APHDashboardMessageViewCell *)cell).type = kDashboardMessageViewCellTypeInsight;
                
            }
                break;
            case kDashboardSectionAlerts:
            {
                cell = (APHDashboardMessageViewCell *)[tableView dequeueReusableCellWithIdentifier:kDashboardMessagesCellIdentifier forIndexPath:indexPath];
                ((APHDashboardMessageViewCell *)cell).type = kDashboardMessageViewCellTypeAlert;
            }
                break;
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            height = 65.0f;
        } else {
            height = 163.0f;
        }
    } else{
        APHDashboardSection cellType = ((NSNumber *)[self.sectionsOrder objectAtIndex:indexPath.row]).integerValue;
        
        switch (cellType) {
            case kDashboardSectionBloodCount:
            case kDashboardSectionActivity:
            case kDashboardSectionMedications:
                height = 204.0f;
                break;
            default:
                height = 150;
                break;
        }
    }
    
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), tableView.sectionHeaderHeight)];
    headerView.contentView.backgroundColor = [UIColor appSecondaryColor4];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    headerLabel.font = [UIFont appLightFontWithSize:16.0f];
    headerLabel.textColor = [UIColor appSecondaryColor3];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:headerLabel];
    
    if (section == 0) {
        headerLabel.text = @"Today";
    } else{
        headerLabel.text = @"Past 5 Days";
    }
    
    return headerView;
}

#pragma mark - Selection Actions

- (void)editTapped
{
    APHEditSectionsViewController *editSectionsViewController = [[APHEditSectionsViewController alloc] initWithNibName:@"APHEditSectionsViewController" bundle:nil];
    
    UINavigationController *editSectionsNavigationController = [[UINavigationController alloc] initWithRootViewController:editSectionsViewController];
    editSectionsNavigationController.navigationBar.translucent = NO;
    
    [self presentViewController:editSectionsNavigationController animated:YES completion:nil];
}

#pragma mark - APCLineGraphViewDelegate methods

- (void)lineGraphTouchesBegan:(APCLineGraphView *)graphView
{
    for (APCLineGraphView *lineGraph in self.lineCharts) {
        if (lineGraph != graphView) {
            [lineGraph setScrubberViewsHidden:NO animated:YES];
        }
    }
}

- (void)lineGraph:(APCLineGraphView *)graphView touchesMovedToXPosition:(CGFloat)xPosition
{
    for (APCLineGraphView *lineGraph in self.lineCharts) {
        if (lineGraph != graphView) {
            [lineGraph scrubReferenceLineForXPosition:xPosition];
        }
    }
}

- (void)lineGraphTouchesEnded:(APCLineGraphView *)graphView
{
    for (APCLineGraphView *lineGraph in self.lineCharts) {
        if (lineGraph != graphView) {
            [lineGraph setScrubberViewsHidden:YES animated:YES];
        }
    }
}

@end
