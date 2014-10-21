//
//  APHOverviewViewController.m
//  BasicTabBar
//
//  Created by Henry McGilton on 9/7/14.
//  Copyright (c) 2014 Trilithon Software. All rights reserved.
//

@import APCAppleCore;
/* Controllers */
#import "APHDashboardViewController.h"
#import "APHEditSectionsViewController.h"

/* Views */
#import "APHDashboardGraphViewCell.h"
#import "APHDashboardMessageViewCell.h"
#import "APHDashboardProgressViewCell.h"

static NSString * const kDashboardGraphCellIdentifier    = @"DashboardGraphCellIdentifier";
static NSString * const kDashboardProgressCellIdentifier = @"DashboardProgressCellIdentifier";
static NSString * const kDashboardMessagesCellIdentifier = @"DashboardMessageCellIdentifier";

@interface APHDashboardViewController () <YMLTimeLineChartViewDataSource>

@property (nonatomic, strong) NSMutableArray *sectionsOrder;

@end

@implementation APHDashboardViewController

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _sectionsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kDashboardSectionsOrder]];
        
        if (!_sectionsOrder.count) {
            _sectionsOrder = [[NSMutableArray alloc] initWithArray:@[@(kDashboardSectionStudyOverView),
                                                                     @(kDashboardSectionActivity),
//                                                                     @(kDashboardSectionBloodCount),
                                                                     @(kDashboardSectionMedications),
                                                                     @(kDashboardSectionInsights),
                                                                     @(kDashboardSectionAlerts)]];
            
            [defaults setObject:[NSArray arrayWithArray:_sectionsOrder] forKey:kDashboardSectionsOrder];
            [defaults synchronize];
        }
        
        self.title = NSLocalizedString(@"Dashboard", @"Dashboard");
    }
    
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(editTapped)];
    [self.navigationItem setLeftBarButtonItem:editButton];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeNone;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionsOrder.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellType = ((NSNumber *)[self.sectionsOrder objectAtIndex:indexPath.section]).integerValue;
    
    UITableViewCell *cell = nil;
    
    switch (cellType) {
        case kDashboardSectionStudyOverView:
        {
            cell = (APHDashboardProgressViewCell *)[tableView dequeueReusableCellWithIdentifier:kDashboardProgressCellIdentifier forIndexPath:indexPath];
            
        }
            break;
        case kDashboardSectionActivity:
        {
            cell = (APHDashboardGraphViewCell *)[tableView dequeueReusableCellWithIdentifier:kDashboardGraphCellIdentifier forIndexPath:indexPath];
            APHDashboardGraphViewCell * graphCell = (APHDashboardGraphViewCell *) cell;
            graphCell.titleLabel.text = NSLocalizedString(@"Activity", @"Activity");
            if (graphCell.graphView.subviews.count == 0) {
                YMLLineChartView * lineChartView = [[YMLLineChartView alloc] initWithFrame:CGRectMake(0, 0, graphCell.graphView.frame.size.width, graphCell.graphView.frame.size.height)];
                lineChartView.layer.borderColor = [UIColor grayColor].CGColor;
                lineChartView.layer.borderWidth = 1.0;
                lineChartView.layer.cornerRadius = 5;
                lineChartView.layer.masksToBounds = YES;
                
                
                lineChartView.xUnits = @[@(15), @(16), @(17), @(18), @(19)];
                
                lineChartView.yUnits = @[@(70), @(75), @(80), @(85), @(90)];
                
                lineChartView.values = @[
                                         [NSValue valueWithCGPoint:CGPointMake(15, 75)],
                                         [NSValue valueWithCGPoint:CGPointMake(16, 85)],
                                         [NSValue valueWithCGPoint:CGPointMake(17, 75)],
                                         [NSValue valueWithCGPoint:CGPointMake(18, 90)],
                                         [NSValue valueWithCGPoint:CGPointMake(19, 80)]
                                         ];
                
                lineChartView.lineLayer.strokeColor = [UIColor appPrimaryColor].CGColor;
                lineChartView.lineLayer.lineWidth = 1.5;
                lineChartView.markerColor = [UIColor appPrimaryColor];
                lineChartView.markerRadius = 3;
                [graphCell.graphView addSubview:lineChartView];
                
                [lineChartView draw];
            }
        }
            break;
        case kDashboardSectionBloodCount:
        {
            cell = (APHDashboardGraphViewCell *)[tableView dequeueReusableCellWithIdentifier:kDashboardGraphCellIdentifier forIndexPath:indexPath];
            APHDashboardGraphViewCell * graphCell = (APHDashboardGraphViewCell *) cell;
            graphCell.titleLabel.text = NSLocalizedString(@"Blood Count", @"Blood Count");
            
        }
            break;
        case kDashboardSectionMedications:
        {
            cell = (APHDashboardGraphViewCell *)[tableView dequeueReusableCellWithIdentifier:kDashboardGraphCellIdentifier forIndexPath:indexPath];
            APHDashboardGraphViewCell * graphCell = (APHDashboardGraphViewCell *) cell;
            graphCell.titleLabel.text = NSLocalizedString(@"Medications", @"Medications");
            if (graphCell.graphView.subviews.count == 0) {
                YMLTimeLineChartView *timeLineChartView = [[YMLTimeLineChartView alloc] initWithFrame:CGRectMake(0, 0, graphCell.graphView.frame.size.width, graphCell.graphView.frame.size.height) orientation:YMLChartOrientationHorizontal];
                timeLineChartView.datasource = self;
                timeLineChartView.layer.borderColor = [UIColor grayColor].CGColor;
                timeLineChartView.layer.borderWidth = 1.0;
                timeLineChartView.layer.cornerRadius = 5;
                timeLineChartView.layer.masksToBounds = YES;
                [graphCell.graphView addSubview:timeLineChartView];
                
                [timeLineChartView redrawCanvas];
                [timeLineChartView addBar:[YMLTimeLineChartBarLayer layerWithColor:[UIColor appPrimaryColor]] fromUnit:15 toUnit:18 animation:YES];
                [timeLineChartView addBar:[YMLTimeLineChartBarLayer layerWithColor:[UIColor appPrimaryColor]] fromUnit:16 toUnit:19 animation:YES];
                [timeLineChartView addBar:[YMLTimeLineChartBarLayer layerWithColor:[UIColor appPrimaryColor]] fromUnit:15 toUnit:17 animation:YES];
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
        default:  NSAssert(0, @"Invalid Cell Type");
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Placeholder Value. Have to change when contents are present. Esp. for Alerts and Insights.
    return 150.f;
}

#pragma mark - Selection Actions

- (void)editTapped
{
    APHEditSectionsViewController *editSectionsViewController = [[APHEditSectionsViewController alloc] initWithNibName:@"APHEditSectionsViewController" bundle:nil];
    
    UINavigationController *editSectionsNavigationController = [[UINavigationController alloc] initWithRootViewController:editSectionsViewController];
    editSectionsNavigationController.navigationBar.translucent = NO;
    
    [self presentViewController:editSectionsNavigationController animated:YES completion:nil];
}

#pragma mark - YMLTimeLineChartViewDataSource

- (NSArray *) timeLineChartViewUnits:(YMLTimeLineChartView *)chartView {
    return @[@(15), @(16), @(17), @(18), @(19)];
}

- (NSString *) timeLineChartView:(YMLTimeLineChartView *)chartView titleAtIndex:(NSInteger)index {
    NSArray *titles = @[@"Sep 15", @"16", @"17", @"18", @"19"];
    
    NSString *title;
    if (index < titles.count) {
        title = titles[index];
    }
    
    return title;
}

@end
