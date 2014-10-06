//
//  HeartAgeAndRiskFactors.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 10/6/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>

@interface APHHeartAgeAndRiskFactors : NSObject

- (NSDictionary *)calculateHeartAgeAndTenYearRisk:(NSDictionary *)results;

@end
