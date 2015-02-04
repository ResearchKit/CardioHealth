// 
//  APHDashboardViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
/* Controllers */
#import "APHDashboardViewController.h"
#import "APHDashboardEditViewController.h"
#import "APHFitnessAllocation.h"
#import "APHAppDelegate.h"
#import "APHDashboardWalkTestTableViewCell.h"

static NSString*  const kAPCBasicTableViewCellIdentifier       = @"APCBasicTableViewCell";
static NSString*  const kAPCRightDetailTableViewCellIdentifier = @"APCRightDetailTableViewCell";
static NSInteger  const kDataCountLimit                        = 1;

@interface APHDashboardViewController ()<APCPieGraphViewDatasource>

@property (nonatomic)           NSInteger           dataCount;
@property (nonatomic, strong)   NSArray*            allocationDataset;
@property (nonatomic, strong)   APCScoring*         stepScoring;
@property (nonatomic, strong)   APCScoring*         heartRateScoring;
@property (nonatomic, strong)   NSMutableArray*     rowItemsOrder;
@property (nonatomic, strong)   NSDateFormatter*    dateFormatter;
@property (nonatomic, strong)   APCPresentAnimator* presentAnimator;
@property (nonatomic, strong)   APCFadeAnimator*    fadeAnimator;

@end

@implementation APHDashboardViewController

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _rowItemsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kAPCDashboardRowItemsOrder]];
        
        if (!_rowItemsOrder.count) {
            _rowItemsOrder = [[NSMutableArray alloc] initWithArray:@[
                                                                     @(kAPHDashboardItemTypeDistance),
                                                                     @(kAPHDashboardItemTypeHeartRate),
                                                                     @(kAPHDashboardItemTypeSevenDayFitness), @(kAPHDashboardItemTypeWalkingTest)
                                                                     ]];
            
            [defaults setObject:[NSArray arrayWithArray:_rowItemsOrder] forKey:kAPCDashboardRowItemsOrder];
            [defaults synchronize];
            
        }
        
        self.title = NSLocalizedString(@"Dashboard", @"Dashboard");
        
        _presentAnimator = [APCPresentAnimator new];
        _fadeAnimator = [APCFadeAnimator new];
        _dateFormatter = [NSDateFormatter new];
    }
    
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self updatePieChart:nil];
    [self prepareScoringObjects];
    [self prepareData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePieChart:)
                                                 name:APHSevenDayAllocationDataIsReadyNotification
                                               object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.rowItemsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kAPCDashboardRowItemsOrder]];

    [self updatePieChart:nil];
    
    [self prepareScoringObjects];
    [self prepareData];
    
    //Every time the cells are reloaded this variable is checked and used to prevent unnecessary drawing of the pie graph.
    self.dataCount = 0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APHSevenDayAllocationDataIsReadyNotification
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - APCDashboardGraphTableViewCellDelegate methods
- (void)updateVisibleRowsInTableView:(NSNotification *)notification
{
    //Every time the cells are reloaded this variable is added to and used as a flag to prevent unnecessary drawing of the pie graph.
    self.dataCount++;
    
    [self prepareData];
}

#pragma mark - Data

- (void)updatePieChart:(NSNotification *)notification
{
    APHAppDelegate *appDelegate = (APHAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.allocationDataset = [appDelegate.sevenDayFitnessAllocationData todaysAllocation];
    [self.tableView reloadData];
}

- (void)prepareScoringObjects {
    

    HKQuantityType *stepQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    self.stepScoring= [[APCScoring alloc] initWithHealthKitQuantityType:stepQuantityType unit:[HKUnit countUnit] numberOfDays:-5];

    HKQuantityType *heartRateQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    self.heartRateScoring = [[APCScoring alloc] initWithHealthKitQuantityType:heartRateQuantityType unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] numberOfDays:-5];

}

- (void)prepareData
{
    [self.items removeAllObjects];
    
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        NSUInteger allScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.countOfAllScheduledTasksForToday;
        NSUInteger completedScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.countOfCompletedScheduledTasksForToday;
                
        {
            APCTableViewDashboardProgressItem *item = [APCTableViewDashboardProgressItem new];
            item.identifier = kAPCDashboardProgressTableViewCellIdentifier;
            item.editable = NO;
            item.progress = (CGFloat)completedScheduledTasks/allScheduledTasks;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = item;
            row.itemType = kAPCTableViewDashboardItemTypeProgress;
            [rowItems addObject:row];
        }
        
        
        APCTableViewSection *section = [APCTableViewSection new];
        NSDate *dateToday = [NSDate date];
        
        self.dateFormatter.dateFormat = @"MMMM d";
        
        section.sectionTitle = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"Today", @""), [self.dateFormatter stringFromDate:dateToday]];
        section.rows = [NSArray arrayWithArray:rowItems];
        section.rows = [NSArray arrayWithArray:rowItems];
        [self.items addObject:section];
    }
    
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        for (NSNumber *typeNumber in self.rowItemsOrder) {
            
            APHDashboardItemType rowType = typeNumber.integerValue;
            
            switch (rowType) {
                case kAPHDashboardItemTypeDistance:
                {
                    APCTableViewDashboardGraphItem *item = [APCTableViewDashboardGraphItem new];
                    item.caption = NSLocalizedString(@"Steps", @"");
                    item.graphData = self.stepScoring;
                    item.detailText = [NSString stringWithFormat:NSLocalizedString(@"Average : %0.0f", @"Average: {value}"), [[self.stepScoring averageDataPoint] doubleValue]];
                    item.identifier = kAPCDashboardGraphTableViewCellIdentifier;
                    item.editable = YES;
                    item.tintColor = [UIColor appTertiaryPurpleColor];
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];

                }
                    break;
                case kAPHDashboardItemTypeHeartRate:{
                    
                    APCTableViewDashboardGraphItem *item = [APCTableViewDashboardGraphItem new];
                    item.caption = NSLocalizedString(@"Heart Rate", @"");
                    item.graphData = self.heartRateScoring;
                    
                    item.detailText = [NSString stringWithFormat:NSLocalizedString(@"Average : %0.0f bpm", @"Average: {value} bpm"), [[self.heartRateScoring averageDataPoint] doubleValue]];
                    item.identifier = kAPCDashboardGraphTableViewCellIdentifier;
                    item.editable = YES;
                    item.tintColor = [UIColor appTertiaryYellowColor];
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
                }
                    break;
                
                case kAPHDashboardItemTypeSevenDayFitness:
                {
                    APHTableViewDashboardFitnessControlItem *item = [APHTableViewDashboardFitnessControlItem new];
                    item.caption = NSLocalizedString(@"7-Day Assessment", @"");
                    item.identifier = kAPCDashboardPieGraphTableViewCellIdentifier;
                    item.tintColor = [UIColor appTertiaryGreenColor];
                    item.editable = YES;
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
                }
                    break;
                    
                case kAPHDashboardItemTypeWalkingTest:
                {
                    APHTableViewDashboardWalkingTestItem *item = [APHTableViewDashboardWalkingTestItem new];
                    item.caption = NSLocalizedString(@"6-minute Walking Test", @"");
                    item.identifier = kAPHDashboardWalkTestTableViewCellIdentifier;
                    
                    /* Placeholder values.-- */
                    item.info = NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", @"");
                    item.distanceWalked = 2100;
                    item.peakHeartRate = 110;
                    item.finalHeartRate = 86;
                    item.lastPerformedDate = [NSDate date];
                    /* -- Pull the actual values from the corresponding activity*/
                    
                    item.tintColor = [UIColor appTertiaryRedColor];
                    item.editable = YES;
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
                }
                    break;

                default:
                    break;
            }
            
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        section.sectionTitle = NSLocalizedString(@"Recent Activity", @"");
        [self.items addObject:section];
    }
    
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    APCTableViewDashboardItem *dashboardItem = (APCTableViewDashboardItem *)[self itemForIndexPath:indexPath];
    
    if ([dashboardItem isKindOfClass:[APHTableViewDashboardFitnessControlItem class]]){
        APHTableViewDashboardFitnessControlItem *fitnessItem = (APHTableViewDashboardFitnessControlItem *)dashboardItem;
        
        APCDashboardPieGraphTableViewCell *pieGraphCell = (APCDashboardPieGraphTableViewCell *)cell;
        
        pieGraphCell.pieGraphView.datasource = self;
        pieGraphCell.textLabel.text = @"";
        pieGraphCell.titleLabel.text = fitnessItem.caption;
        pieGraphCell.tintColor = fitnessItem.tintColor;
        pieGraphCell.pieGraphView.shouldAnimateLegend = NO;
        
        //Every time the cells are reloaded this variable is checked and used to prevent unnecessary drawing of the pie graph.
        if (self.dataCount < kDataCountLimit) {
            [pieGraphCell.pieGraphView setNeedsLayout];
        }
        
        
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardWalkingTestItem class]]){
        APHTableViewDashboardWalkingTestItem *walkingTestItem = (APHTableViewDashboardWalkingTestItem *)dashboardItem;
        
        APHDashboardWalkTestTableViewCell *walkingTestCell = (APHDashboardWalkTestTableViewCell *)cell;
        
        walkingTestCell.textLabel.text = @"";
        walkingTestCell.title = walkingTestItem.caption;
        walkingTestCell.distanceLabel.text = [NSString stringWithFormat:@"Distance Walked: %ld ft", (long)walkingTestItem.distanceWalked];
        walkingTestCell.peakHeartRateLabel.text = [NSString stringWithFormat:@"Peak Heart Rate: %ld bpm", (long)walkingTestItem.peakHeartRate];
        walkingTestCell.finalHeartRateLabel.text = [NSString stringWithFormat:@"Final Heart Rate: %ld bpm", (long)walkingTestItem.finalHeartRate];
        
        
        self.dateFormatter.dateFormat = @"MMM. d";
        walkingTestCell.lastPerformedDateLabel.text = [NSString stringWithFormat:@"Last performed %@", [self.dateFormatter stringFromDate:walkingTestItem.lastPerformedDate]];
        walkingTestCell.tintColor = walkingTestItem.tintColor;
        walkingTestCell.delegate = self;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    APCTableViewItem *dashboardItem = [self itemForIndexPath:indexPath];
    
    if ([dashboardItem isKindOfClass:[APHTableViewDashboardFitnessControlItem class]]){
        height = 255.0f;
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardWalkingTestItem class]]) {
        height = 138.0;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //cell.contentView.subviews
    
}

- (void)dashboardGraphViewCellDidTapExpandForCell:(APCDashboardLineGraphTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewDashboardGraphItem *graphItem = (APCTableViewDashboardGraphItem *)[self itemForIndexPath:indexPath];
    
    CGRect initialFrame = [cell convertRect:cell.bounds toView:self.view.window];
    self.presentAnimator.initialFrame = initialFrame;

    APCLineGraphViewController *graphViewController = [[UIStoryboard storyboardWithName:@"APHDashboard" bundle:nil] instantiateViewControllerWithIdentifier:@"GraphVC"];
    graphViewController.graphItem = graphItem;
//    graphViewController.transitioningDelegate = self;
//    graphViewController.modalPresentationStyle = UIModalPresentationCustom;
    [self.navigationController presentViewController:graphViewController animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if ([presented isKindOfClass:[APCLineGraphViewController class]]) {
        animationController = self.presentAnimator;
        self.presentAnimator.presenting = YES;
    } else if ([presented isKindOfClass:[APCDashboardMoreInfoViewController class]]){
        animationController = self.fadeAnimator;
        self.fadeAnimator.presenting = YES;
    }
    
    return animationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if ([dismissed isKindOfClass:[APCLineGraphViewController class]]) {
        animationController = self.presentAnimator;
        self.presentAnimator.presenting = NO;
    } else if ([dismissed isKindOfClass:[APCDashboardMoreInfoViewController class]]){
        animationController = self.fadeAnimator;
        self.fadeAnimator.presenting = NO;
    }
    
    return animationController;
}

#pragma mark - Pie Graph View delegates

-(NSInteger)numberOfSegmentsInPieGraphView
{
    return [self.allocationDataset count];
}

- (UIColor *)pieGraphView:(APCPieGraphView *)pieGraphView colorForSegmentAtIndex:(NSInteger)index
{
    return [[self.allocationDataset valueForKey:kDatasetSegmentColorKey] objectAtIndex:index];
}

- (NSString *)pieGraphView:(APCPieGraphView *)pieGraphView titleForSegmentAtIndex:(NSInteger)index
{
    return [[self.allocationDataset valueForKey:kDatasetSegmentKey] objectAtIndex:index];
}

- (CGFloat)pieGraphView:(APCPieGraphView *)pieGraphView valueForSegmentAtIndex:(NSInteger)index
{
    return [[[self.allocationDataset valueForKey:kSegmentSumKey] objectAtIndex:index] floatValue];
}

@end

@implementation APHTableViewDashboardFitnessControlItem

@end

@implementation APHTableViewDashboardWalkingTestItem

@end

