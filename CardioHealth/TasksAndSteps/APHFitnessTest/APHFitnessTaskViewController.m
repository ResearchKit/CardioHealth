// 
//  APHFitnessTaskViewController.m 
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
 
#import "APHFitnessTaskViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "APHAppDelegate.h"

static NSInteger const  kRestDuration              = 3.0 * 60.0;
static NSInteger const  kWalkDuration              = 6.0 * 60.0;
static NSString* const  kFitnessTestIdentifier     = @"6-Minute Walk Test";

static NSString* const  kFitnessTestInstructionTitle = @"6-Minute Walk Test";

static NSInteger const  kFirstStep                 = 0;
static NSInteger const  kSecondStep                = 1;
static NSInteger const  kThirdStep                 = 3;
static NSString* const  kIntroStep                 = @"instruction";
static NSString* const  kIntroOneStep              = @"instruction1";
static NSString* const  kCountdownStep             = @"countdown";
static NSString* const  kWalkStep                  = @"fitness.walk";
static NSString* const  kRestStep                  = @"fitness.rest";
static NSString* const  kConclusionStep            = @"conclusion";

static NSString* const  kHeartRateFileNameComp     = @"HKQuantityTypeIdentifierHeartRate";
static NSString* const  kLocationFileNameComp      = @"location";
static NSString* const  kPedometerFileName         = @"pedometer";
static NSString* const  kFileResultsKey            = @"items";
static NSString* const  kHeartRateValueKey         = @"value";
static NSString* const  kCoordinate                 = @"coordinate";
static NSString* const  kLongitude                 = @"longitude";
static NSString* const  kLatitude                  = @"latitude";
static NSString* const  kDistance                  = @"distance";

static NSString* const kCompletedKeyForDashboard   = @"completed";
static NSString* const kPeakHeartRateForDashboard  = @"peakHeartRate";
static NSString* const kAvgHeartRateForDashboard   = @"avgHeartRate";
static NSString* const kLastHeartRateForDashboard  = @"lastHeartRate";
static NSString* const kPedometerDistance          = @"pedometerDistance";
static NSString* const kLocationDistance           = @"totalDistance";

static NSString* const kInstructionIntendedDescription = @"This test monitors how far you can walk in six minutes. It will also record your heart rate if you are wearing such a device.";

static NSString* const kInstruction2IntendedDescription = @"Walk outdoors as far as you can for six minutes. When you're done, sit and rest comfortably for three minutes. To begin, tap Get Started.";

static NSString* const kFitnessWalkText = @"Walk as far as you can for six minutes.";

@interface APHFitnessTaskViewController ()

@end

@implementation APHFitnessTaskViewController

/*********************************************************************************/
#pragma  mark  -  Initialisation
/*********************************************************************************/

+ (ORKOrderedTask *)createTask:(APCScheduledTask *) __unused scheduledTask
{
    ORKOrderedTask  *task = [ORKOrderedTask fitnessCheckTaskWithIdentifier:kFitnessTestIdentifier intendedUseDescription:nil walkDuration:kWalkDuration restDuration:kRestDuration options:ORKPredefinedTaskOptionNone];
    
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];

    [task.steps[kFirstStep] setTitle:NSLocalizedString(kFitnessTestInstructionTitle, nil)];
    
    [task.steps[kFirstStep] setText:NSLocalizedString(kInstructionIntendedDescription, kInstructionIntendedDescription)];
    
    [task.steps[kSecondStep] setTitle:NSLocalizedString(kFitnessTestInstructionTitle, nil)];
    
    [task.steps[kSecondStep] setText:NSLocalizedString(kInstruction2IntendedDescription, kInstruction2IntendedDescription)];

    NSString  *spokenInstructionString = kFitnessWalkText;
    [task.steps[kThirdStep] setSpokenInstruction:NSLocalizedString(spokenInstructionString, nil)];

    [task.steps[kThirdStep] setTitle:NSLocalizedString(kFitnessWalkText, kFitnessWalkText)];
    
    [task.steps[5] setTitle:NSLocalizedString(@"Thank You!", nil)];
    [task.steps[5] setText:NSLocalizedString(@"The results of this activity can be viewed on the dashboard.", nil)];

    APHAppDelegate* delegate = (APHAppDelegate*)[UIApplication sharedApplication].delegate;
    double interval = [delegate.heartRateSink intervalSinceLastHeartRateUpdate];
    
    //  If the interval is a negative number we presume there is no heart rate being monitored.
    if (interval < 0)
    {
        //  Take out the resting step.
        NSMutableArray* newSteps = [[NSMutableArray alloc] initWithArray:task.steps];
        [newSteps removeObjectAtIndex:task.steps.count - 2];
        ORKOrderedTask *orderedTask = [[ORKOrderedTask alloc] initWithIdentifier:kFitnessTestIdentifier steps:[newSteps copy]];
        task = orderedTask;
    }
    
    return  task;
}

- (void)taskViewController:(ORKTaskViewController *) __unused taskViewController stepViewControllerWillAppear:(ORKStepViewController *)stepViewController {
    
    if ([stepViewController.step.identifier isEqualToString:kConclusionStep]) {
        [[UIView appearance] setTintColor:[UIColor appTertiaryColor1]];
    }

    if ([stepViewController.step isKindOfClass:[ORKCompletionStep class]])
    {
        AVSpeechUtterance *utterance = [AVSpeechUtterance
                                        speechUtteranceWithString:NSLocalizedString(@"You have completed the activity", nil)];
        utterance.rate = (AVSpeechUtteranceMinimumSpeechRate + AVSpeechUtteranceDefaultSpeechRate)*0.3;
        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        [synth speakUtterance:utterance];
    }
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(NSError *)error
{
    if (reason == ORKTaskViewControllerFinishReasonCompleted)
    {
        [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
    }
    
    [super taskViewController:taskViewController didFinishWithReason:reason error:error];
}


/*********************************************************************************/
#pragma  mark  -  Helper methods
/*********************************************************************************/
- (NSString*) createResultSummary
{
    NSMutableDictionary*    dashboardDataSource = [NSMutableDictionary new];
    NSDictionary*           distanceResults     = nil;
    NSDictionary*           heartRateResults    = nil;
    NSDictionary*           pedometerResults    = nil;
    
    ORKStepResult* stepResult = (ORKStepResult *)[self.result resultForIdentifier:kWalkStep];
    
    for (ORKFileResult* fileResult in stepResult.results)
    {
        NSString*   fileString      = [fileResult.fileURL lastPathComponent];
        NSArray*    nameComponents  = [fileString componentsSeparatedByString:@"_"];
        
        if ([[nameComponents firstObject] isEqualToString:kLocationFileNameComp])
        {
            //  Transform location data into displacement data
            [self startDisplacementSerializer:fileResult.fileURL];
        }
        else if ([[nameComponents firstObject] isEqualToString:kHeartRateFileNameComp])
        {
            heartRateResults = [self computeHeartRateForDashboardItem:fileResult.fileURL];
        }
        else if ([[nameComponents firstObject] isEqualToString:kPedometerFileName])
        {
            pedometerResults = [self pedometerData:fileResult.fileURL];
        }
    }

    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateStyle:NSDateFormatterMediumStyle];
    [format setDateFormat:@"MMM dd"];
    
    NSDate *now = [NSDate date];
    
    NSString *completedDate = [format stringFromDate:now];
    
    if (completedDate)
    {
        [dashboardDataSource setValue:completedDate
                               forKey:kCompletedKeyForDashboard];
    }
    
    if (distanceResults)
    {
        [dashboardDataSource addEntriesFromDictionary:distanceResults];
    }
    
    if (heartRateResults)
    {
        [dashboardDataSource addEntriesFromDictionary:heartRateResults];
    }
    
    if (pedometerResults)
    {
        [dashboardDataSource addEntriesFromDictionary:pedometerResults];
    }
    
    NSString*       jsonString              = [self generateJSONFromDictionary:dashboardDataSource];

    //   Iterate through the file results and if is NOT the location data do not include it in the new set of results.
    NSMutableArray* newResultForFitnessTest = [NSMutableArray new];

    if (stepResult)
    {
        for (ORKFileResult* fileResult in stepResult.results)
        {
            if (![fileResult.fileURL.lastPathComponent hasPrefix:kLocationFileNameComp])
            {
                [newResultForFitnessTest addObject:fileResult];
            }
        }
    }

    ORKStepResult* newStepResult = (ORKStepResult*)[self.result resultForIdentifier:kWalkStep];

    newStepResult.results = (NSArray *) newResultForFitnessTest;

    return jsonString;
}

- (NSDictionary*)pedometerData:(NSURL*)fileURL
{
    NSDictionary*   pedometerItems      = [self readFileResultsFor:fileURL];
    NSArray*        pedometerResults    = [pedometerItems objectForKey:kFileResultsKey];
    NSDictionary*   lastResult          = [pedometerResults lastObject];
    NSNumber*       totalDistance       = [lastResult objectForKey:kDistance];
    NSDictionary*   distance            = nil;
    
    if (totalDistance)
    {
        distance = @{kPedometerDistance : totalDistance};
    }
    
    return distance;
}

- (NSDictionary*)computeHeartRateForDashboardItem:(NSURL*)fileURL
{
    NSDictionary*   heartRateResults    = [self readFileResultsFor:fileURL];
    NSArray*        heartRates          = [heartRateResults objectForKey:kFileResultsKey];
    id              maxValue            = [NSNull null];
    id              avgValue            = [NSNull null];
    id              lastValue           = [NSNull null];
    
    if ([heartRates valueForKeyPath:@"@max.value"])
    {
        maxValue = [heartRates valueForKeyPath:@"@max.value"];
    }
    
    if ([heartRates valueForKeyPath:@"@avg.value"])
    {
        avgValue = [heartRates valueForKeyPath:@"@avg.value"];
    }
    
    if (heartRates)
    {
        if ([[heartRates lastObject] objectForKey:kHeartRateValueKey])
        {
            lastValue = [[heartRates lastObject] objectForKey:kHeartRateValueKey];
        }
    }
    
    return @{
             kPeakHeartRateForDashboard : maxValue,
             kAvgHeartRateForDashboard  : avgValue,
             kLastHeartRateForDashboard : lastValue
            };
}

- (NSDictionary *) readFileResultsFor:(NSURL *)fileURL
{
    NSError*        error       = nil;
    NSString*       contents    = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];
    NSDictionary*   results     = nil;

    if (!contents)
    {
        if (error)
        {
            APCLogError2(error);
        }
    }
    else
    {
        NSError*    error = nil;
        NSData*     data  = [contents dataUsingEncoding:NSUTF8StringEncoding];
        
        results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (!results)
        {
            if (error)
            {
                APCLogError2(error);
            }
        }
    }
    
    return results;
}

- (NSString *)generateJSONFromDictionary:(NSMutableDictionary *)dictionary
{
    NSError*    error       = nil;
    NSData*     jsonData    = [NSJSONSerialization dataWithJSONObject:dictionary
                                                               options:0
                                                                 error:&error];
    NSString* jsonString    = nil;

    if (!jsonData)
    {
        if (error)
        {
            APCLogError2(error);
        }
    }
    else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

- (NSString*)startDisplacementSerializer:(NSURL*)fileURL
{
    NSDictionary*           distanceResults     = [self readFileResultsFor:fileURL];
    NSArray*                locationData        = [distanceResults objectForKey:kFileResultsKey];
    __weak typeof (self)    weakSelf            = self;
    
    void(^LocationDataTransformer)(NSArray*) = ^(NSArray* locations)
    {
        __strong typeof (self)  strongSelf = weakSelf;
        __weak typeof (self)    weakSelf   = strongSelf;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
           __strong typeof (self) strongSelf = weakSelf;
           NSMutableArray* displacementData = [NSMutableArray new];
           
           if (locations)
           {
               CLLocation* previousCoor = nil;
               
               for (NSDictionary* location in locations)
               {
                   float lon = 0;
                   
                   if ([location objectForKey:kCoordinate])
                   {
                       if ([[location objectForKey:kCoordinate] objectForKey:kLongitude])
                       {
                           lon = [[[location objectForKey:kCoordinate] objectForKey:kLongitude] floatValue];
                       }
                   }
                   
                   float lat = 0;
                   
                   if ([location objectForKey:kCoordinate])
                   {
                       if ([[location objectForKey:kCoordinate] objectForKey:kLatitude])
                       {
                           lat = [[[location objectForKey:kCoordinate] objectForKey:kLatitude] floatValue];
                       }
                   }
                   
                   CLLocation* currentCoor = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                   
                   if(previousCoor)
                   {
                       id displacementDistance = [NSNull null];
                       id direction            = [NSNull null];
                       
                       if (@([currentCoor distanceFromLocation:previousCoor]))
                       {
                           displacementDistance = @([currentCoor distanceFromLocation:previousCoor]);
                       }
                       
                       if (@([currentCoor calculateDirectionFromLocation:previousCoor]))
                       {
                           direction = @([currentCoor calculateDirectionFromLocation:previousCoor]);
                       }
                       
                       NSDictionary* displacement = [strongSelf displacement:displacementDistance direction:direction fromLocationData:location];
                       
                       [displacementData addObject:displacement];
                   }
                   
                   previousCoor = currentCoor;
               }
               
               if ([NSJSONSerialization isValidJSONObject:displacementData])
               {
                   NSDictionary *displacementDictionary = @{@"items" : displacementData};
                   
                   [APCDataArchiverAndUploader uploadDictionary:displacementDictionary withTaskIdentifier:@"6MWT Displacement Data" andTaskRunUuid:strongSelf.taskRunUUID];
               }
           }
       });
    };
    
    //  Only if there's location data and we can produce displacement data should we continue.
    if (locationData)
    {
        if (locationData.count > 1)
        {
            LocationDataTransformer(locationData);
        }
    }
    
    return nil;
}

- (NSDictionary*)displacement:(id)displacementDistance direction:(id)direction fromLocationData:(NSDictionary*)location
{
    //  Expecting an NSNumber or null. But just in case we have this check here.
    if (displacementDistance == nil)
    {
        displacementDistance = [NSNull null];
    }
    
    if (direction == nil)
    {
        direction = [NSNull null];
    }
    
    id altitude             = [location objectForKey:@"altitude"]           ? : [NSNull null];
    id timestamp            = [location objectForKey:@"timestamp"]          ? : [NSNull null];
    id horizontalAccuracy   = [location objectForKey:@"horizontalAccuracy"] ? : [NSNull null];
    id verticalAccuracy     = [location objectForKey:@"verticalAccuracy"]   ? : [NSNull null];
    
    NSDictionary* displacement =
    @{
      @"altitude": altitude,
      @"displacement": displacementDistance,
      @"displacementUnit" : @"meters", //    always in meters
      @"direction": direction,
      @"directionUnit": @"meters", //    always in meters
      @"horizontalAccuracy": horizontalAccuracy,
      @"timestamp": timestamp,
      @"verticalAccuracy": verticalAccuracy
      };
    
    return displacement;
}


@end
