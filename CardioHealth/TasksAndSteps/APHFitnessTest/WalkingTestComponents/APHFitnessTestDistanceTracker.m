//
//  APHFitnessTestDistanceTracker.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/30/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTestDistanceTracker.h"


static const NSUInteger kAPHFitnessTestDistanceFilter = 8.0;                               // the minimum distance (meters) for which we want to receive location updates (see docs for CLLocationManager.distanceFilter)
static const float kAPHFitnessTestRequiredHorizontalAccuracy = 5.0;                      // the required accuracy in meters for a location.  if we receive anything above this number, the delegate will be informed that the signal is weak
//static const float kAPHFitnessTestMaximumAcceptableHorizontalAccuracy = 10.0;             // the maximum acceptable accuracy in meters for a location.  anything above this number will be completely ignored
static const NSUInteger kAPHValidLocationHistoryDeltaInterval = 3;                        // the maximum valid age in seconds of a location stored in the location history

//static const NSUInteger kAPHFitnessTestGPSRefinementInterval = 15;                        // the number of seconds at which we will attempt to achieve kRequiredHorizontalAccuracy before giving up and accepting kMaximumAcceptableHorizontalAccuracy
//static const NSUInteger kAPHFitnessTestValidLocationHistoryDeltaInterval = 3;             // the maximum valid age in seconds of a location stored in the location history
//static const NSUInteger kAPHFitnessTestMinLocationsNeededToUpdateDistanceAndSpeed = 3;    // the number of locations needed in history before we will even update the current distance and speed
//static const NSUInteger kAPHFitnessTestMinimumLocationUpdateInterval = 10;                // the interval (seconds) at which we ping for a new location if we haven't received one yet

@interface APHFitnessTestDistanceTracker ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *temporaryLocationPoint;
@property (assign) CLLocationDistance totalDistance;
@property (assign) APHLocationManagerGPSSignalStrength signalStrength;

//TODO decide how to handle poor signal strength
//@property (assign) BOOL allowMaximumAcceptableAccuracy;
@property (assign) BOOL startUpdatingDistance;

@property (assign) BOOL prepLocationComplete;

@end


@implementation APHFitnessTestDistanceTracker

-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        //TODO Check this once onboarding process has been setup.
//        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            self.locationManager = [[CLLocationManager alloc]init];
            [self.locationManager setDelegate:self];
            [self.locationManager requestAlwaysAuthorization];
            self.locationManager.activityType = CLActivityTypeFitness;
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
            [self.locationManager setPausesLocationUpdatesAutomatically:YES];
            [self.locationManager setDistanceFilter:kAPHFitnessTestDistanceFilter];
            self.startUpdatingDistance = NO;
            self.prepLocationComplete = NO;
//        }

    }
    
    return self;
}

- (void) prepLocationUpdates {
    [self.locationManager startUpdatingLocation];
}

- (void)start
{
    self.startUpdatingDistance = YES;
}


- (CLLocationDistance)stop
{
    
    if ([CLLocationManager locationServicesEnabled])
    {
        [self.locationManager stopUpdatingLocation];
        
    } else {
        NSLog(@"Location services disabled");
    }
    
    return self.totalDistance;
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

- (void)setGPSSignalStrength:(CLLocationManager*)manager {

    if (manager.location.horizontalAccuracy <= kAPHFitnessTestRequiredHorizontalAccuracy) {
        self.signalStrength = APHLocationManagerGPSSignalStrengthStrong;
        
    } else {
        self.signalStrength = APHLocationManagerGPSSignalStrengthWeak;
        
        //Send to delegate
        [self GPSSignalStrength:manager.location.horizontalAccuracy];
    }
    
//    double horizontalAccuracy;
//    
//    if (self.allowMaximumAcceptableAccuracy) {
//        horizontalAccuracy = kAPHFitnessTestMaximumAcceptableHorizontalAccuracy;
//    } else {
//        horizontalAccuracy = kAPHFitnessTestRequiredHorizontalAccuracy;
//    }
    
}

/*********************************************************************************/
#pragma mark -CLLocationManagerDelegate
/*********************************************************************************/
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    
    //TODO error handling
}


- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"locationManagerDidResumeLocationUpdates");
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"locationManagerDidPauseLocationUpdates");
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    
    /** GPS Accuracy
     
     StackOverflow:
     
     The 1414 for horizontalAccuracy indicates that the horizontal (lat/lon) position could be up to 1414m off (this is just an estimated error).
     This is probably a location determined by cell tower triangulation or WiFi location data. GPS locations usually report 100m or better.
        
     To get a higher accuracy location (300m or better) you need to set desiredAccuracy and wait for the GPS receiver to lock onto at least 3 satellites
     (or 4 for a 3D fix). Until that happens CLLocationManager will give you the best it has which is WiFi or Cell tower triangulation results.
     
     */
    //TODO remove this debug view
    [self debugView:manager.location.horizontalAccuracy];

    [self setGPSSignalStrength:manager];
    
    if (self.prepLocationComplete && self.startUpdatingDistance) {
    

        
        if (self.temporaryLocationPoint == nil && manager.location.horizontalAccuracy <= kAPHFitnessTestRequiredHorizontalAccuracy) {
            self.temporaryLocationPoint = manager.location;
            self.totalDistance = 0;
        }
        else
        {
            CLLocation *bestLocation;
            
            float bestAccuracy = kAPHFitnessTestRequiredHorizontalAccuracy;
            
            for (CLLocation *location in locations) {
                NSTimeInterval differenceInTime = [NSDate timeIntervalSinceReferenceDate] - [location.timestamp timeIntervalSinceReferenceDate];
                
                if ( differenceInTime <= kAPHValidLocationHistoryDeltaInterval) {
                    
                    if (location.horizontalAccuracy < bestAccuracy && location != self.temporaryLocationPoint) {
                        bestAccuracy = location.horizontalAccuracy;
                        bestLocation = location;
                    }
                }
            }
            if (bestLocation == nil && manager.location.horizontalAccuracy <= kAPHFitnessTestRequiredHorizontalAccuracy)
            {
                bestLocation = manager.location;
                
                CLLocationDistance distance = [bestLocation distanceFromLocation:self.temporaryLocationPoint];
                
                self.totalDistance += distance;
                
                //Return the updated distance
                [self didUpdateLocation:self.totalDistance];
                
                self.temporaryLocationPoint = bestLocation;
                
            }
        }
    }
    else
    {
        //This is set once
        /**
         Apple:
         
         When requesting high-accuracy location data, the initial event delivered by the location service may not have the accuracy you requested. The
         location service delivers the initial event as quickly as possible. It then continues to determine the location with the accuracy you requested
         and delivers additional events, as necessary, when that data is available.
         */

        self.prepLocationComplete = YES;
        [self.delegate locationManager:manager finishedPrepLocation:self.prepLocationComplete];
    }
    
    //TODO What to do in the instance GPS signal is weak?
    /**
     Estimate using GPS Accuracy, time and some average speed
     How to account for resting?
     
     */
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Asynchronous call failed");
    
    //TODO connection failed. What to do here.
}



/*********************************************************************************/
#pragma mark - Delegate Methods
/*********************************************************************************/

- (void) didFailToUpdateLocationWithError:(NSError *)error
{
    
    if ( [self.delegate respondsToSelector:@selector(fitnessTestDistanceTracker:didFailToUpdateLocationWithError:)] ) {
        
        [self.delegate fitnessTestDistanceTracker:self didFailToUpdateLocationWithError:error];
    }
}


- (void) didPauseLocationTracking:(CLLocationManager *)manager
{
    
    if ( [self.delegate respondsToSelector:@selector(fitnessTestDistanceTracker:didPauseLocationTracking:)] ) {
        
        [self.delegate fitnessTestDistanceTracker:self didPauseLocationTracking:manager];
    }
}


- (void) didResumeLocationTracking:(CLLocationManager *)manager
{
    
    if ( [self.delegate respondsToSelector:@selector(fitnessTestDistanceTracker:didResumeLocationTracking:)] ) {
        
        [self.delegate fitnessTestDistanceTracker:self didResumeLocationTracking:manager];
    }
}

- (void) didUpdateLocation:(CLLocationDistance)distance
{
    //TODO return the total distance traveled
    
    if ( [self.delegate respondsToSelector:@selector(fitnessTestDistanceTracker:didUpdateLocations:)] ) {
        
        [self.delegate fitnessTestDistanceTracker:self didUpdateLocations:distance];
    }
}

- (void) GPSSignalStrength:(CLLocationAccuracy)accuracy {
    
    if ([self.delegate respondsToSelector:@selector(fitnessTestDistanceTracker:weakGPSSignal:)]) {
        [self.delegate fitnessTestDistanceTracker:self weakGPSSignal: [NSString stringWithFormat:@"Weak GPS Signal %.2f", accuracy]];
    }
}

- (void) debugView:(CLLocationDistance)distance
{
    //TODO return the total distance traveled
    
    if ( [self.delegate respondsToSelector:@selector(fitnessTestDistanceTracker:debugView:)] ) {
        
        [self.delegate fitnessTestDistanceTracker:self debugView:distance];
    }
}

@end
