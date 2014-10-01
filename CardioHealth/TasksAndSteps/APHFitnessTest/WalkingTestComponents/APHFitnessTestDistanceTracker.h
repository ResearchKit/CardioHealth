//
//  APHFitnessTestDistanceTracker.h
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/30/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 
 Fitness test distance tracker is going to be used to judge distance between all geolocation points beginning from start: and ending at stop:.
 
 */
typedef NS_ENUM(NSInteger, APHLocationManagerGPSSignalStrenght) {
    APHLocationManagerGPSSignalStrengthInvalid = 0,
    APHLocationManagerGPSSignalStrengthWeak = 1,
    APHLocationManagerGPSSignalStrengthStrong = 2
};

@protocol APHFitnessTestDistanceTrackerDelegate;

@interface APHFitnessTestDistanceTracker : NSObject <CLLocationManagerDelegate>

/**
 *  Designated initializer
 *
 *  @return instancetype
 */
- (instancetype)init;

/**
 *  @brief Get an early lock on location
 */
- (void)prepLocationUpdates;

/**
 *  @brief start Starts the Core Location manager updating location
 */

- (void)start;

/**
 *  @brief stop Stops the Core Location manager from updating location
 *
 *  @return A CLLocationDistance Type used to represent a distance in meters
 */

- (CLLocationDistance) stop;

/**
 *  Delegate conforms to APHFitnessTestDistanceTrackerDelegate.
 *
 */
@property (weak, nonatomic) id <APHFitnessTestDistanceTrackerDelegate> delegate;

@end

/*********************************************************************************/
//Protocol
/*********************************************************************************/
@protocol APHFitnessTestDistanceTrackerDelegate <NSObject>


@optional

/**
 * @brief Location has failed to update.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)parameters didFailToUpdateLocationWithError:(NSError *)error;

/**
 * @brief Location updates did pause.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)parameters didPauseLocationTracking:(CLLocationManager *)manager;

/**
 * @brief Location updates did resume.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)parameters didResumeLocationTracking:(CLLocationManager *)manager;

/**
 * @brief Did update locations.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)parameters didUpdateLocations:(CLLocationDistance)distance;

/**
 * @brief Signal strength changed
 */
- (void)locationManager:(CLLocationManager*)locationManager signalStrengthChanged:(APHLocationManagerGPSSignalStrenght)signalStrength;

/**
 * @brief GPS is consistently weak
 */
- (void)locationManagerSignalConsistentlyWeak:(CLLocationManager*)manager;

/**
 * @brief Finished prepping location
 */
- (void)locationManager:(CLLocationManager *)locationManager finishedPrepLocation:(BOOL)finishedPrep;

/**
 * @brief Debug text
 */
- (void)locationManager:(CLLocationManager *)locationManager debugText:(NSString *)text;

@end
