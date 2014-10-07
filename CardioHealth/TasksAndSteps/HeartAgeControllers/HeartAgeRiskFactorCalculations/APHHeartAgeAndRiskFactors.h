//
//  HeartAgeAndRiskFactors.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 10/6/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>

static NSString *kHeartAgeTestDataAge = @"heart-age-data-age";
static NSString *kHeartAgekHeartAgeTestDataTotalCholesterol = @"heart-age-data-total-cholesterol";
static NSString *kHeartAgekHeartAgeTestDataHDL = @"heart-age-data-hdl";
static NSString *kHeartAgekHeartAgeTestDataSystolicBP = @"heart-age-data-systolicBP";
static NSString *kHeartAgekHeartAgeTestDataSmoke = @"heart-age-data-smoke";
static NSString *kHeartAgekHeartAgeTestDataDiabetes = @"heart-age-data-diabetes";
static NSString *kHeartAgekHeartAgeTestDataFamilyDiabetes = @"heart-age-data-family-diabetes";
static NSString *kHeartAgekHeartAgeTestDataFamilyHeart = @"heart-age-data-family-heart";
static NSString *kHeartAgekHeartAgeTestDataEthnicity = @"heart-age-data-ethnicity";
static NSString *kHeartAgekHeartAgeTestDataGender = @"heart-age-data-gender";
static NSString *kHeartAgekHeartAgeTestDataCurrentlySmoke = @"heart-age-data-currently-smoke";
static NSString *kHeartAgekHeartAgeTestDataHypertension = @"heart-age-data-hypertension";

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
