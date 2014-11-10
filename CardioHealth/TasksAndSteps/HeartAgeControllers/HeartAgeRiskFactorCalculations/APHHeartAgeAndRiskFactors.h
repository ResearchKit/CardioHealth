//
//  HeartAgeAndRiskFactors.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 10/6/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>

extern NSString *const kHeartAgeTestDataAge;
extern NSString *const kHeartAgeTestDataTotalCholesterol;
extern NSString *const kHeartAgeTestDataHDL;
extern NSString *const kHeartAgeTestDataSystolicBloodPressure;
extern NSString *const kHeartAgeTestDataSmoke;
extern NSString *const kHeartAgeTestDataDiabetes;
extern NSString *const kHeartAgeTestDataFamilyDiabetes;
extern NSString *const kHeartAgeTestDataFamilyHeart;
extern NSString *const kHeartAgeTestDataEthnicity;
extern NSString *const kHeartAgeTestDataGender;
extern NSString *const kHeartAgeTestDataGenderFemale;
extern NSString *const kHeartAgeTestDataGenderMale;
extern NSString *const kHeartAgeTestDataCurrentlySmoke;
extern NSString *const kHeartAgeTestDataHypertension;

extern NSString *const kSummaryHeartAge;
extern NSString *const kSummaryTenYearRisk;
extern NSString *const kSummaryLifetimeRisk;

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
/**
 * @brief  Returns the 10-year and lifetime risk based on the optimal factors.
 *
 * @param  results   an NSDictionary of results collected from the survey.
 *
 * @return returns a dictionary with 3 keys: 'age', 'tenYearRisk', and 'lifetimeRisk' whoes value is an NSNumber.
 *
 */
- (NSDictionary *)calculateRiskWithOptimalFactors:(NSDictionary *)results;

@end
