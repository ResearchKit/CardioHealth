//
//  APHFitnessTestDistanceTracker.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 9/30/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTestDistanceTracker.h"
 
static const NSUInteger kAPHFitnessTestDistanceFilter = 5.0;           // the minimum distance (meters) for which we want to receive location updates (see docs for CLLocationManager.distanceFilter)
static const NSUInteger kAPHValidLocationHistoryDeltaInterval = 3;     // the maximum valid age in seconds of a location stored in the location history

@interface APHFitnessTestDistanceTracker ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *temporaryLocationPoint;
@property (assign) APHLocationManagerGPSSignalStrength signalStrength;

//TODO decide how to handle poor signal strength
//@property (assign) BOOL allowMaximumAcceptableAccuracy;
@property (assign) BOOL startUpdatingDistance;
@property (assign) BOOL prepLocationComplete;

@property (assign) CLLocationAccuracy horizontalAccuracy;

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
        APCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        APCParameters *parameters = appDelegate.dataSubstrate.parameters;
        self.horizontalAccuracy = [[parameters numberForKey:@"FTrackerHorizonalAccuracy"] doubleValue];
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


- (void)stop
{
    
    if ([CLLocationManager locationServicesEnabled])
    {
        [self.locationManager stopUpdatingLocation];
        
    } else {
        NSLog(@"Location services disabled");
    }
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

- (void)setGPSSignalStrength:(CLLocationManager*)manager {

    if (manager.location.horizontalAccuracy <= self.horizontalAccuracy) {
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
    
    NSLog(@"Location Updated");
    /** GPS Accuracy
     
     StackOverflow:
     
     The 1414 for horizontalAccuracy indicates that the horizontal (lat/lon) position could be up to 1414m off (this is just an estimated error).
     This is probably a location determined by cell tower triangulation or WiFi location data. GPS locations usually report 100m or better.
        
     To get a higher accuracy location (300m or better) you need to set desiredAccuracy and wait for the GPS receiver to lock onto at least 3 satellites
     (or 4 for a 3D fix). Until that happens CLLocationManager will give you the best it has which is WiFi or Cell tower triangulation results.
     
     */

    [self setGPSSignalStrength:manager];
        
    if (self.temporaryLocationPoint == nil && manager.location.horizontalAccuracy <= self.horizontalAccuracy) {
        
        NSLog(@"Temporary location set and horizontal Accuracy good");
        self.temporaryLocationPoint = manager.location;
    }
    else if (manager.location.horizontalAccuracy <= self.horizontalAccuracy)
    {
        CLLocation *bestLocation = nil;
        
        float bestAccuracy = self.horizontalAccuracy;
        
        for (CLLocation *location in locations) {
            NSTimeInterval differenceInTime = [NSDate timeIntervalSinceReferenceDate] - [location.timestamp timeIntervalSinceReferenceDate];
            
            if ( differenceInTime <= kAPHValidLocationHistoryDeltaInterval) {
                
                if (location.horizontalAccuracy < bestAccuracy && location != self.temporaryLocationPoint) {
                    bestAccuracy = location.horizontalAccuracy;
                    bestLocation = location;
                }
            }
        }
        
        if (bestLocation == nil && manager.location.horizontalAccuracy <= self.horizontalAccuracy)
        {
            bestLocation = manager.location;
        }
        
        CLLocationDistance distance = [bestLocation distanceFromLocation:self.temporaryLocationPoint];
        
    
        //Return the updated distance
        NSLog(@"Update View");
        [self didUpdateLocation:distance];
    
        
        self.temporaryLocationPoint = bestLocation;
        bestLocation = nil;
    }
    
    
        /**
         Apple:
         
         When requesting high-accuracy location data, the initial event delivered by the location service may not have the accuracy you requested. The
         location service delivers the initial event as quickly as possible. It then continues to determine the location with the accuracy you requested
         and delivers additional events, as necessary, when that data is available.
         */
    
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
