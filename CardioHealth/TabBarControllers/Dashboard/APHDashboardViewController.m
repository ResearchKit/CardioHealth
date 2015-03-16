// 
//  APHDashboardViewController.m 
//  MyHeart Counts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
/* Controllers */
#import "APHDashboardViewController.h"
#import "APHDashboardEditViewController.h"
#import "APHAppDelegate.h"
#import "APHDashboardWalkTestTableViewCell.h"
#import "APHWalkTestViewController.h"
#import "APHWalkingTestResults.h"

static NSString *const kDatasetValueNoDataKey = @"datasetValueNoDataKey";

static NSString*  const kAPCBasicTableViewCellIdentifier        = @"APCBasicTableViewCell";
static NSString*  const kAPCRightDetailTableViewCellIdentifier  = @"APCRightDetailTableViewCell";

static NSString*  const kFitnessTestTaskId                      = @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995";
static NSString*  const kAPCTaskAttributeUpdatedAt              = @"updatedAt";
static NSString*  const kFitTestTotalDistDataSourceKey          = @"totalDistance";
static NSString*  const kFitTestpeakHeartRateDataSourceKey      = @"peakHeartRate";
static NSString*  const kFitTestlastHeartRateDataSourceKey      = @"lastHeartRate";

static CGFloat kTitleFontSize = 17.0f;
static CGFloat kDetailFontSize = 16.0f;

@interface APHDashboardViewController ()<APCPieGraphViewDatasource>

@property (nonatomic, strong)   NSArray*                allocationDataset;
@property (nonatomic, strong)   APCScoring*             stepScoring;
@property (nonatomic, strong)   APCScoring*             heartRateScoring;
@property (nonatomic, strong)   NSMutableArray*         rowItemsOrder;
@property (nonatomic, strong)   APHWalkingTestResults*  walkingResults;
@property (nonatomic)           NSNumber*               totalDistanceForSevenDay;
@property (nonatomic)           NSIndexPath*            currentPieGraphIndexPath;
@property (nonatomic)           NSNumber*               totalStepsValue;

@property (nonatomic) BOOL pieGraphDataExists;

@end

@implementation APHDashboardViewController

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _rowItemsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kAPCDashboardRowItemsOrder]];
        
        if (!_rowItemsOrder.count) {
            _rowItemsOrder = [[NSMutableArray alloc] initWithArray:@[]];
            if ([APCDeviceHardware isiPhone5SOrNewer]) {
                [_rowItemsOrder addObjectsFromArray:@[@(kAPHDashboardItemTypeSevenDayFitness), @(kAPHDashboardItemTypeWalkingTest)]];
            } else {
                [_rowItemsOrder addObjectsFromArray:@[@(kAPHDashboardItemTypeWalkingTest)]];
            }
            
            [defaults setObject:[NSArray arrayWithArray:_rowItemsOrder] forKey:kAPCDashboardRowItemsOrder];
            [defaults synchronize];
            
        }
        
        self.title = NSLocalizedString(@"Dashboard", @"Dashboard");

        /*
         Keep this "nil" until we get some real data from HealthKit
         (in -statsCollectionQuery, below).  If nil, we won't display it.
         */
        self.totalStepsValue = nil;

        /*
         We use this property to update some UI elements when that data
         arrives from HealthKit.  We set this property for the first time
         when we first load the table.  So let's keep it nil until then,
         so we don't try to redraw things before we have a place to draw them.
         */
        self.currentPieGraphIndexPath = nil;
    }
    
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    APHAppDelegate *appDelegate = (APHAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.allocationDataset = [appDelegate.sevenDayFitnessAllocationData weeksAllocation];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.rowItemsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kAPCDashboardRowItemsOrder]];
    
    [self prepareData];
    
    self.pieGraphDataExists = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.pieGraphDataExists = NO;
}

#pragma mark - Data


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
            
            item.info = NSLocalizedString(@"The activity completion indicates the percentage of activities scheduled for today that you have completed.  You can complete more by going to the Activities section and tapping on any incomplete task.", @"");
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = item;
            row.itemType = kAPCTableViewDashboardItemTypeProgress;
            [rowItems addObject:row];
        }
        
        for (NSNumber *typeNumber in self.rowItemsOrder) {
            
            APHDashboardItemType rowType = typeNumber.integerValue;
            
            switch (rowType) {
                
                case kAPHDashboardItemTypeSevenDayFitness:
                {
                    APHTableViewDashboardSevenDayFitnessItem *item = [APHTableViewDashboardSevenDayFitnessItem new];
                    item.caption = NSLocalizedString(@"7-Day Assessment", @"");
                    item.taskId = @"3-APHSevenDayAllocation-00000000-1111-1111-1111-F810BE28D995";
                
                    NSNumber *numberOfDaysRemaining = [self numberOfRemainingDaysInSevenDayFitnessTask];
                    
                    if (numberOfDaysRemaining != nil) {
                        
                        NSString *numOfDaysRemainingLabelInfo = nil;
                        if ([numberOfDaysRemaining integerValue] > 0) {
                            numOfDaysRemainingLabelInfo = NSLocalizedString([self fitnessDaysRemaining], @"");
                        }
                        
                        item.numberOfDaysString = numOfDaysRemainingLabelInfo;
                        
                        APHAppDelegate *appDelegate = (APHAppDelegate *)[[UIApplication sharedApplication] delegate];
                        NSString *sevenDayDistanceStr = nil;

                        sevenDayDistanceStr = [NSString stringWithFormat:@"%d Active Minutes", (int) roundf(appDelegate.sevenDayFitnessAllocationData.activeSeconds/60)];
                        
                        NSString *activityMinutesLabelInfo = nil;
                        
                        if ([numberOfDaysRemaining integerValue] > 0) {
                            activityMinutesLabelInfo = NSLocalizedString(sevenDayDistanceStr, @"");
                        }
                        
                        item.activeMinutesString = activityMinutesLabelInfo;
                        item.identifier = kAPCDashboardPieGraphTableViewCellIdentifier;
                        item.tintColor = [UIColor colorForTaskId:item.taskId];
                        item.editable = YES;
                    }
                    
                    item.info = NSLocalizedString(@"The circle shows estimates of the proportion of time you have been spending in different levels of activity, based on sensor data from your phone or wearable device. It also estimates your accumulated “active minutes,” which combines moderate and vigorous activities, and daily steps. This is intended to be informational, as accurate assessment of every type of activity from sensors is an ongoing area of research and development. Your data can help us refine these estimates and better understand the relationship between activity and your health.", @"");
                    
                    //If there is no date returned then no task has ever been started and thus we don't show this graph.
                    if ([self checkSevenDayFitnessStartDate] != nil) {
                    
                        APCTableViewRow *row = [APCTableViewRow new];
                        row.item = item;
                        row.itemType = rowType;
                        [rowItems addObject:row];
                    }
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
                    
                    item.caption = NSLocalizedString(@"6-Minute Walk Test", @"");
                    item.taskId = @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995";
                    item.identifier = kAPHDashboardWalkTestTableViewCellIdentifier;
                    item.tintColor = [UIColor colorForTaskId:item.taskId];
                    item.editable = YES;
                    
                    item.info = NSLocalizedString(@"This shows the distance you have walked in 6 minutes, which is a simple measure of fitness. We are also implementing a feature to give you the typical distance expected for your age, gender, height, and weight. You can also view a log of your prior data. Heart rate data are made available if you were using a wearable device capable of recording heart rate while walking.", @"");
                    
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
        
        pieGraphCell.subTitleLabel2.alpha = 0;
        
        [UIView animateWithDuration:0.2 animations:^{
            pieGraphCell.subTitleLabel2.text = fitnessItem.activeMinutesString;
            pieGraphCell.subTitleLabel2.alpha = 1;
        }];
        
        NSMutableAttributedString *attirbutedDistanceString = nil;
        
        if (fitnessItem.activeMinutesString != nil && ![fitnessItem.activeMinutesString isEqualToString:@""]) {
            attirbutedDistanceString = [[NSMutableAttributedString alloc] initWithString:fitnessItem.activeMinutesString];
            [attirbutedDistanceString addAttribute:NSFontAttributeName value:[UIFont appMediumFontWithSize:kTitleFontSize] range:NSMakeRange(0, (fitnessItem.activeMinutesString.length - @" Active Minutes".length))];
            [attirbutedDistanceString addAttribute:NSFontAttributeName value:[UIFont appRegularFontWithSize:kDetailFontSize] range: [fitnessItem.activeMinutesString rangeOfString:@" Active Minutes"]];
        }

        /*
         Total number of steps.  This "nil" check keeps it blank until
         we hear back from HealthKit (in -statsCollectionQuery, below).
         */
        NSMutableAttributedString *attributedTotalStepsString = nil;

        if (self.totalStepsValue != nil)
        {
            NSString *explanation         = @" Steps Today";
            NSString *nonAttributedString = [NSString stringWithFormat: @"%@%@", self.totalStepsValue, explanation];
            attributedTotalStepsString    = [[NSMutableAttributedString alloc] initWithString: nonAttributedString];

            [attributedTotalStepsString addAttribute: NSFontAttributeName
                                               value: [UIFont appMediumFontWithSize:kTitleFontSize]
                                               range: NSMakeRange (0, nonAttributedString.length)];

            [attributedTotalStepsString addAttribute: NSFontAttributeName
                                               value: [UIFont appRegularFontWithSize:kDetailFontSize]
                                               range: [nonAttributedString rangeOfString: explanation]];
        }


        pieGraphCell.subTitleLabel3.attributedText = attributedTotalStepsString;
        
        pieGraphCell.subTitleLabel2.attributedText = attirbutedDistanceString;
        
        pieGraphCell.title = fitnessItem.caption;
        pieGraphCell.tintColor = fitnessItem.tintColor;
        pieGraphCell.pieGraphView.shouldAnimateLegend = NO;
        
        if (!self.pieGraphDataExists) {
            
            [pieGraphCell.pieGraphView setNeedsLayout];
            
            [self statsCollectionQueryForStep];
            self.pieGraphDataExists = YES;
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

- (void)tableView:(UITableView *) __unused tableView willDisplayCell:(UITableViewCell *) __unused cell forRowAtIndexPath:(NSIndexPath *) __unused indexPath {
}

#pragma mark - Pie Graph View delegates

-(NSInteger)numberOfSegmentsInPieGraphView
{
    return [self.allocationDataset count];
}

- (UIColor *)pieGraphView:(APCPieGraphView *) __unused pieGraphView colorForSegmentAtIndex:(NSInteger)index
{
    return [[self.allocationDataset valueForKey:kDatasetSegmentColorKey] objectAtIndex:index];
}

- (NSString *)pieGraphView:(APCPieGraphView *) __unused pieGraphView titleForSegmentAtIndex:(NSInteger)index
{
    return [[self.allocationDataset valueForKey:kDatasetSegmentKey] objectAtIndex:index];
}

- (CGFloat)pieGraphView:(APCPieGraphView *) __unused pieGraphView valueForSegmentAtIndex:(NSInteger)index
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

- (NSNumber *)numberOfRemainingDaysInSevenDayFitnessTask {
    
    NSDate *startDate = [self checkSevenDayFitnessStartDate];
    
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
    
    NSInteger daysRemain = 0;
    

    daysRemain = 7 - numberOfDaysFromStartDate.day;


    return startDate ? @(daysRemain) : nil;
}

- (NSString *)fitnessDaysRemaining
{
    NSDate *startDate = [self checkSevenDayFitnessStartDate];
    
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
    
    if ( daysRemain == 1) {
        remaining = NSLocalizedString(@"Last Day", nil);
    }
    
    return remaining;
}

- (NSDate *)checkSevenDayFitnessStartDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *fitnessStartDate = [defaults objectForKey:kSevenDayFitnessStartDateKey];
    
    return fitnessStartDate;
}

- (void)statsCollectionQueryForStep
{
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                 minute:0
                                                                 second:0
                                                                 ofDate:[NSDate date]
                                                                options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:[NSDate date] options:HKQueryOptionStrictEndDate];
    
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:predicate
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:startDate
                                                                                intervalComponents:interval];
    
    // set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery * __unused query,
                                    HKStatisticsCollection *results,
                                    NSError *error) {
        if (!error) {
            NSDate *endDate = [NSDate date];
            NSDate *beginDate = startDate;
            
            [results enumerateStatisticsFromDate:beginDate
                                          toDate:endDate
                                       withBlock:^(HKStatistics *result, BOOL * __unused stop) {

                                           HKQuantity *quantity = result.sumQuantity;
                                           double numberOfSteps = [quantity doubleValueForUnit:[HKUnit countUnit]];
                                           [self updateTotalStepsItemWithValue: numberOfSteps];
                                       }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
            [self updateSevenDayItem];
            });
            
        } else {
            APCLogError2(error);
        }
    };
    
    [[HKHealthStore new] executeQuery:query];
}

- (NSDate *)dateForSpan:(NSInteger)daySpan
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daySpan];
    
    NSDate *spanDate = [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                                     toDate:[NSDate date]
                                                                    options:0];
    return spanDate;
}



- (void)updateSevenDayItem {
    
    if (!self.pieGraphDataExists) {

        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[self.currentPieGraphIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
        self.pieGraphDataExists = YES;
    }
}

- (void) updateTotalStepsItemWithValue: (double) rawNumberOfSteps
{
    NSInteger numberOfStepsAsInt = (NSInteger) rawNumberOfSteps;

    if (numberOfStepsAsInt > 0)
    {
        NSNumber *numberOfSteps = @(numberOfStepsAsInt);

        /*
         The __weak means:  if the view gets destroyed before the main-queue
         block executes (below), the __weak variable weakSelf will become nil.
         This means that when the main-thread code eventually DOES run -- which
         it always will - it'll execute safely.
         */
        __weak APHDashboardViewController *weakSelf = self;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            weakSelf.totalStepsValue = numberOfSteps;

            if (weakSelf.currentPieGraphIndexPath != nil)
            {
                [weakSelf.tableView reloadRowsAtIndexPaths: @[weakSelf.currentPieGraphIndexPath]
                                          withRowAnimation: UITableViewRowAnimationNone];
            }
        }];
    }
}

@end

