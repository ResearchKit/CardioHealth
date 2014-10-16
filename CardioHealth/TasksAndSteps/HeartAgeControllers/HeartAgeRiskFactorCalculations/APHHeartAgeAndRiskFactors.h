//
//  HeartAgeAndRiskFactors.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 10/6/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>

static NSString *kHeartAgeTestDataAge = @"heartAgeDataAge";
static NSString *kHeartAgekHeartAgeTestDataTotalCholesterol = @"heartAgeDataTotalCholesterol";
static NSString *kHeartAgekHeartAgeTestDataHDL = @"heartAgeDataHdl";
static NSString *kHeartAgekHeartAgeTestDataSystolicBloodPressure = @"heartAgeDataSystolicBloodPressure";
static NSString *kHeartAgekHeartAgeTestDataSmoke = @"heartAgeDataSmoke";
static NSString *kHeartAgekHeartAgeTestDataDiabetes = @"heartAgeDataDiabetes";
static NSString *kHeartAgekHeartAgeTestDataFamilyDiabetes = @"heartAgeDataFamilyDiabetes";
static NSString *kHeartAgekHeartAgeTestDataFamilyHeart = @"heartAgeDataFamilyHeart";
static NSString *kHeartAgekHeartAgeTestDataEthnicity = @"heartAgeDataEthnicity";
static NSString *kHeartAgekHeartAgeTestDataGender = @"heartAgeDataGender";
static NSString *kHeartAgekHeartAgeTestDataCurrentlySmoke = @"heartAgeDataCurrentlySmoke";
static NSString *kHeartAgekHeartAgeTestDataHypertension = @"heartAgeDataHypertension";

static NSString *kSummaryHeartAge = @"heartAge";
static NSString *kSummaryTenYearRisk = @"tenYearRisk";
static NSString *kSummaryLifetimeRisk = @"lifetimeRisk";

@interface APHHeartAgeAndRiskFactors : NSObject

/**
 * @brief  This is the entry point into calculating the heart age and all associated coefficients.
 *
 * @param  results   an NSDictionary of results collected from the survey.
 *
 * @return returns a dictionary with 3 keys: 'age', 'tenYearRisk', and 'lifetimeRisk' whoes value is an NSNumber.
 *
 */
- (NSDictionary *)calculateHeartAgeAndRiskFactors:(NSDictionary *)results;

@end
