//
//  APHWalkingTestComparison.m
//  CardioHealth
//
//  Created by Ramsundar Shandilya on 5/14/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHWalkingTestComparison.h"

@interface APHWalkingTestComparison()

@property (nonatomic) CGFloat mean;
@property (nonatomic) CGFloat standardDeviation;

@property (nonatomic) HKBiologicalSex gender;
@property (nonatomic) NSArray *zScores;

@end

@implementation APHWalkingTestComparison

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self statsFromJSONFile:@"WalkingTestStats"];
        _zScores = @[@(-3), @(-2), @(-1), @0, @1, @2, @3];
    }
    return self;
}


- (void)statsFromJSONFile:(NSString *)jsonFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    if (jsonDictionary && !parseError) {
        
        NSDictionary *stats;
        
        if ([self gender] == HKBiologicalSexFemale) {
            stats = jsonDictionary[@"6MWT_stats_female"];
        } else {
            stats = jsonDictionary[@"6MWT_stats_male"];
        }
        
        if (stats) {
            _mean = [stats[@"mean"] floatValue];
            _standardDeviation = [stats[@"sd"] floatValue];
        }
    }
}

-(HKBiologicalSex)gender
{
    _gender = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser.biologicalSex;
    return _gender;
}


- (double)computeYForZScore:(CGFloat)zScore
{
    //e^(-0.5*(zScore)^2)*(1/(157.5*sqrt(2*pi)))
    //Where zScore = (X-mean)/sd
    
    double exponent = pow(zScore, 2) * (-0.5);
    double result = pow(M_E, exponent)*(1/(self.standardDeviation * sqrt(2*M_PI)));
    
    return result;
}

- (CGFloat)zScoreForDistanceWalked:(CGFloat)distanceWalked
{
    NSInteger minZScore = [[self.zScores firstObject] integerValue];
    NSInteger maxZScore = [[self.zScores lastObject] integerValue];
    
    CGFloat zScore = (distanceWalked - self.mean)/(self.standardDeviation);
    
    zScore = MIN(MAX(zScore, minZScore), maxZScore);
    
    return zScore;
}

- (CGFloat)distancePercentForZScore:(CGFloat)zScore
{
    NSInteger minZScore = [[self.zScores firstObject] integerValue];
    NSInteger maxZScore = [[self.zScores lastObject] integerValue];
    
    CGFloat percent = (zScore - minZScore)/(maxZScore - minZScore);
    return percent;
}

- (CGFloat)xValueFromZScore:(NSInteger)zScore
{
    CGFloat xValue = zScore*self.standardDeviation + self.mean;
    
    return xValue;
    
}

- (NSString *)lineGraph:(APCLineGraphView *)graphView titleForXAxisAtIndex:(NSInteger)pointIndex
{
    CGFloat distance = [self xValueFromZScore:[self.zScores[pointIndex] integerValue]];
    
    NSString *title = [NSString stringWithFormat:@"%0.0f", distance];
    
    return title;
}

#pragma mark - APCLineCharViewDataSource

- (NSInteger)lineGraph:(APCLineGraphView *)__unused graphView numberOfPointsInPlot:(NSInteger)__unused plotIndex
{
    return [self.zScores count];
}

- (NSInteger)numberOfPlotsInLineGraph:(APCLineGraphView *)__unused graphView
{
    return 1;
}

- (CGFloat)lineGraph:(APCLineGraphView *)__unused graphView plot:(NSInteger)__unused plotIndex valueForPointAtIndex:(NSInteger)pointIndex
{
    CGFloat value;
    
    NSInteger zScore = [self.zScores[pointIndex] integerValue];
    value = [self computeYForZScore:zScore];
    
    return value;
}

@end
