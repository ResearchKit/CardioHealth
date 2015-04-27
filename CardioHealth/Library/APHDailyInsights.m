//
//  APHDailyInsights.m
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

#import "APHDailyInsights.h"

NSString *const kHeartAgeTaskId   = @"2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";
NSString *const kDietSurveyTaskId = @"4-DietSurvey-1E174061-5B02-11E4-8ED6-0800200C9A66";

NSString *const kHeartAgeDataLdlKey                    = @"heartAgeDataLdl";
NSString *const kHeartAgeDataEthnicityKey              = @"heartAgeDataEthnicity";
NSString *const kHeartAgeDataBloodGlucoseKey           = @"heartAgeDataBloodGlucose";
NSString *const kHeartAgeDataSystolicBloodPressureKey  = @"heartAgeDataSystolicBloodPressure";
NSString *const kHeartAgeDataTotalCholesterolKey       = @"heartAgeDataTotalCholesterol";
NSString *const kHeartAgeDataDiabetesKey               = @"heartAgeDataDiabetes";
NSString *const kHeartAgeDataDiastolicBloodPressureKey = @"heartAgeDataDiastolicBloodPressure";
NSString *const kHeartAgeDataHypertensionKey           = @"heartAgeDataHypertension";
NSString *const kHeartAgeDataAgeKey                    = @"heartAgeDataAge";
NSString *const kHeartAgeDataGenderKey                 = @"heartAgeDataGender";
NSString *const kHeartAgeSmokingHistoryKey             = @"smokingHistory";
NSString *const kHeartAgeDataHdlKey                    = @"heartAgeDataHdl";

NSString *const kDietSurveyGrainsKey      = @"grains";
NSString *const kDietSurveySugarDrinksKey = @"sugar_drinks";
NSString *const kDietSurveySodiumKey      = @"sodium";
NSString *const kDietSurveyVegetableKey   = @"vegetable";
NSString *const kDietSurveyFruitKey       = @"fruit";
NSString *const kDietSurveyFishKey        = @"fish";

NSString *const kAPHDailyInsightDataCollectionIsCompleteNotification = @"APHDailyInsightDataCollectionIsCompleteNotification";

static NSAttributedString *kResultsNotFound = nil;
static NSInteger kNumberOfDaysForLookup = -90; // Going back 90 days from current date.

typedef NS_ENUM(NSUInteger, APHDailyInsightIdentifiers)
{
    APHDailyInsightIdentifierSmoking = 0,
    APHDailyInsightIdentifierWeight,
    APHDailyInsightIdentifierActivity,
    APHDailyInsightIdentifierDiet,
    APHDailyInsightIdentifierBloodPressure,
    APHDailyInsightIdentifierCholesterol,
    APHDailyInsightIdentifierBloodSugar,
    APHDailyInsightIdentifierTotalNumberOfInsights
};

@interface APHDailyInsights()

@property (nonatomic, strong) NSMutableArray *collectedInsights;

@property (nonatomic, strong) UIColor *dailyInsightGoodColor;
@property (nonatomic, strong) UIColor *dailyInsightNeedsImprovementColor;
@property (nonatomic, strong) UIColor *dailyInsightBadColor;

@property (nonatomic, strong) NSDictionary *heartAgeResults;
@property (nonatomic, strong) NSDictionary *dietSurveyResults;

@property (nonatomic, strong) NSOperationQueue *dailyInsightQueue;

@property (nonatomic, strong) NSMutableArray *queueItems;

@property (nonatomic) double heightInInches;
@property (nonatomic) double weightInPounds;

@end

@implementation APHDailyInsights

- (void)sharedInit
{
    _dailyInsightGoodColor = [UIColor appTertiaryGreenColor];
    _dailyInsightNeedsImprovementColor = [UIColor appTertiaryYellowColor];
    _dailyInsightBadColor = [UIColor appTertiaryRedColor];
    
    _heightInInches = [((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser.height doubleValueForUnit:[HKUnit inchUnit]];
    _weightInPounds = [((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser.weight doubleValueForUnit:[HKUnit poundUnit]];
    
    _dailyInsightQueue = [NSOperationQueue sequentialOperationQueueWithName:@"Daily Insight Queue"];
    
    _heartAgeResults = nil;
    _dietSurveyResults = nil;
    
    kResultsNotFound = [self attributedStringFromString:NSLocalizedString(@"Results not available.", nil)
                                              withColor:[UIColor blackColor]];
    
    _collectedInsights = [NSMutableArray new];
    
    _queueItems = [NSMutableArray new];
}

- (instancetype)initInsight
{
    self = [super init];
    
    if (self) {
        [self sharedInit];
    }
    
    return self;
}

- (void)queueInsightItems
{
    [self.queueItems addObjectsFromArray:@[
                                       @(APHDailyInsightIdentifierSmoking),
                                       @(APHDailyInsightIdentifierWeight),
                                       @(APHDailyInsightIdentifierActivity),
                                       @(APHDailyInsightIdentifierDiet),
                                       @(APHDailyInsightIdentifierBloodPressure),
                                       @(APHDailyInsightIdentifierCholesterol),
                                       @(APHDailyInsightIdentifierBloodSugar)
                                       ]];
}

- (void)gatherInsights
{
    [self.collectedInsights removeAllObjects];
    [self queueInsightItems];
    [self fetchInsightsForQueuedItems];
}

- (void)fetchInsightsForQueuedItems
{
    APCLogDebug(@"Fetching insight entry point...");
    
    BOOL hasItemsQueued = self.queueItems.count > 0;
    
    if (hasItemsQueued) {
        APCLogDebug(@"About to queue insight item...");
        
        NSNumber *insightItem = [self.queueItems firstObject];
        [self.queueItems removeObjectAtIndex:0];
        
        APCLogDebug(@"We are about to collect data for the insight item (%@)...", insightItem);
        
        switch (insightItem.integerValue) {
            case APHDailyInsightIdentifierWeight:
                break;
            case APHDailyInsightIdentifierActivity:
                break;
            case APHDailyInsightIdentifierDiet: // Based on the Diet survey
            {
                if (!self.dietSurveyResults) {
                    self.dietSurveyResults = [self retrieveDataForTask:kDietSurveyTaskId];
                }
            }
                break;
            default: // All other insights are pulled from the Heart Age survey.
            {
                if (!self.heartAgeResults) {
                    self.heartAgeResults = [self retrieveDataForTask:kHeartAgeTaskId];
                }
            }
                break;
        }
        
        [self generateInsightForIdentifier:insightItem.integerValue];
        
        [self fetchInsightsForQueuedItems];
    } else {
        APCLogDebug(@"We're done!");
        
        self.collectedDailyInsights = [self.collectedInsights copy];
        
        // Post the notification that all data collection and processing is done.
        [[NSNotificationCenter defaultCenter] postNotificationName:kAPHDailyInsightDataCollectionIsCompleteNotification
                                                            object:nil];
    }
}

- (void)refresh:(APHDailyInsightIdentifiers)identifier
{
    [self generateInsightForIdentifier:identifier];
}

- (void)generateInsightForIdentifier:(APHDailyInsightIdentifiers)identifier
{
    switch (identifier) {
        case APHDailyInsightIdentifierSmoking:
            [self insightForSmoking];
            break;
        case APHDailyInsightIdentifierWeight:
            [self insightForWeight];
            break;
        case APHDailyInsightIdentifierActivity:
            [self insightForActivity];
            break;
        case APHDailyInsightIdentifierDiet:
            [self insightForDiet];
            break;
        case APHDailyInsightIdentifierCholesterol:
            [self insightForCholesterol];
            break;
        case APHDailyInsightIdentifierBloodPressure:
            [self insightForBloodPressure];
            break;
        case APHDailyInsightIdentifierBloodSugar:
            [self insightForBloodSugar];
            break;
        default:
            break;
    }
}

#pragma mark - Gather data

- (NSDictionary *)retrieveDataForTask:(NSString *)taskId
{
    APCScoring *surveyResults = [[APCScoring alloc] initWithTask:taskId
                                                    numberOfDays:kNumberOfDaysForLookup
                                                        valueKey:@"value"
                                                         dataKey:nil
                                                         sortKey:nil
                                                         groupBy:APHTimelineGroupForInsights];
    
    NSDictionary *latestSurveyResults = [self latestResultsFromTask:surveyResults.allObjects];
    
    return latestSurveyResults;
}

- (NSDictionary *)latestResultsFromTask:(NSArray *)dataset
{
    NSDictionary *latestResults = nil;
    NSSortDescriptor *sortByDateDesending = [[NSSortDescriptor alloc] initWithKey:kDatasetDateKey ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K in SELF", @"raw"];
    
    [dataset sortedArrayUsingDescriptors:@[sortByDateDesending]];
    
    NSArray *rawData = [dataset filteredArrayUsingPredicate:predicate];
    
    if (rawData.count > 0) {
        latestResults = [rawData firstObject][@"raw"];
    }
    
    return latestResults;
}

#pragma mark - Compute Insights

- (void)insightForSmoking
{
    NSAttributedString *smokingInsight = kResultsNotFound;
    
    if (self.heartAgeResults) {
        if (self.heartAgeResults[kHeartAgeSmokingHistoryKey]) {
            smokingInsight = [self attributedStringFromString:NSLocalizedString(@"Does not smoke currently", nil)
                                                    withColor:self.dailyInsightGoodColor];
        } else {
            smokingInsight = [self attributedStringFromString:NSLocalizedString(@"Currently smokes", nil)
                                                    withColor:self.dailyInsightBadColor];
        }
    }
    
    APCLogDebug(@"Smoking insight.");
    
    [self.collectedInsights addObject:smokingInsight];
}

- (void)insightForWeight
{
    NSAttributedString *weightInsight = kResultsNotFound;
    
    if ((self.weightInPounds > 0) && (self.heightInInches > 0)) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setRoundingMode:NSNumberFormatterRoundDown];
        [formatter setMaximumFractionDigits:0];
        
        double bmi = (self.weightInPounds / pow(self.heightInInches, 2)) * 703;
        
        NSString *weightCaption = [NSString stringWithFormat:@"%@ pounds (BMI %@)",
                                   [formatter stringFromNumber:@(self.weightInPounds)],
                                   [formatter stringFromNumber:@(bmi)]];
        if ((bmi >= 18.5) && (bmi <= 25.0)) {
            weightInsight = [self attributedStringFromString:NSLocalizedString(weightCaption, nil)
                                                   withColor:self.dailyInsightGoodColor];
        } else if (bmi > 25.0) {
            weightInsight = [self attributedStringFromString:NSLocalizedString(weightCaption, nil)
                                                   withColor:self.dailyInsightNeedsImprovementColor];
        } else {
            weightInsight = [self attributedStringFromString:NSLocalizedString(weightCaption, nil)
                                                   withColor:self.dailyInsightBadColor];
        }
    }
    
    APCLogDebug(@"Weight insight.");
    [self.collectedInsights addObject:weightInsight];
}

- (void)insightForActivity
{
    NSAttributedString *activityInsight = kResultsNotFound;
    APCAppDelegate *appDelegate = (APCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundUp];
    [formatter setMaximumFractionDigits:0];
    
    double activeMinutes = appDelegate.sevenDayFitnessAllocationData.activeSeconds/60;
    
    if (activeMinutes > 0) {
        NSString *activeMinutesCaption = [NSString stringWithFormat:@"%@ Active Minutes", [formatter stringFromNumber:@(activeMinutes)]];
        
        if (activeMinutes >= 150) {
            activityInsight = [self attributedStringFromString:activeMinutesCaption withColor:self.dailyInsightGoodColor];
        } else if ((activeMinutes > 112) && (activeMinutes < 150)) {
            activityInsight = [self attributedStringFromString:activeMinutesCaption withColor:self.dailyInsightNeedsImprovementColor];
        } else {
            activityInsight = [self attributedStringFromString:activeMinutesCaption withColor:self.dailyInsightBadColor];
        }
    }
    
    APCLogDebug(@"Activity insight.");
    [self.collectedInsights addObject:activityInsight];
}

- (void)insightForDiet
{
    NSAttributedString *dietInsight = kResultsNotFound;
    
    if (self.dietSurveyResults) {
        
    }
    
    APCLogDebug(@"Diet insight.");
    [self.collectedInsights addObject:dietInsight];
}

- (void)insightForBloodPressure
{
    NSAttributedString *bloodPressureInsight = kResultsNotFound;
    
    if (self.heartAgeResults) {
        NSNumber *systolicValue = self.heartAgeResults[kHeartAgeDataSystolicBloodPressureKey];
        NSNumber *diastolicValue = self.heartAgeResults[kHeartAgeDataDiastolicBloodPressureKey];
        
        NSString *bloodPressureReading = [NSString stringWithFormat:@"%lu/%lu mm Hg blood pressure",
                                          systolicValue.integerValue, diastolicValue.integerValue];
        NSString *bloodPressureCaption = NSLocalizedString(bloodPressureReading, nil);
        
        NSRange systolicRangeNeedsImprovement = NSMakeRange(120, 9);
        NSRange diastolicRangeNeedsImprovement = NSMakeRange(80, 9);
        
        if ((systolicValue.integerValue < 120) && (diastolicValue.integerValue < 80)) {
            bloodPressureInsight = [self attributedStringFromString:bloodPressureCaption
                                                          withColor:self.dailyInsightGoodColor];
        } else if ((NSLocationInRange(systolicValue.integerValue, systolicRangeNeedsImprovement))
                   && (NSLocationInRange(diastolicValue.integerValue, diastolicRangeNeedsImprovement))) {
            bloodPressureInsight = [self attributedStringFromString:bloodPressureCaption
                                                          withColor:self.dailyInsightNeedsImprovementColor];
        } else if ((systolicValue.integerValue >= 140) && (diastolicValue.integerValue >= 90)) {
            bloodPressureInsight = [self attributedStringFromString:bloodPressureCaption
                                                          withColor:self.dailyInsightBadColor];
        }
    }
    
    APCLogDebug(@"Blood Pressure insight.");
    [self.collectedInsights addObject:bloodPressureInsight];
}

- (void)insightForCholesterol
{
    NSAttributedString *cholesterolInsight = kResultsNotFound;
    
    if (self.heartAgeResults) {
        NSNumber *bloodCholesterolValue = self.heartAgeResults[kHeartAgeDataTotalCholesterolKey];
        NSString *cholesterolReading = [NSString stringWithFormat:@"%lu md/dL blood cholesterol", bloodCholesterolValue.integerValue];
        NSString *cholesterolCaption = NSLocalizedString(cholesterolReading, nil);
        
        if (bloodCholesterolValue.integerValue < 200) {
            cholesterolInsight = [self attributedStringFromString:cholesterolCaption
                                                        withColor:self.dailyInsightGoodColor];
        } else if ((bloodCholesterolValue.integerValue >= 200) && (bloodCholesterolValue.integerValue <= 250)) {
            cholesterolInsight = [self attributedStringFromString:cholesterolCaption
                                                        withColor:self.dailyInsightNeedsImprovementColor];
        } else if (bloodCholesterolValue.integerValue > 250) {
            cholesterolInsight = [self attributedStringFromString:cholesterolCaption
                                                        withColor:self.dailyInsightBadColor];
        }
    }
    
    APCLogDebug(@"Cholesterol insight.");
    [self.collectedInsights addObject:cholesterolInsight];
}

- (void)insightForBloodSugar
{
    NSAttributedString *bloodSugarInsight = kResultsNotFound;
    
    if (self.heartAgeResults) {
        NSNumber *bloodSugarValue = self.heartAgeResults[kHeartAgeDataBloodGlucoseKey];
        
        if (bloodSugarValue.integerValue > 0) {
            NSString *bloodSugarReading = [NSString stringWithFormat:@"%lu md/dL blood sugar", bloodSugarValue.integerValue];
            NSString *bloodSugarCaption = NSLocalizedString(bloodSugarReading, nil);
            
            if (bloodSugarValue.integerValue < 100) {
                bloodSugarInsight = [self attributedStringFromString:bloodSugarCaption
                                                           withColor:self.dailyInsightGoodColor];
            } else if ((bloodSugarValue.integerValue >= 100) && (bloodSugarValue.integerValue <= 125)) {
                bloodSugarInsight = [self attributedStringFromString:bloodSugarCaption
                                                           withColor:self.dailyInsightNeedsImprovementColor];
            } else if (bloodSugarValue.integerValue > 125) {
                bloodSugarInsight = [self attributedStringFromString:bloodSugarCaption
                                                           withColor:self.dailyInsightBadColor];
            }
        }
    }
    
    APCLogDebug(@"Blood Sugar insight.");
    [self.collectedInsights addObject:bloodSugarInsight];
}

#pragma mark - Helpers

- (NSAttributedString *)attributedStringFromString:(NSString *)text withColor:(UIColor *)color
{
    NSDictionary *attributes = @{NSForegroundColorAttributeName: color};
    
    NSAttributedString *coloredString = [[NSAttributedString alloc] initWithString:text
                                                                        attributes:attributes];
    
    return coloredString;
}

@end



















