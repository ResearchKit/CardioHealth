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

static NSString * const kAPCBasicTableViewCellIdentifier       = @"APCBasicTableViewCell";
static NSString * const kAPCRightDetailTableViewCellIdentifier = @"APCRightDetailTableViewCell";

@interface APHDashboardViewController ()<UIViewControllerTransitioningDelegate, APCPieGraphViewDatasource>

@property (nonatomic, strong) NSMutableArray *rowItemsOrder;

@property (nonatomic, strong) APCPresentAnimator *presentAnimator;

@property (nonatomic, strong) NSArray *allocationDataset;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) APCScoring *stepScoring;
@property (nonatomic, strong) APCScoring *heartRateScoring;
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
                                                                     @(kAPHDashboardItemTypeSevenDayFitness)
                                                                     ]];
            
            [defaults setObject:[NSArray arrayWithArray:_rowItemsOrder] forKey:kAPCDashboardRowItemsOrder];
            [defaults synchronize];
            
        }
        
        self.title = NSLocalizedString(@"Dashboard", @"Dashboard");
        
        _presentAnimator = [APCPresentAnimator new];
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
            APCTableViewItem *item = [APCTableViewItem new];
            item.caption = NSLocalizedString(@"Activities", @"");
            item.identifier = kAPCRightDetailTableViewCellIdentifier;
            item.editable = NO;
            item.textAlignnment = NSTextAlignmentRight;

            
            item.detailText = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)completedScheduledTasks, (unsigned long)allScheduledTasks];
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = item;
            row.itemType = kAPCTableViewDashboardItemTypeProgress;
            [rowItems addObject:row];
        }
        
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
        [pieGraphCell.pieGraphView setNeedsLayout];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    APCTableViewItem *dashboardItem = [self itemForIndexPath:indexPath];
    
    if ([dashboardItem isKindOfClass:[APHTableViewDashboardFitnessControlItem class]]){
        height = 255.0f;
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
                                                                      sourceController:(UIViewController *)source {
    self.presentAnimator.presenting = YES;
    return self.presentAnimator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    self.presentAnimator.presenting = NO;
    return self.presentAnimator;
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
