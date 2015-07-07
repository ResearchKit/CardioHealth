//
//  APHWalkingTestComparison.m
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

#import "APHWalkingTestComparison.h"

@interface APHWalkingTestComparison()

@property (nonatomic) CGFloat mean;
@property (nonatomic) CGFloat standardDeviation;
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
        
        HKBiologicalSex gender = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser.biologicalSex;
        
        if (gender == HKBiologicalSexFemale) {
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

- (NSString *)lineGraph:(APCLineGraphView *) __unused graphView titleForXAxisAtIndex:(NSInteger)pointIndex
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
