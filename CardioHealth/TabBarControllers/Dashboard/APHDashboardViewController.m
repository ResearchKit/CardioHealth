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
#import "APHWalkTestViewController.h"
#import "APHWalkingTestResults.h"


static   CGFloat const metersPerMile             = 1609.344;
static NSString*  const kAPCBasicTableViewCellIdentifier        = @"APCBasicTableViewCell";
static NSString*  const kAPCRightDetailTableViewCellIdentifier  = @"APCRightDetailTableViewCell";
static NSInteger  const kDataCountLimit                         = 1;

static NSString*  const kFitnessTestTaskId                      = @"APHFitnessTest-00000000-1111-1111-1111-F810BE28D995";
static NSString*  const kAPCTaskAttributeUpdatedAt              = @"updatedAt";
static NSString*  const kFitTestTotalDistDataSourceKey          = @"totalDistance";
static NSString*  const kFitTestpeakHeartRateDataSourceKey      = @"peakHeartRate";
static NSString*  const kFitTestlastHeartRateDataSourceKey      = @"lastHeartRate";


@interface APHDashboardViewController ()<APCPieGraphViewDatasource>

@property (nonatomic)           NSInteger               dataCount;
@property (nonatomic, strong)   NSArray*                allocationDataset;
@property (nonatomic, strong)   APCScoring*             stepScoring;
@property (nonatomic, strong)   APCScoring*             heartRateScoring;
@property (nonatomic, strong)   NSMutableArray*         rowItemsOrder;
@property (nonatomic, strong)   APHWalkingTestResults*  walkingResults;
@property (nonatomic)           NSNumber*               totalDistanceForSevenDay;
@property (nonatomic)           NSIndexPath*            currentPieGraphIndexPath;

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
                                                                     ]];
            if ([APCDeviceHardware isiPhone5SOrNewer]) {
                [_rowItemsOrder addObjectsFromArray:@[@(kAPHDashboardItemTypeSevenDayFitness), @(kAPHDashboardItemTypeWalkingTest)]];
            } else {
                [_rowItemsOrder addObjectsFromArray:@[@(kAPHDashboardItemTypeWalkingTest)]];
            }
            
            [defaults setObject:[NSArray arrayWithArray:_rowItemsOrder] forKey:kAPCDashboardRowItemsOrder];
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
    self.stepScoring= [[APCScoring alloc] initWithHealthKitQuantityType:stepQuantityType unit:[HKUnit countUnit] numberOfDays:-kNumberOfDaysToDisplay];

    HKQuantityType *heartRateQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    self.heartRateScoring = [[APCScoring alloc] initWithHealthKitQuantityType:heartRateQuantityType unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] numberOfDays:-kNumberOfDaysToDisplay];

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
            item.caption = NSLocalizedString(@"Activity Completion", @"Activity Completion");
            
#warning Replace Placeholder Values - APPLE-1576
            item.info = NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", @"");
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = item;
            row.itemType = kAPCTableViewDashboardItemTypeProgress;
            [rowItems addObject:row];
        }
        
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
                    
                    #warning Replace Placeholder Values - APPLE-1576
                    item.info = NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", @"");
                    
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
                    
                    #warning Replace Placeholder Values - APPLE-1576
                    item.info = NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", @"");
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
                }
                    break;
                
                case kAPHDashboardItemTypeSevenDayFitness:
                {
                    APHTableViewDashboardSevenDayFitnessItem *item = [APHTableViewDashboardSevenDayFitnessItem new];
                    item.caption = NSLocalizedString(@"7-Day Assessment", @"");
                    item.numberOfDaysString = NSLocalizedString([self fitnessDaysRemaining], @"");
                    
                    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                                 minute:0
                                                                                 second:0
                                                                                 ofDate:[NSDate date]
                                                                                options:0];
                    

                    APHAppDelegate *appDelegate = (APHAppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate.sevenDayFitnessAllocationData runStatsCollectionQueryfromStartDate:startDate toEndDate:[NSDate date]];
                    
                    
                    NSString *sevenDayDistanceStr = nil;

                    //If healthkit updated quickly enough then fill in the data.
                    if (self.totalDistanceForSevenDay != nil) {
                        sevenDayDistanceStr = [NSString stringWithFormat:@"%.2f miles", [self.totalDistanceForSevenDay floatValue]/metersPerMile];
                    }
                    
                    item.distanceTraveledString = sevenDayDistanceStr;
                    item.identifier = kAPCDashboardPieGraphTableViewCellIdentifier;
                    item.tintColor = [UIColor appTertiaryGreenColor];
                    item.editable = YES;
                    
                    #warning Replace Placeholder Values - APPLE-1576
                    item.info = NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", @"");
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
                }
                    break;
                    
                case kAPHDashboardItemTypeWalkingTest:
                {
                    if (self.walkingResults) {
                        self.walkingResults = nil;
                    }
                    
                    self.walkingResults = [APHWalkingTestResults new];
                    
                    APHTableViewDashboardWalkingTestItem *item;
                    
                    if (self.walkingResults.results.count) {
                        item = [self.walkingResults.results firstObject];
                    } else {
                        item = [APHTableViewDashboardWalkingTestItem new];
                    }
                    
                    item.caption = NSLocalizedString(@"6-minute Walking Test", @"");
                    item.identifier = kAPHDashboardWalkTestTableViewCellIdentifier;
                    item.tintColor = [UIColor appTertiaryRedColor];
                    item.editable = YES;
                    
#warning Replace Placeholder Values - APPLE-1576
                    item.info = NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", @"");
                    
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

        
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardSevenDayFitnessItem class]]){
        APHTableViewDashboardSevenDayFitnessItem *fitnessItem = (APHTableViewDashboardSevenDayFitnessItem *)dashboardItem;
        self.currentPieGraphIndexPath = indexPath;
        APCDashboardPieGraphTableViewCell *pieGraphCell = (APCDashboardPieGraphTableViewCell *)cell;
        
        pieGraphCell.pieGraphView.datasource = self;
        pieGraphCell.textLabel.text = @"";
        pieGraphCell.subTitleLabel.text = fitnessItem.numberOfDaysString;
        
        if (fitnessItem.distanceTraveledString == nil) {
            fitnessItem.distanceTraveledString = [NSString stringWithFormat:@"%0.1f miles", [self.totalDistanceForSevenDay floatValue]/metersPerMile];
            
            pieGraphCell.subTitleLabel2.alpha = 0;
            
            [UIView animateWithDuration:0.2 animations:^{
                pieGraphCell.subTitleLabel2.text = fitnessItem.distanceTraveledString;
                pieGraphCell.subTitleLabel2.alpha = 1;
            }];
        }
        
        NSMutableAttributedString *attirbutedDistanceString = [[NSMutableAttributedString alloc] initWithString:fitnessItem.distanceTraveledString];
        [attirbutedDistanceString addAttribute:NSFontAttributeName value:[UIFont appMediumFontWithSize:17.0f] range:NSMakeRange(0, (fitnessItem.distanceTraveledString.length - @" miles".length))];
        [attirbutedDistanceString addAttribute:NSFontAttributeName value:[UIFont appRegularFontWithSize:16.0f] range: [fitnessItem.distanceTraveledString rangeOfString:@" miles"]];
        
        pieGraphCell.subTitleLabel2.attributedText = attirbutedDistanceString;
        
        pieGraphCell.title = fitnessItem.caption;
        pieGraphCell.tintColor = fitnessItem.tintColor;
        pieGraphCell.pieGraphView.shouldAnimateLegend = NO;
        
        //Every time the cells are reloaded this variable is checked and used to prevent unnecessary drawing of the pie graph.
        if (self.dataCount < kDataCountLimit) {
            [pieGraphCell.pieGraphView setNeedsLayout];
        }
        
        pieGraphCell.delegate = self;
    
        
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardWalkingTestItem class]]){
        APHTableViewDashboardWalkingTestItem *walkingTestItem = (APHTableViewDashboardWalkingTestItem *)dashboardItem;
        
        APHDashboardWalkTestTableViewCell *walkingTestCell = (APHDashboardWalkTestTableViewCell *)cell;
        
        walkingTestCell.textLabel.text = @"";
        walkingTestCell.title = walkingTestItem.caption;
        walkingTestCell.distanceLabel.text = [NSString stringWithFormat:@"Distance Walked: %ld yd", (long)walkingTestItem.distanceWalked];

        walkingTestCell.peakHeartRateLabel.text = (walkingTestItem.peakHeartRate != 0) ? [NSString stringWithFormat:@"Peak Heart Rate: %ld bpm", (long)walkingTestItem.peakHeartRate] : @"Peak Heart Rate: N/A";
        
        walkingTestCell.finalHeartRateLabel.text = (walkingTestItem.finalHeartRate != 0) ? [NSString stringWithFormat:@"Final Heart Rate: %ld bpm", (long)walkingTestItem.finalHeartRate] : @"Final Heart Rate: N/A";
        
        self.dateFormatter.dateFormat = @"MMM. d";
        walkingTestCell.lastPerformedDateLabel.text = (walkingTestItem.activityDate) ?  [NSString stringWithFormat:@"Last performed %@", [self.dateFormatter stringFromDate:walkingTestItem.activityDate]] : @"Last performed - N/A";
        walkingTestCell.tintColor = walkingTestItem.tintColor;
        walkingTestCell.delegate = self;
        
        walkingTestCell.resizeButton.hidden = (self.walkingResults.results.count == 0);
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
        height = 141.0;
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardSevenDayFitnessItem class]]) {
        height = 288.0;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //cell.contentView.subviews
    
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

#pragma mark - APCDashboardTableViewCellDelegate methods

- (void)dashboardTableViewCellDidTapExpand:(APCDashboardTableViewCell *)cell
{
    [super dashboardTableViewCellDidTapExpand:cell];
    
    if ([cell isKindOfClass:[APHDashboardWalkTestTableViewCell class]]) {
       
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        APHTableViewDashboardWalkingTestItem *item = (APHTableViewDashboardWalkingTestItem *)[self itemForIndexPath:indexPath];
        
        APHWalkTestViewController *walkTestViewController = [[UIStoryboard storyboardWithName:@"APHDashboard" bundle:nil] instantiateViewControllerWithIdentifier:@"APHWalkTestViewController"];
        walkTestViewController.tintColor = item.tintColor;
        walkTestViewController.results = self.walkingResults.results;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:walkTestViewController];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
}

#pragma mark - Helper Methods

- (NSString *)fitnessDaysRemaining
{
    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                 minute:0
                                                                 second:0
                                                                 ofDate:[self checkSevenDayFitnessStartDate]
                                                                options:0];
    NSDate *today = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                             minute:0
                                                             second:0
                                                             ofDate:[NSDate date]
                                                            options:0];
    
    
    // Compute the remaing days of the 7 day fitness allocation.
    NSDateComponents *numberOfDaysFromStartDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                                  fromDate:startDate
                                                                                    toDate:today
                                                                                   options:NSCalendarWrapComponents];
    
    NSUInteger daysRemain = 0;
    
    if (numberOfDaysFromStartDate.day < 7) {
        daysRemain = 7 - numberOfDaysFromStartDate.day;
    }
    
    NSString *days = (daysRemain == 1) ? NSLocalizedString(@"Day", @"Day") : NSLocalizedString(@"Days", @"Days");
    
    NSString *remaining = [NSString stringWithFormat:NSLocalizedString(@"%lu %@ Remaining",
                                                                       @"{count} {day/s} Remaining"), daysRemain, days];
    
    return remaining;
}

- (NSDate *)checkSevenDayFitnessStartDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *fitnessStartDate = [defaults objectForKey:kSevenDayFitnessStartDateKey];
    
    if (!fitnessStartDate) {
        
        NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                     minute:0
                                                                     second:0
                                                                     ofDate:[NSDate date]
                                                                    options:0];
        
        fitnessStartDate = startDate;
        
        APHAppDelegate *appDelegate = (APHAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.sevenDayFitnessAllocationData = [[APHFitnessAllocation alloc] initWithAllocationStartDate:fitnessStartDate];
        [appDelegate.sevenDayFitnessAllocationData startDataCollection];
    }
    
    return fitnessStartDate;
}

@end

