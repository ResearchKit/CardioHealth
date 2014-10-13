//
//  APHFitnessTestDistanceTracker.h
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/30/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@import APCAppleCore;
/**
 
 Fitness test distance tracker is going to be used to judge distance between all geolocation points beginning from start: and ending at stop:.
 
 */
typedef NS_ENUM(NSInteger, APHLocationManagerGPSSignalStrength) {
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

- (void) stop;

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
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)distanceTracker didFailToUpdateLocationWithError:(NSError *)error;

/**
 * @brief Location updates did pause.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)distanceTracker didPauseLocationTracking:(CLLocationManager *)manager;

/**
 * @brief Location updates did resume.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)distanceTracker didResumeLocationTracking:(CLLocationManager *)manager;

/**
 * @brief Did update locations.
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)distanceTracker didUpdateLocations:(CLLocationDistance)distance;

/**
 * @brief Signal strength changed
 */
- (void)locationManager:(CLLocationManager*)locationManager signalStrengthChanged:(CLLocationAccuracy)signalStrength;

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
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)distanceTracker weakGPSSignal:(NSString *)message;

/**
 * @brief Debug text
 */
- (void)fitnessTestDistanceTracker:(APHFitnessTestDistanceTracker *)distanceTracker debugView:(double)object;

@end
