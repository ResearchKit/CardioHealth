//
//  APHDashboardViewController.m 
//  MyHeart Counts 
// 
// Copyright (c) 2015, Stanford Medical. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 

#import "APHAppDelegate.h"
#import "APHCardioInsightCell.h"
#import "APHDailyInsights.h"
#import "APHDashboardViewController.h"
#import "APHDashboardEditViewController.h"
#import "APHDashboardWalkTestTableViewCell.h"
#import "APHDashboardWalkTestComparisonTableViewCell.h"
#import "APHWalkTestViewController.h"
#import "APHWalkingTestResults.h"
#import "APHWalkingTestComparisonViewController.h"
#import "APHDailyInsight.h"

static NSString*  const kDatasetValueNoDataKey                  = @"datasetValueNoDataKey";
static NSString*  const kAPCBasicTableViewCellIdentifier        = @"APCBasicTableViewCell";
static NSString*  const kAPCRightDetailTableViewCellIdentifier  = @"APCRightDetailTableViewCell";
static NSString*  const kFitnessTestTaskId                      = @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995";
static NSString*  const kAPCTaskAttributeUpdatedAt              = @"updatedAt";
static NSString*  const kFitTestpeakHeartRateDataSourceKey      = @"peakHeartRate";
static NSString*  const kFitTestlastHeartRateDataSourceKey      = @"lastHeartRate";
static NSString*  const kDashBoardStoryBoardKey                 = @"APHDashboard";
static CGFloat          kTitleFontSize                          = 17.0f;
static CGFloat          kDetailFontSize                         = 16.0f;

static CGFloat          kFitnessControlRowHeight                = 255.0f;
static CGFloat          kWalkingTestRowHeight                   = 141.0f;
static CGFloat          kWalkingTestComparisonRowHeight         = 270.0f;
static CGFloat          kSevenDayFitnessRowHeight               = 288.0f;

@interface APHDashboardViewController ()<APCPieGraphViewDatasource>

@property (nonatomic, strong)   NSArray*                allocationDataset;
@property (nonatomic, strong)   APCScoring*             stepScoring;
@property (nonatomic, strong)   APCScoring*             heartRateScoring;
@property (nonatomic, strong)   NSMutableArray*         rowItemsOrder;
@property (nonatomic, strong)   APHWalkingTestResults*  walkingResults;
@property (nonatomic)           NSNumber*               totalDistanceForSevenDay;
@property (nonatomic)           NSIndexPath*            currentPieGraphIndexPath;
@property (nonatomic)           NSNumber*               totalStepsValue;

@property (nonatomic, strong)   APHDailyInsights*       dailyInsights;

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
                [_rowItemsOrder addObjectsFromArray:@[
                                                      @(kAPHDashboardItemTypeSevenDayFitness),
                                                      @(kAPHDashboardItemTypeWalkingTest),
                                                      @(kAPHDashboardItemTypeWalkingTestComparison),
                                                      @(kAPHDashboardItemTypeDailyInsights)
                                                     ]
                ];
            } else {
                [_rowItemsOrder addObjectsFromArray:@[
                                                      @(kAPHDashboardItemTypeWalkingTest),
                                                      @(kAPHDashboardItemTypeDailyInsights)
                                                     ]
                ];
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
    
    self.dailyInsights = [[APHDailyInsights alloc] initInsight];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    APHAppDelegate *appDelegate = (APHAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.allocationDataset = [appDelegate.sevenDayFitnessAllocationData weeksAllocation];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.rowItemsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kAPCDashboardRowItemsOrder]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dailyInsightNotification:)
                                                 name:kAPHDailyInsightDataCollectionIsCompleteNotification
                                               object:nil];
    
    [self prepareData];
    
    [self.dailyInsights gatherInsights];
    
    self.pieGraphDataExists = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.pieGraphDataExists = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Data

- (void)dailyInsightNotification:(NSNotification *) __unused notification
{
    [self prepareData];
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
                    if (self.walkingResults)
                    {
                        self.walkingResults = nil;
                    }
                    
                    self.walkingResults = [APHWalkingTestResults new];
                    
                    APHTableViewDashboardWalkingTestItem *item = nil;
                    
                    if (self.walkingResults.results.count)
                    {
                        item            = [self.walkingResults.results firstObject];
                        item.caption    = NSLocalizedString(@"6-Minute Walk Test", nil);
                        item.taskId     = kFitnessTestTaskId;
                        item.identifier = kAPHDashboardWalkTestTableViewCellIdentifier;
                        item.tintColor  = [UIColor colorForTaskId:item.taskId];
                        item.editable   = YES;
                        item.info       = NSLocalizedString(@"This shows the distance you have walked in 6 minutes, which is a simple measure of fitness. We are also implementing a feature to give you the typical distance expected for your age, gender, height, and weight. You can also view a log of your prior data. Heart rate data are made available if you were using a wearable device capable of recording heart rate while walking.", nil);
                        
                        APCTableViewRow* row = [APCTableViewRow new];
                        
                        row.item        = item;
                        row.itemType    = rowType;
                        
                        [rowItems addObject:row];
                    }
                }
                    break;
                    
                case kAPHDashboardItemTypeWalkingTestComparison:
                {
                    if (self.walkingResults)
                    {
                        self.walkingResults = nil;
                    }
                    
                    self.walkingResults = [APHWalkingTestResults new];
                    
                    if (self.walkingResults.results.count)
                    {
                        APHTableViewDashboardWalkingTestComparisonItem *item = [APHTableViewDashboardWalkingTestComparisonItem new];
                        APHTableViewDashboardWalkingTestItem *walkingTestItem = [self.walkingResults.results firstObject];
                        
                        item.caption    = NSLocalizedString(@"6-Minute Walk Test Comparison", nil);
                        item.taskId     = kFitnessTestTaskId;
                        item.identifier = kAPHDashboardWalkTestComparisonTableViewCellIdentifier;
                        item.tintColor  = [UIColor colorForTaskId:item.taskId];
                        item.editable   = YES;
                        item.info       = NSLocalizedString(@"This graph shows a comparison between your latest performance on the 6-Minute Walk Test and the population distribution.  The x-axis shows the distance walked during the test, the y-axis shows the percent of the population that walked each distance.", nil);
                        item.distanceWalked = walkingTestItem.distanceWalked;
                        APCTableViewRow* row = [APCTableViewRow new];
                        
                        row.item        = item;
                        row.itemType    = rowType;
                        
                        [rowItems addObject:row];
                    }
                }
                    break;
                    
                case kAPHDashboardItemTypeDailyInsights:
                {
                    // Header
                    {
                        APHTableViewDashboardDailyInsightItem *headerItem = [APHTableViewDashboardDailyInsightItem new];
                        
                        headerItem.identifier = kAPHDashboardDailyInsightHeaderCellIdentifier;
                        headerItem.tintColor = [UIColor appTertiaryGreenColor];
                        headerItem.editable = NO;
                        
                        APCTableViewRow *row = [APCTableViewRow new];
                        row.item = headerItem;
                        row.itemType = rowType;
                        [rowItems addObject:row];
                    }
                    
                    // Insight Items
                    {
                        for (APHDailyInsight *dailyInsight in self.dailyInsights.collectedDailyInsights) {
                            
                            //    NSDictionary *insight = @{
                            //                              kDailyInsightCaptionKey: smokingInsight,
                            //                              kDailyInsightIconKey: [UIImage imageNamed:@"insight_smoking"],
                            //                              kDailyInsightSubCaptionKey: NSLocalizedString(@"Optimal: No Smoking", nil)
                            //                             };
                            
                            
                            
                            APHTableViewDashboardDailyInsightItem *item = [APHTableViewDashboardDailyInsightItem new];
                            
                            item.identifier = kAPHDashboardDailyInsightCellIdentifier;
                            item.tintColor = [UIColor appTertiaryGreenColor];
                            item.editable = NO;
                            
                            item.insightAttributedTitle = dailyInsight.dailyInsightCaption;
                            item.insightSubtitle = dailyInsight.dailyInsightSubCaption;
                            item.insightImage = [UIImage imageNamed:dailyInsight.iconName];
                            
                            item.info = NSLocalizedString(@"Put something for Daily Insights", nil);
                            
                            APCTableViewRow *row = [APCTableViewRow new];
                            row.item = item;
                            row.itemType = rowType;
                            [rowItems addObject:row];
                        }
                    }
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
        
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardWalkingTestComparisonItem class]]){
        
        APHTableViewDashboardWalkingTestComparisonItem *walkingTestComparisonItem = (APHTableViewDashboardWalkingTestComparisonItem *)dashboardItem;
        
        APHDashboardWalkTestComparisonTableViewCell *walkingTestComparisonCell = (APHDashboardWalkTestComparisonTableViewCell *)cell;
        
        APCNormalDistributionGraphView *graphView = (APCNormalDistributionGraphView *)walkingTestComparisonCell.normalDistributionGraphView;
        graphView.datasource = walkingTestComparisonItem.comparisonObject;
        graphView.delegate = self;
        graphView.tintColor = walkingTestComparisonItem.tintColor;
        graphView.panGestureRecognizer.delegate = self;
        graphView.axisTitleFont = [UIFont appRegularFontWithSize:14.0f];
        
        CGFloat zScore = [walkingTestComparisonItem.comparisonObject zScoreForDistanceWalked:walkingTestComparisonItem.distanceWalked];
        CGFloat myScore = [walkingTestComparisonItem.comparisonObject distancePercentForZScore:zScore];
        graphView.value = myScore;
        
        walkingTestComparisonCell.textLabel.text = @"";
        walkingTestComparisonCell.title = walkingTestComparisonItem.caption;
        
        NSString *text = NSLocalizedString(@"You vs Others", nil);
        
        NSMutableAttributedString *attirbutedString = [[NSMutableAttributedString alloc] initWithString:text];
        [attirbutedString addAttribute:NSForegroundColorAttributeName value:[UIColor appTertiaryRedColor] range:[text rangeOfString:@"You"]];
        [attirbutedString addAttribute:NSForegroundColorAttributeName value:[UIColor appSecondaryColor2] range:[text rangeOfString:@"vs"]];
        [attirbutedString addAttribute:NSForegroundColorAttributeName value:walkingTestComparisonItem.tintColor range:[text rangeOfString:@"Others"]];
        
        walkingTestComparisonCell.subtitleLabel.attributedText = attirbutedString;
        
        NSLengthFormatter* lengthFormatter = [NSLengthFormatter new];
        NSString* distanceWalkedString = [lengthFormatter unitStringFromValue:(double)walkingTestComparisonItem.distanceWalked
                                                               unit:NSLengthFormatterUnitYard];
        
        walkingTestComparisonCell.distanceLabel.text = [NSString stringWithFormat:@"%@", distanceWalkedString];
        
        walkingTestComparisonCell.tintColor = walkingTestComparisonItem.tintColor;
        walkingTestComparisonCell.delegate = self;
        
        [graphView layoutSubviews];
        
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardDailyInsightItem class]]) {
        APHTableViewDashboardDailyInsightItem *dailyInsight = (APHTableViewDashboardDailyInsightItem *)dashboardItem;
        APHCardioInsightCell *dailyInsightCell = (APHCardioInsightCell *)cell;
        
        dailyInsightCell.tintColor = dailyInsight.tintColor;
        dailyInsightCell.delegate = self;
        
        if ([dashboardItem.identifier isEqualToString:kAPHDashboardDailyInsightCellIdentifier]) {
            dailyInsightCell.cellAttributedTitle = dailyInsight.insightAttributedTitle;
            dailyInsightCell.cellSubtitle = dailyInsight.insightSubtitle;
            dailyInsightCell.cellImage = dailyInsight.insightImage;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    APCTableViewItem *dashboardItem = [self itemForIndexPath:indexPath];
    
    if ([dashboardItem isKindOfClass:[APHTableViewDashboardFitnessControlItem class]]){
        height = kFitnessControlRowHeight;
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardWalkingTestItem class]]) {
        height = kWalkingTestRowHeight;
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardWalkingTestComparisonItem class]]) {
        height = kWalkingTestComparisonRowHeight;
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardSevenDayFitnessItem class]]) {
        height = kSevenDayFitnessRowHeight;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    APCTableViewItem *dashboardItem = [self itemForIndexPath:indexPath];
    
    if ([dashboardItem isKindOfClass:[APHTableViewDashboardWalkingTestComparisonItem class]]){        
        APHDashboardWalkTestComparisonTableViewCell *walkingTestComparisonCell = (APHDashboardWalkTestComparisonTableViewCell *)cell;
        
        APCNormalDistributionGraphView *graphView = (APCNormalDistributionGraphView *)walkingTestComparisonCell.normalDistributionGraphView;
        
        [graphView setNeedsLayout];
        [graphView layoutIfNeeded];
        [graphView refreshGraph];
    }
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
    } else if ([cell isKindOfClass:[APHDashboardWalkTestComparisonTableViewCell class]]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        APHTableViewDashboardWalkingTestComparisonItem *item = (APHTableViewDashboardWalkingTestComparisonItem *)[self itemForIndexPath:indexPath];
        
        APHWalkingTestComparisonViewController *walkTestComparisonViewController = [[UIStoryboard storyboardWithName:kDashBoardStoryBoardKey bundle:nil] instantiateViewControllerWithIdentifier:@"APHWalkingTestComparisonViewController"];
        walkTestComparisonViewController.comparisonItem = item;
        
        [self.navigationController presentViewController:walkTestComparisonViewController animated:YES completion:nil];
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

