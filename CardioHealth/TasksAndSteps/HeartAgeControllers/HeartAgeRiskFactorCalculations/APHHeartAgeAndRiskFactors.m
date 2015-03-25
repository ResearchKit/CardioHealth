// 
//  APHHeartAgeAndRiskFactors.m 
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
 
#import "APHHeartAgeAndRiskFactors.h"

// Lookup Keys
static NSString *kLookupOptimalRiskFactors = @"optimal-risk-factors";
static NSString *kLookupOptimalRiskFactorTotalCholesterol = @"total-cholesterol";
static NSString *kLookupOptimalRiskFactorHDL = @"hdl-c";
static NSString *kLookupOptimalRiskFactorSystolicBP = @"systolic-bp";
static NSString *kLookupParameters = @"parameters";
static NSString *kLookupGenderFemale = @"Female";
static NSString *kLookupGenderMale = @"Male";
static NSString *kLookupEthnicityAfricanAmerican = @"African-American";
static NSString *kLookupEthnicityOther = @"Other";
static NSString *kLookupBaseline = @"baseline-10-year-survival";
static NSString *kLookupPopulationMean = @"population-mean";
static NSString *kLookupCoefficients = @"coefficients";
static NSString *kLookupCoefficient1 = @"coefficient-1";
static NSString *kLookupCoefficient2 = @"coefficient-2";
static NSString *kLookupCoefficient3 = @"coefficient-3";

// Lookup keys for Lifetime Risk Factors
static NSString *kLookupLifetimeRiskFactor = @"lifetime-risk-factor";
static NSString *kLifetimeRiskFactorOptimal = @"risk-factor-optimal";
static NSString *kLifetimeRiskFactorNotOptimal = @"risk-factor-not-optimal";
static NSString *kLifetimeRiskFactorElevated = @"risk-factor-elevated";
static NSString *kLifetimeRiskFactorMajor = @"risk-factor-major";
static NSString *kLifetimeRiskFactorMajorGreaterThanEqualToTwo = @"risk-factor-major-2";

// Keys for data that is collected in the survey
NSString *const kHeartAgeTestDataAge = @"heartAgeDataAge";
NSString *const kHeartAgeTestDataTotalCholesterol = @"heartAgeDataTotalCholesterol";
NSString *const kHeartAgeTestDataHDL = @"heartAgeDataHdl";
NSString *const kHeartAgeTestDataLDL = @"heartAgeDataLdl";
NSString *const kHeartAgeTestDataSystolicBloodPressure = @"heartAgeDataSystolicBloodPressure";
NSString *const kHeartAgeTestDataDiastolicBloodPressure = @"heartAgeDataDiastolicBloodPressure";
NSString *const kHeartAgeTestBloodGlucose = @"heartAgeDataBloodGlucose";
NSString *const kHeartAgeTestDataSmoke = @"heartAgeDataSmoke";
NSString *const kHeartAgeTestDataDiabetes = @"heartAgeDataDiabetes";
NSString *const kHeartAgeTestDataFamilyDiabetes = @"heartAgeDataFamilyDiabetes";
NSString *const kHeartAgeTestDataFamilyHeart = @"heartAgeDataFamilyHeart";
NSString *const kHeartAgeTestDataEthnicity = @"heartAgeDataEthnicity";
NSString *const kHeartAgeTestDataGender = @"heartAgeDataGender";
NSString *const kHeartAgeTestDataGenderFemale = @"Female";
NSString *const kHeartAgeTestDataGenderMale = @"Male";
NSString *const kHeartAgeTestDataCurrentlySmoke = @"heartAgeDataCurrentlySmoke";
NSString *const kHeartAgeTestDataHypertension = @"heartAgeDataHypertension";

// Summary data keys
NSString *const kSummaryHeartAge = @"heartAge";
NSString *const kSummaryTenYearRisk = @"tenYearRisk";
NSString *const kSummaryLifetimeRisk = @"lifetimeRisk";

@interface APHHeartAgeAndRiskFactors()

@property (nonatomic, strong) NSDictionary *heartAgeParametersLookup;

@end

@implementation APHHeartAgeAndRiskFactors

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        // Heart age lookup parameters
        _heartAgeParametersLookup = @{
                                          kLookupOptimalRiskFactors: @{
                                                  kLookupOptimalRiskFactorTotalCholesterol: @170,
                                                  kLookupOptimalRiskFactorHDL: @50,
                                                  kLookupOptimalRiskFactorSystolicBP: @110
                                                  },
                                          kLookupGenderFemale: @{
                                                  kLookupLifetimeRiskFactor: @{
                                                          kLifetimeRiskFactorOptimal: @8,
                                                          kLifetimeRiskFactorNotOptimal: @27,
                                                          kLifetimeRiskFactorElevated: @39,
                                                          kLifetimeRiskFactorMajor: @39,
                                                          kLifetimeRiskFactorMajorGreaterThanEqualToTwo: @50
                                                          },
                                                  kLookupEthnicityAfricanAmerican: @{
                                                          kLookupParameters: @{
                                                                  kLookupPopulationMean: @86.61,
                                                                  kLookupBaseline: @0.9533,
                                                                  kLookupCoefficient1: @61.5776393901894,
                                                                  kLookupCoefficient2: @6.00638641400169,
                                                                  kLookupCoefficient3: @0,
                                                                  kLookupCoefficients: @[@17.1141, @0, @0.9396, @0, @-18.9196, @4.4748,
                                                                                         @29.2907, @-6.4321, @27.8197, @-6.0873, @0.6908, @0, @0.8738]
                                                                  }
                                                          },
                                                  kLookupEthnicityOther: @{
                                                          kLookupParameters: @{
                                                                  kLookupPopulationMean: @-29.18,
                                                                  kLookupBaseline: @0.9665,
                                                                  kLookupCoefficient1: @25.6201025458129,
                                                                  kLookupCoefficient2: @-33.4729158888813,
                                                                  kLookupCoefficient3: @4.884,
                                                                  kLookupCoefficients: @[@-29.799, @4.884, @13.54, @-3.114, @-13.578, @3.149,
                                                                                           @2.019, @0, @1.957, @0, @7.574,@-1.665, @0.661]
                                                                  }
                                                          }
                                                  },
                                          kLookupGenderMale: @{
                                                  kLookupLifetimeRiskFactor: @{
                                                          kLifetimeRiskFactorOptimal: @5,
                                                          kLifetimeRiskFactorNotOptimal: @36,
                                                          kLifetimeRiskFactorElevated: @46,
                                                          kLifetimeRiskFactorMajor: @50,
                                                          kLifetimeRiskFactorMajorGreaterThanEqualToTwo: @69
                                                          },
                                                  kLookupEthnicityAfricanAmerican: @{
                                                          kLookupParameters: @{
                                                                  kLookupPopulationMean: @19.54,
                                                                  kLookupBaseline: @0.8954,
                                                                  kLookupCoefficient1: @8.85318904704122,
                                                                  kLookupCoefficient2: @2.469,
                                                                  kLookupCoefficient3: @0,
                                                                  kLookupCoefficients: @[@2.4690, @0.0000, @0.3020, @0.0000, @-0.3070,
                                                                                         @0.0000, @1.9160, @0.0000, @1.8090, @0.0000, @0.5490, @0.0000, @0.6450]
                                                                  }
                                                          },
                                                  kLookupEthnicityOther: @{
                                                          kLookupParameters: @{
                                                                  kLookupPopulationMean: @61.18,
                                                                  kLookupBaseline: @0.9144,
                                                                  kLookupCoefficient1: @37.9092024262437,
                                                                  kLookupCoefficient2: @5.58260166030049,
                                                                  kLookupCoefficient3: @0,
                                                                  kLookupCoefficients: @[@12.344, @0, @11.853, @-2.664, @-7.990, @1.769,
                                                                                         @1.797, @0, @1.764, @0, @7.837, @-1.795, @0.658]
                                                                  }
                                                          }
                                                  }
                                          };
    }
    
    return self;
}

- (NSDictionary *)calculateHeartAgeAndRiskFactors:(NSDictionary *)results
{
    NSUInteger actualAge = [results[kHeartAgeTestDataAge] integerValue];
    
    NSString *gender = results[kHeartAgeTestDataGender];
    NSString *ethnicity = results[kHeartAgeTestDataEthnicity];
    
    if ([ethnicity isEqualToString:@"Black"]) {
        ethnicity = kLookupEthnicityAfricanAmerican;
    } else {
        ethnicity = kLookupEthnicityOther;
    }
    
    // Coefficients used for computing individual sum.
    NSArray *coefficients = self.heartAgeParametersLookup[gender][ethnicity][kLookupParameters][kLookupCoefficients];
    
    double baseline = [self.heartAgeParametersLookup[gender][ethnicity][kLookupParameters][kLookupBaseline] doubleValue];
    double populationMean = [self.heartAgeParametersLookup[gender][ethnicity][kLookupParameters][kLookupPopulationMean] doubleValue];
    
    // Computing log of data that is used in multiple place for computing other coefficients.
    double logActualAge = log(actualAge);
    double logTotalCholesterol = log([results[kHeartAgeTestDataTotalCholesterol] doubleValue]);
    double logHDLC = log([results[kHeartAgeTestDataHDL] doubleValue]);
    double logTreatedSystolic = log([results[kHeartAgeTestDataSystolicBloodPressure] doubleValue]) * [results[kHeartAgeTestDataHypertension] integerValue];
    double logUnTreatedSystolic = log([results[kHeartAgeTestDataSystolicBloodPressure] doubleValue]) * (1 - [results[kHeartAgeTestDataHypertension] integerValue]);
    
    double individualSum = 0;
    
    // Looping through individual coefficients to compute the individual sum.
    for (NSUInteger idx = 0; idx < coefficients.count; idx++) {
        
        NSNumber *obj = [coefficients objectAtIndex:idx];
        double coefficientTimesValue = 0;
        
        switch (idx) {
            case 0:
                coefficientTimesValue = logActualAge * [obj doubleValue];
                break;
            case 1:
                coefficientTimesValue = pow(logActualAge, 2) * [obj doubleValue];
                break;
            case 2:
                coefficientTimesValue = logTotalCholesterol * [obj doubleValue];
                break;
            case 3:
                coefficientTimesValue = (logActualAge * logTotalCholesterol) * [obj doubleValue];
                break;
            case 4:
                coefficientTimesValue = logHDLC * [obj doubleValue];
                break;
            case 5:
                coefficientTimesValue = (logActualAge * logHDLC) * [obj doubleValue];
                break;
            case 6:
                coefficientTimesValue = logTreatedSystolic * [obj doubleValue];
                break;
            case 7:
                coefficientTimesValue = (logActualAge * logTreatedSystolic) * [obj doubleValue];
                break;
            case 8:
                coefficientTimesValue = logUnTreatedSystolic * [obj doubleValue];
                break;
            case 9:
                coefficientTimesValue = (logActualAge * logUnTreatedSystolic) * [obj doubleValue];
                break;
            case 10:
                coefficientTimesValue = [results[kHeartAgeTestDataSmoke] integerValue] * [obj doubleValue];
                break;
            case 11:
                coefficientTimesValue = (logActualAge * [results[kHeartAgeTestDataSmoke] integerValue]) * [obj doubleValue];
                break;
            case 12:
                coefficientTimesValue = [results[kHeartAgeTestDataDiabetes] integerValue] * [obj doubleValue];
                break;
            default:
                NSAssert(YES, @"You have more objects in the coefficient array.");
                break;
        }
        
        individualSum += coefficientTimesValue;
    }
    
    // Estimated 10 year risk with Optimal Risk  Factors for an individual
    double individualEstimatedTenYearRisk = 1 - pow(baseline, exp(individualSum - populationMean));
    
    // since NAN is not equal to anything, including itself
    if (individualEstimatedTenYearRisk != individualEstimatedTenYearRisk) {
        individualEstimatedTenYearRisk = 0;
    }
    
    NSUInteger heartAge = [self findHeartAgeForRiskValue:individualEstimatedTenYearRisk forGender:gender forEthnicity:ethnicity];
    NSUInteger lifetimeRiskFactor = [self lifetimeRisk:results];
    
    return @{
             kSummaryHeartAge: [NSNumber numberWithDouble:heartAge],
             kSummaryTenYearRisk: [NSNumber numberWithDouble:individualEstimatedTenYearRisk],
             kSummaryLifetimeRisk: [NSNumber numberWithDouble:lifetimeRiskFactor]
             };
}

- (NSDictionary *)calculateRiskWithOptimalFactors:(NSDictionary *)results
{
    NSNumber *actualAge = results[kHeartAgeTestDataAge];
    NSString *gender = results[kHeartAgeTestDataGender];
    NSString *ethnicity = results[kHeartAgeTestDataEthnicity];
    
    NSDictionary *optimalResults = @{
                                     kHeartAgeTestDataAge: actualAge,
                                     kHeartAgeTestDataGender: gender,
                                     kHeartAgeTestDataEthnicity: ethnicity,
                                     
                                     kHeartAgeTestDataTotalCholesterol: self.heartAgeParametersLookup[kLookupOptimalRiskFactors][kLookupOptimalRiskFactorTotalCholesterol],
                                     
                                     kHeartAgeTestDataHDL: self.heartAgeParametersLookup[kLookupOptimalRiskFactors][kLookupOptimalRiskFactorHDL],
                                     
                                     kHeartAgeTestDataSystolicBloodPressure: self.heartAgeParametersLookup[kLookupOptimalRiskFactors][kLookupOptimalRiskFactorSystolicBP],
                                     
                                     kHeartAgeTestDataHypertension: [NSNumber numberWithBool:NO],
                                     
                                     kHeartAgeTestDataSmoke: [NSNumber numberWithBool:NO],
                                     
                                     kHeartAgeTestDataDiabetes: [NSNumber numberWithBool:NO]
                                     };
    
    NSDictionary *riskWithOptimalFactors = [self calculateHeartAgeAndRiskFactors:optimalResults];
    
    return riskWithOptimalFactors;
}

/**
 * @brief   Searches the estimated 10 year risk table that generated for the given gender and ethnicity.
 *
 * @param   riskValue   A value that will be matched (or nearly matched) in the lookup table.
 * @param   gender      Gender of the person that is taking the survey.
 * @param   ethnicity   Ethnicity of the person that is taking the survey.
 *
 * @return  Returns the heart age as an NSInteger of the person taking the survey.
 *
 * @note    This method calls the generateHeartAgeLookupTableForGender:ethnicity method to build the lookup
 *          table for the given gender and ethnicity.
 *
 * @see     -generateHeartAgeLookupTableForGender:ethnicity:
 */
- (NSInteger)findHeartAgeForRiskValue:(double)riskValue forGender:(NSString *)gender forEthnicity:(NSString *)ethnicity
{
    
    NSUInteger nearestIndex;
    
    NSArray *heartAgeLookup = [self generateHeartAgeLookupTableForGender:gender ethnicity:ethnicity];
    
    NSUInteger index = [heartAgeLookup indexOfObject:@(riskValue)
                                       inSortedRange:NSMakeRange(0, heartAgeLookup.count)
                                             options:NSBinarySearchingFirstEqual | NSBinarySearchingInsertionIndex
                                     usingComparator:^NSComparisonResult(id a, id b) {
                                         NSNumber *riskA = [(NSDictionary *)a objectForKey:@"risk"];
                                         NSNumber *riskB = (NSNumber *)b;
                                         return [riskA compare:riskB];
                                     }];
    if (index == 0) {
        nearestIndex = [[[heartAgeLookup objectAtIndex:index] objectForKey:@"age"] integerValue];
    } else if (index == heartAgeLookup.count) {
        nearestIndex = [[[heartAgeLookup lastObject] objectForKey:@"age"] integerValue];
    } else {
        double leftDifference = riskValue - [[heartAgeLookup[index - 1] objectForKey:@"risk" ] doubleValue];
        double rightDifference = [[heartAgeLookup[index] objectForKey:@"risk" ] doubleValue] - riskValue;
        
        if (leftDifference < rightDifference) {
            --index;
        }
        
        nearestIndex = [[heartAgeLookup[index] objectForKey:@"age"] integerValue];
    }
    
    return nearestIndex;
}

/**
 * @brief   Generates the lookup table for all heart ages between 17 and 100. The table includes
 *          the heart age and the 10 year risk factor.
 *
 * @param   gender      Gender of the person taking the survey.
 * @param   ethnicity   Ethnicity of the person taking the survey.
 *
 * @return  An array of dictionaries. Each dictionary has an 'age' key that corresponds to the Heart Age
 *          and 'risk' key that corresponds to the Estimated 10-Year Risk value. Both key have values
 *          that are of type NSNumber.
 *
 * @note    This method relies on the heartAgeLookup property to retrieve constant/precomputed values
 *          that are needed to perform all of the calculations.
 */
- (NSArray *)generateHeartAgeLookupTableForGender:(NSString *)gender ethnicity:(NSString *)ethnicity
{
    NSMutableArray *lookup = [NSMutableArray array];
    
    double baseline = [self.heartAgeParametersLookup[gender][ethnicity][kLookupParameters][kLookupBaseline] doubleValue];
    double populationMean = [self.heartAgeParametersLookup[gender][ethnicity][kLookupParameters][kLookupPopulationMean] doubleValue];
    double coefficient_1 = [self.heartAgeParametersLookup[gender][ethnicity][kLookupParameters][kLookupCoefficient1] doubleValue];
    double coefficient_2 = [self.heartAgeParametersLookup[gender][ethnicity][kLookupParameters][kLookupCoefficient2] doubleValue];
    double coefficient_3 = [self.heartAgeParametersLookup[gender][ethnicity][kLookupParameters][kLookupCoefficient3] doubleValue];
    
    for (NSInteger age=17; age <= 100; age++) {
        double coefficientSum =  coefficient_1 + coefficient_2 * log(age) + coefficient_3 * pow(log(age), 2.0);
        double estimatedTenYearRiskOfHardAscvd = 1 - pow(baseline, exp(coefficientSum - populationMean));
        
        [lookup addObject:@{
                            @"age": [NSNumber numberWithInteger:age],
                            @"risk": [NSNumber numberWithDouble:estimatedTenYearRiskOfHardAscvd]
                            }];
    }
    
    // TODO: Convert this using blocks, if and only if there's a performance benefit.
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"risk"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [lookup sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedArray;
}

/**
 * @brief   This method will compute the lifetime risk factor based on the results of the survey.
 *          Lifetime Risk Factor is essentially a comparison based on the predefined ranges for
 *          the data points that are provided in the survey (i.e. Systolic BP, Total Cholesterol, etc.).
 *
 *          The Atherosclerotic Cardio Vascular Disease is also a predefined, different based on gender,
 *          constant that is the used to compute the lifetime risk factor for the person taking the survey.
 *
 * @param   results A dictionary of results that contain answer to the survey questions.
 *
 * @return  Returns the lifetime risk factor (NSInteger).
 */
- (NSInteger)lifetimeRisk:(NSDictionary *)results
{
    NSString *gender = results[kHeartAgeTestDataGender];
    NSUInteger totalCholesterol = [results[kHeartAgeTestDataTotalCholesterol] integerValue];
    NSUInteger systolicBP = [results[kHeartAgeTestDataSystolicBloodPressure] integerValue];
    NSUInteger hypertension = [results[kHeartAgeTestDataHypertension] integerValue];    
    
    // The YES and NO are 1 and 0, respectively.
    NSUInteger riskFactorAllOptimal = (totalCholesterol < 180) + ((systolicBP < 120) && (hypertension == 0));
    NSUInteger riskFactorNotOptimal = ((totalCholesterol >= 180) && (totalCholesterol < 200)) + ((systolicBP >= 120) && (systolicBP < 140) && (hypertension == 0));
    NSUInteger riskFactorElevated = ((totalCholesterol >= 200) && (totalCholesterol < 240)) + ((systolicBP >= 140) && (systolicBP < 160) && (hypertension == 0));
    NSUInteger riskFactorMajor = (totalCholesterol > 240) + (systolicBP > 160) + ((systolicBP > 160) + hypertension);
    
    NSUInteger personRiskFactorAllOptimal = ((riskFactorAllOptimal == 2) && (riskFactorMajor == 0)) * [self.heartAgeParametersLookup[gender][kLookupLifetimeRiskFactor][kLifetimeRiskFactorOptimal] integerValue];
    
    NSUInteger personRiskFactorNotOptimal = ((riskFactorNotOptimal >= 1) && (riskFactorElevated == 0) && (riskFactorMajor == 0)) * [self.heartAgeParametersLookup[gender][kLookupLifetimeRiskFactor][kLifetimeRiskFactorNotOptimal] integerValue];;
    NSUInteger personRiskFactorElevated = ((riskFactorElevated >= 1) && (riskFactorMajor == 0)) * [self.heartAgeParametersLookup[gender][kLookupLifetimeRiskFactor][kLifetimeRiskFactorElevated] integerValue];;
    NSUInteger personRiskFactorMajor = (riskFactorMajor == 1) * [self.heartAgeParametersLookup[gender][kLookupLifetimeRiskFactor][kLifetimeRiskFactorMajor] integerValue];;
    NSUInteger personRiskFactorMajorGreaterThanEqualToTwo = (riskFactorMajor >= 2) * [self.heartAgeParametersLookup[gender][kLookupLifetimeRiskFactor][kLifetimeRiskFactorMajorGreaterThanEqualToTwo] integerValue];;
    
    
    
    NSUInteger lifetimeRiskFactor = personRiskFactorAllOptimal + personRiskFactorNotOptimal + personRiskFactorElevated + personRiskFactorMajor + personRiskFactorMajorGreaterThanEqualToTwo;
    
    return lifetimeRiskFactor;
}

@end
