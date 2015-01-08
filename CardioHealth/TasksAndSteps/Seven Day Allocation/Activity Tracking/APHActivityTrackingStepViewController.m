//
//  APHActivityTrackingStepViewController.m
//  MyHeartCounts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import "APHActivityTrackingStepViewController.h"
#import "APHAppDelegate.h"
#import "APHFitnessAllocation.h"

static CGFloat metersPerMile = 1609.344;

@interface APHActivityTrackingStepViewController () <APCPieGraphViewDatasource>

@property (weak, nonatomic) IBOutlet UILabel *daysRemaining;
@property (weak, nonatomic) IBOutlet APCPieGraphView *chartView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentDays;

@property (nonatomic, strong) NSArray *allocationDataset;

@property (nonatomic) BOOL showTodaysDataAtViewLoad;
@property (nonatomic) NSInteger numberOfDaysOfFitnessWeek;

@end

@implementation APHActivityTrackingStepViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.daysRemaining.text = [self fitnessDaysRemaining];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(handleClose:)];
    
    self.view.layer.backgroundColor = [UIColor colorWithWhite:0.973 alpha:1.000].CGColor;
    
    self.segmentDays.tintColor = [UIColor clearColor];
    [self.segmentDays setTitleTextAttributes:@{
                                               NSFontAttributeName:[UIFont appRegularFontWithSize:19.0f],
                                               NSForegroundColorAttributeName : [UIColor lightGrayColor]
                                               }
                                    forState:UIControlStateNormal];
    [self.segmentDays setTitleTextAttributes:@{
                                               NSFontAttributeName:[UIFont appMediumFontWithSize:19.0f],
                                               NSForegroundColorAttributeName : [UIColor blackColor]
                                               }
                                    forState:UIControlStateSelected];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(datasetDidUpdate:)
                                                 name:APHSevenDayAllocationDataIsReadyNotification object:nil];
    
    self.showTodaysDataAtViewLoad = YES;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    
    self.chartView.datasource = self;
    self.chartView.legendPaddingHeight = 60.0;
    self.chartView.shouldAnimate = YES;
    self.chartView.shouldAnimateLegend = NO;
    self.chartView.titleLabel.text = NSLocalizedString(@"Distance", @"Distance");
    
    if (self.showTodaysDataAtViewLoad) {
        [self handleDays:self.segmentDays];
        self.showTodaysDataAtViewLoad = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APHSevenDayAllocationDataIsReadyNotification
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)handleDays:(UISegmentedControl *)sender
{
    APHAppDelegate *appDelegate = (APHAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.allocationDataset = [appDelegate.sevenDayFitnessAllocationData yesterdaysAllocation];
            break;
        case 1:
            self.allocationDataset = [appDelegate.sevenDayFitnessAllocationData todaysAllocation];
            break;
        default:
            self.allocationDataset = [appDelegate.sevenDayFitnessAllocationData weeksAllocation];
            break;
    }
    
    [self datasetDidUpdate:nil];
}

- (void)handleClose:(UIBarButtonItem *)sender
{
    if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
        [self.delegate stepViewControllerDidFinish:self navigationDirection:RKSTStepViewControllerNavigationDirectionForward];
    }
}

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
    
    // Disable Yesterday and Week segments when start date is today
    BOOL startDateIsToday = [startDate isEqualToDate:today];
    [self.segmentDays setEnabled:!startDateIsToday forSegmentAtIndex:0];
    [self.segmentDays setEnabled:!startDateIsToday forSegmentAtIndex:2];
    
    // Compute the remaing days of the 7 day fitness allocation.
    NSDateComponents *numberOfDaysFromStartDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                                  fromDate:startDate
                                                                                    toDate:today
                                                                                   options:NSCalendarWrapComponents];
    self.numberOfDaysOfFitnessWeek = numberOfDaysFromStartDate.day;
    
    NSUInteger daysRemain = 0;
    
    if (self.numberOfDaysOfFitnessWeek < 7) {
        daysRemain = 7 - self.numberOfDaysOfFitnessWeek;
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
        fitnessStartDate = [NSDate date];
        [self saveSevenDayFitnessStartDate:fitnessStartDate];
        
        APHAppDelegate *appDelegate = (APHAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.sevenDayFitnessAllocationData = [[APHFitnessAllocation alloc] initWithAllocationStartDate:fitnessStartDate];
        [appDelegate.sevenDayFitnessAllocationData startDataCollection];
    }
    
    return fitnessStartDate;
}

- (void)saveSevenDayFitnessStartDate:(NSDate *)startDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:startDate forKey:kSevenDayFitnessStartDateKey];
    
    [defaults synchronize];
}

#pragma mark - Fitness Allocation Delegate

- (void)datasetDidUpdate:(NSNotification *)notif
{
    APHAppDelegate *appDelegate = (APHAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGFloat totalDistance = [[appDelegate.sevenDayFitnessAllocationData totalDistanceForDays:0] floatValue];
    
    self.chartView.valueLabel.text = [NSString stringWithFormat:@"%0.1f mi", totalDistance/metersPerMile];
    
    [self.chartView layoutSubviews];
}

#pragma mark - PieGraphView Delegates

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
