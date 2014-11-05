//
//  YMLScoring.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 10/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHScoring.h"
#import "APHDataPoint.h"

@interface APHScoring()

@property (nonatomic, strong) NSMutableArray *dataPoints;
@property (nonatomic, strong) NSMutableArray *correlateDataPoints;
@property (nonatomic) NSUInteger current;
@property (nonatomic) NSUInteger correlatedCurrent;
@property (nonatomic) BOOL hasCorrelateDataPoints;

@end

@implementation APHScoring

/**
 * @brief   Returns an instance of YMLScoring.
 *
 * @param   kind            One of the YMLScoreDataKinds enums choices
 *
 * @param   numberOfDays    Number of days that the data is needed.
 *
 * @note    This is the designated initializer for this class.
 *
 */

/*
 * @usage  Both YMLScoring.h and YMLDataPoint.h should be imported.
 *
 *   YMLScoring *scoring = [[YMLScoring alloc] initWithKind:YMLDataKindWalk numberOfDays:10 correlateWithKind:YMLDataKindNone];
 *
 *   NSLog(@"Score Min: %f", [[scoring minimumDataPoint] doubleValue]);
 *   NSLog(@"Score Max: %f", [[scoring maximumDataPoint] doubleValue]);
 *   NSLog(@"Score Avg: %f", [[scoring averageDataPoint] doubleValue]);
 *
 *   YMLDataPoint *score = nil;
 *   while (score = [scoring nextObject]) {
 *       NSLog(@"Score: %f", [score.value doubleValue]);
 *   }
 */
- (instancetype)initWithKind:(NSUInteger)kind numberOfDays:(NSUInteger)numberOfDays correlateWithKind:(NSUInteger)correlateKind
{
    self = [super init];
    
    if (self) {
        _dataPoints = [NSMutableArray array];
        _correlateDataPoints = [NSMutableArray array];
        _hasCorrelateDataPoints = (correlateKind != APHDataKindNone);
        
        [self generateDataPointsForKind:kind numberOfDays:numberOfDays correlateWithKind:correlateKind];
    }
    
    return self;
}

- (void)generateDataPointsForKind:(NSUInteger)kind numberOfDays:(NSUInteger)numberOfDays correlateWithKind:(NSUInteger)correlateKind
{
    // The intent is that we will check the datastore first to see if
    // the task in question has any data. If so, we will pull that from the
    // datastore. Otherwise, for testing/dev purpose we will generate the requested
    // data.
    [self fakeDataForKind:kind numberOfDays:numberOfDays correlateWithKind:correlateKind];
}


/*
 * Commenting out the below method until the proper startegy can be worked out as to how best
 * to get at the data that is being persisted using CoreData. When uncommenting, don't forget to
 * import CoreData.
 */
//- (void)dataPointsFromDataStoreForTask:(NSString *)taskUUID kind:(NSUInteger)kind numberOfDays:(NSUInteger)numberOfDays
//{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"APCTask" inManagedObjectContext:<#context#>];
//    [fetchRequest setEntity:entity];
//    
//    // Specify criteria for filtering which objects to fetch
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@", <#arguments#>];
//    [fetchRequest setPredicate:predicate];
//    
//    // Specify how the fetched objects should be sorted
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"<#key#>"
//                                                                   ascending:YES];
//    
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
//
//    NSError *error = nil;
//    NSArray *fetchedObjects = [<#context#> executeFetchRequest:fetchRequest error:&error];
//    
//    if (fetchedObjects == nil) {
//        <#Error handling code#>
//    }
//}

- (void)fakeDataForKind:(NSUInteger)kind numberOfDays:(NSUInteger)numberOfDays correlateWithKind:(NSUInteger)correlateKind
{   
    self.dataPoints = [[self generateDataPointsForSpan:numberOfDays kind:kind] mutableCopy];
    
    if (self.hasCorrelateDataPoints) {
        self.correlateDataPoints = [[self generateDataPointsForSpan:numberOfDays kind:kind] mutableCopy];
    }
}

- (NSArray *)generateDataPointsForSpan:(NSUInteger)daySpan kind:(NSUInteger)kind
{
    NSMutableArray *points = [NSMutableArray array];
    
    NSNumber *maxBaseline = nil;
    NSNumber *minBaseline = nil;
    
    switch (kind) {
        case APHDataKindSystolicBloodPressure:
            maxBaseline = @120;
            minBaseline = @60;
            break;
        case APHDataKindTotalCholesterol:
            maxBaseline = @200;
            minBaseline = @50;
            break;
        case APHDataKindWalk:
            maxBaseline = @1000;
            minBaseline = @1;
            break;
        case APHDataKindHeartRate:
            maxBaseline = @100;
            minBaseline = @60;
        case APHDataKindHDL:
            maxBaseline = @60;
            minBaseline = @40;
        default:
            NSAssert(YES, @"Data kind is not implemented.");
            break;
    }
    
    for (NSInteger day = 1; day <= daySpan; day++) {
        NSDate *span = [self dateForSpan:-(daySpan - day)];
        NSInteger point = arc4random() % ([maxBaseline integerValue] - [minBaseline integerValue] + 1) + [minBaseline integerValue];
        APHDataPoint *dp = [[APHDataPoint alloc] initWithValue:[NSNumber numberWithInteger:point] timestamp:span];
        [points addObject:dp];
    }
    
    return points;
}

/**
 * @brief   Returns an NSDate that is past/future by the value of daySpan.
 *
 * @param   daySpan Number of days relative to current date.
 *                  If negative, date will be number of days in the past;
 *                  otherwise the date will be number of days in the future.
 *
 * @return  Returns the date as NSDate.
 */
- (NSDate *)dateForSpan:(NSInteger)daySpan
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daySpan];
    
    NSDate *spanDate = [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                                     toDate:[NSDate date]
                                                                    options:0];
    return spanDate;
}


- (NSNumber *)minimumDataPoint
{
    return [self.dataPoints valueForKeyPath:@"@min.value"];
}

- (NSNumber *)maximumDataPoint
{
    return [self.dataPoints valueForKeyPath:@"@max.value"];
}

- (NSNumber *)averageDataPoint
{
    return [self.dataPoints valueForKeyPath:@"@avg.value"];
}

- (id)nextObject
{
    id nextPoint = nil;
    
    if (self.current < [self.dataPoints count]) {
        nextPoint = [self.dataPoints objectAtIndex:self.current++];
    }
    
    return nextPoint;
}

- (id)nextCorrelatedObject
{
    id nextCorrelatedPoint = nil;
    
    if (self.correlatedCurrent < [self.correlateDataPoints count]) {
        nextCorrelatedPoint = [self.correlateDataPoints objectAtIndex:self.correlatedCurrent++];
    }
    
    return nextCorrelatedPoint;
}

#pragma mark - Graph Datasource

- (NSInteger)lineGraph:(APCLineGraphView *)graphView numberOfPointsInPlot:(NSInteger)plotIndex
{
    NSInteger numberOfPoints = 0;
    
    if (plotIndex == 0) {
        numberOfPoints = [self.dataPoints count];
    } else {
        numberOfPoints = [self.correlateDataPoints count];
    }
    
    return numberOfPoints;
}

- (NSInteger)numberOfPlotsInLineGraph:(APCLineGraphView *)graphView
{
    NSUInteger numberOfPlots = 1;
    
    if (self.hasCorrelateDataPoints) {
        numberOfPlots = 2;
    }
    return numberOfPlots;
}

- (CGFloat)minimumValueForLineGraph:(APCLineGraphView *)graphView
{
    return [[self minimumDataPoint] doubleValue];
}

- (CGFloat)maximumValueForLineGraph:(APCLineGraphView *)graphView
{
    return [[self maximumDataPoint] doubleValue];
}

- (CGFloat)lineGraph:(APCLineGraphView *)graphView plot:(NSInteger)plotIndex valueForPointAtIndex:(NSInteger)pointIndex
{
    CGFloat value;
    
    if (plotIndex == 0) {
        APHDataPoint *point = [self nextObject];
        value = [point.value doubleValue];
    } else {
        APHDataPoint *correlatedPoint = [self nextCorrelatedObject];
        value = [correlatedPoint.value doubleValue];
    }
    
    return value;
}


@end