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

@interface APHActivityTrackingStepViewController () <APCPieGraphViewDatasource, APHFitnessAllocationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *daysRemaining;
@property (weak, nonatomic) IBOutlet APCPieGraphView *chartView;
@property (weak, nonatomic) IBOutlet UIButton *btnToday;
@property (weak, nonatomic) IBOutlet UIButton *btnWeek;

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
    
    // Button Appearance
    [self.btnToday setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.btnToday setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    [self.btnWeek setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.btnWeek setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.showTodaysDataAtViewLoad = YES;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"7 Day Fitness Allocation", @"7 Day Fitness Allocation");
    
    self.chartView.datasource = self;
    self.chartView.legendPaddingHeight = 60.0;
    self.chartView.shouldAnimate = YES;
    self.chartView.shouldAnimateLegend = NO;
    self.chartView.titleLabel.text = NSLocalizedString(@"Distance", @"Distance");
    
    if (self.showTodaysDataAtViewLoad) {
        [self handleToday:self.btnToday];
        self.showTodaysDataAtViewLoad = NO;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)handleToday:(UIButton *)sender
{
    self.btnToday.selected = YES;
    self.btnWeek.selected = NO;
    
    [self showDataForKind:0];
}

- (IBAction)handleWeek:(UIButton *)sender
{
    self.btnToday.selected = NO;
    self.btnWeek.selected = YES;
    
    [self showDataForKind:-7];
}

- (void)showDataForKind:(NSInteger)kind
{
    APHAppDelegate *appDelegate = (APHAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.sevenDayFitnessAllocationData setDelegate:self];
    [appDelegate.sevenDayFitnessAllocationData allocationForDays:kind];
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
    // Compute the remaing days of the 7 day fitness allocation.
    NSDateComponents *numberOfDaysFromStartDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                                  fromDate:startDate
                                                                                    toDate:today
                                                                                   options:NSCalendarWrapComponents];
    self.numberOfDaysOfFitnessWeek = [numberOfDaysFromStartDate day];
    
    NSUInteger daysRemain = 7 - self.numberOfDaysOfFitnessWeek;

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

- (void)datasetDidUpdate:(NSArray *)dataset forKind:(NSInteger)kind
{
    self.allocationDataset = dataset;
    
    CGFloat totalDistance = [[self.allocationDataset valueForKeyPath:@"@sum.segmentSumKey"] floatValue];
    
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
