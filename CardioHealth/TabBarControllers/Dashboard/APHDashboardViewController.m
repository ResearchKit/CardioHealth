// 
//  APHDashboardViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 <INSTITUTION-NAME-TBD> All rights reserved. 
// 
 
/* Controllers */
#import "APHDashboardViewController.h"
#import "APHDashboardEditViewController.h"

/* Scoring */
#import "APHScoring.h"

static NSString * const kAPCBasicTableViewCellIdentifier       = @"APCBasicTableViewCell";
static NSString * const kAPCRightDetailTableViewCellIdentifier = @"APCRightDetailTableViewCell";

@interface APHDashboardViewController ()<UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) NSMutableArray *rowItemsOrder;

@property (nonatomic, strong) APHScoring *distanceScore;
@property (nonatomic, strong) APHScoring *heartRateScore;

@property (nonatomic, strong) APCPresentAnimator *presentAnimator;

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
                                                                     @(kAPHDashboardItemTypeAlerts),
                                                                     @(kAPHDashboardItemTypeInsights)]];
            
            [defaults setObject:[NSArray arrayWithArray:_rowItemsOrder] forKey:kAPCDashboardRowItemsOrder];
            [defaults synchronize];
            
        }
        
        self.title = NSLocalizedString(@"Dashboard", @"Dashboard");
        
        _presentAnimator = [APCPresentAnimator new];
    }
    
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.distanceScore = [[APHScoring alloc] initWithKind:APHDataKindWalk
                                             numberOfDays:5
                                        correlateWithKind:APHDataKindNone];
    
    self.heartRateScore = [[APHScoring alloc] initWithKind:APHDataKindHeartRate
                                              numberOfDays:5
                                         correlateWithKind:APHDataKindNone];
    
    [self prepareData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.rowItemsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kAPCDashboardRowItemsOrder]];
    
    [self prepareData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
        section.sectionTitle = NSLocalizedString(@"Today", @"");
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
                    HKQuantityType *stepQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                    APCScoring *scoring = [[APCScoring alloc] initWithHealthKitQuantityType:stepQuantityType unit:[HKUnit countUnit] numberOfDays:-5];
                    
                    APCTableViewDashboardGraphItem *item = [APCTableViewDashboardGraphItem new];
                    item.caption = NSLocalizedString(@"Steps", @"");
                    item.graphData = scoring;
                    item.detailText = [NSString stringWithFormat:NSLocalizedString(@"Average : %lu ft", @"Average: {value} ft"), [[self.distanceScore averageDataPoint] integerValue]];
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
                    item.graphData = self.heartRateScore;
                    item.detailText = [NSString stringWithFormat:NSLocalizedString(@"Average : %lu bpm", @"Average: {value} bpm"), [[self.heartRateScore averageDataPoint] integerValue]];
                    item.identifier = kAPCDashboardGraphTableViewCellIdentifier;
                    item.editable = YES;
                    item.tintColor = [UIColor appTertiaryYellowColor];
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
                }
                    break;
                case kAPHDashboardItemTypeAlerts:{
                    
                    APCTableViewDashboardMessageItem *item = [APCTableViewDashboardMessageItem new];
                    item.identifier = kAPCDashboardMessageTableViewCellIdentifier;
                    item.messageType = kAPCDashboardMessageTypeAlert;
                    item.detailText = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
                    item.editable = YES;
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
                }
                    break;
                case kAPHDashboardItemTypeInsights:{
                    
                    APCTableViewDashboardMessageItem *item = [APCTableViewDashboardMessageItem new];
                    item.identifier = kAPCDashboardMessageTableViewCellIdentifier;
                    item.messageType = kAPCDashboardMessageTypeInsight;
                    item.detailText = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
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
        section.sectionTitle = NSLocalizedString(@"Past 5 Days", @"");
        [self.items addObject:section];
    }
    
    [self.tableView reloadData];
}

#pragma mark - APCDashboardGraphTableViewCellDelegate methods

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

@end
