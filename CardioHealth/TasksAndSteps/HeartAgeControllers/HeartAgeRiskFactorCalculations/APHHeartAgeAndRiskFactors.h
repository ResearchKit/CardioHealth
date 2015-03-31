// 
//  APHHeartAgeAndRiskFactors.h 
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
 
#import <Foundation/Foundation.h>
#import <math.h>

extern NSString *const kHeartAgeTestDataAge;
extern NSString *const kHeartAgeTestDataTotalCholesterol;
extern NSString *const kHeartAgeTestDataHDL;
extern NSString *const kHeartAgeTestDataLDL;
extern NSString *const kHeartAgeTestDataSystolicBloodPressure;
extern NSString *const kHeartAgeTestDataDiastolicBloodPressure;
extern NSString *const kHeartAgeTestBloodGlucose;
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
