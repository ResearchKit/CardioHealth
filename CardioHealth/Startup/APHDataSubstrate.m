//
//  APHDataSubstrate.m
//  Parkinson
//
//  Created by Dhanush Balachandran on 9/30/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHDataSubstrate.h"

static NSTimeInterval LOCATION_COLLECTION_INTERVAL = 5 * 60.0 * 60.0;

@implementation APHDataSubstrate

-(void)setUpCollectors
{
    if (self.currentUser.isConsented) {
        NSError *error = nil;
        {
            //TODO Need to setup a mechanism to gather sleep data like passive data collection.
            //           HKCategorySample *sleepSampleType = [HKCategorySample categorySampleWithType:[HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis] value:HKCategoryValueSleepAnalysisAsleep startDate:[NSDate date] endDate:[NSDate date]];
            
            RKMotionActivityCollector *motionCollector = [self.study addMotionActivityCollectorWithStartDate:nil error:&error];
            if (!motionCollector)
            {
                NSLog(@"Error creating motion collector: %@", error);
                [self.studyStore removeStudy:self.study error:nil];
                goto errReturn;
            }

            HKQuantityType *quantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
            RKHealthCollector *healthCollector = [self.study addHealthCollectorWithSampleType:quantityType unit:[HKUnit countUnit] startDate:nil error:&error];
            if (!healthCollector)
            {
                NSLog(@"Error creating health collector: %@", error);
                [self.studyStore removeStudy:self.study error:nil];
                goto errReturn;
            }
            
            //Collectors below added specifically for the cardio health application.
            HKQuantityType *flightsClimbedQuantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
            RKHealthCollector *flightsClimbedHealthCollector = [self.study addHealthCollectorWithSampleType:flightsClimbedQuantityType unit:[HKUnit countUnit] startDate:nil error:&error];
            if (!flightsClimbedHealthCollector)
            {
                NSLog(@"Error creating flights climbed health collector: %@", error);
                [self.studyStore removeStudy:self.study error:nil];
                goto errReturn;
            }
            
            HKQuantityType *distanceWalkingRunningQuantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
            RKHealthCollector *distanceWalkingRunningHealthCollector = [self.study addHealthCollectorWithSampleType:distanceWalkingRunningQuantityType unit:[HKUnit countUnit] startDate:nil error:&error];
            if (!distanceWalkingRunningHealthCollector)
            {
                NSLog(@"Error creating flights climbed health collector: %@", error);
                [self.studyStore removeStudy:self.study error:nil];
                goto errReturn;
            }

            HKQuantityType *cyclingQuantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
            RKHealthCollector *cyclingHealthCollector = [self.study addHealthCollectorWithSampleType:cyclingQuantityType unit:[HKUnit countUnit] startDate:nil error:&error];
            if (!cyclingHealthCollector)
            {
                NSLog(@"Error creating flights climbed health collector: %@", error);
                [self.studyStore removeStudy:self.study error:nil];
                goto errReturn;
            }
        }
        
    errReturn:
        return;
    }

}

@end
