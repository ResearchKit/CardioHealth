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
extern NSString *const kHeartAgekHeartAgeTestDataTotalCholesterol;
extern NSString *const kHeartAgekHeartAgeTestDataHDL;
extern NSString *const kHeartAgekHeartAgeTestDataSystolicBloodPressure;
extern NSString *const kHeartAgekHeartAgeTestDataSmoke;
extern NSString *const kHeartAgekHeartAgeTestDataDiabetes;
extern NSString *const kHeartAgekHeartAgeTestDataFamilyDiabetes;
extern NSString *const kHeartAgekHeartAgeTestDataFamilyHeart;
extern NSString *const kHeartAgekHeartAgeTestDataEthnicity;
extern NSString *const kHeartAgekHeartAgeTestDataGender;
extern NSString *const kHeartAgekHeartAgeTestDataCurrentlySmoke;
extern NSString *const kHeartAgekHeartAgeTestDataHypertension;

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

@end
