//
//  APHSevenDayFitnessAllocationViewController.m
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

#import "APHSevenDayFitnessAllocationTaskViewController.h"

#warning TEMPORARY import
#import <CoreLocation/CoreLocation.h>

static NSString *kMainStudyIdentifier = @"com.cardioVascular.sevenDayFitnessAllocation";
static NSString *kSevenDayFitnessInstructionStep = @"sevenDayFitnessInstructionStep";
static NSString *kSevenDayFitnessActivityStep = @"sevenDayFitnessActivityStep";
static NSString *kSevenDayFitnessCompleteStep = @"sevenDayFitnessCompleteStep";

@interface APHSevenDayFitnessAllocationTaskViewController ()

@end

@implementation APHSevenDayFitnessAllocationTaskViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showsProgressInNavigationBar = NO;

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationBar.topItem.title = NSLocalizedString(@"7-Day Assessment", nil);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Task

+ (ORKOrderedTask *)createTask:(APCScheduledTask *) __unused scheduledTask
{
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:kSevenDayFitnessInstructionStep];
        step.title = NSLocalizedString(@"7-Day Activity and Sleep Assessment", @"7-Day Activity and Sleep Assessment");
        step.detailText = @"Some instructions";
        
        [steps addObject:step];
    }
    
    {
        // Seven Day Fitness Allocation Step
        ORKStep* step = [[ORKStep alloc] initWithIdentifier:kSevenDayFitnessActivityStep];
        step.title = NSLocalizedString(@"Activity Tracking", @"Activity Tracking");
        step.text = NSLocalizedString(@"Get Ready!", @"Get Ready");
        
        [steps addObject:step];
    }
    
    ORKOrderedTask  *task = [[ORKOrderedTask alloc] initWithIdentifier:@"sevenDayFitnessAllocation" steps:steps];
    
    return task;
}

#pragma mark - Task View Delegates

- (ORKStepViewController *)taskViewController:(ORKTaskViewController *) __unused taskViewController viewControllerForStep:(ORKStep *)step
{
    ORKStepViewController *stepVC = nil;
    
    if (step.identifier == kSevenDayFitnessInstructionStep) {
        APCInstructionStepViewController *controller = [[UIStoryboard storyboardWithName:@"APCInstructionStep"
                                                                                  bundle:[NSBundle appleCoreBundle]] instantiateInitialViewController];
        
        controller.imagesArray = @[@"tutorial-2", @"tutorial-1"];
        controller.headingsArray = @[
                                     NSLocalizedString(@"Keep Your Phone On You", @""),
                                     NSLocalizedString(@"7-Day Activity and Sleep Assessment", @"")
                                    ];
        controller.messagesArray = @[
                                     NSLocalizedString(@"To ensure the accuracy of this task, keep your phone or wearable on you at all times.", @""),
                                     NSLocalizedString(@"During the next week, your activity allocation will be recorded, analyzed, and available to you in real time.", @"")
                                    ];
        
        controller.delegate = self;
        controller.step = step;
        
        stepVC = controller;
    } else if (step.identifier == kSevenDayFitnessActivityStep) {
        UIStoryboard *sbActivityTracking = [UIStoryboard storyboardWithName:@"APCActivityTracking" bundle:[NSBundle appleCoreBundle]];
        APCActivityTrackingStepViewController *activityVC = [sbActivityTracking instantiateInitialViewController];
        
        activityVC.delegate = self;
        activityVC.step = step;
        
        stepVC = activityVC;
    }
    
    return stepVC;
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(NSError *)error
{
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
    
    [super taskViewController:taskViewController didFinishWithReason:reason error:error];
}

#warning TEMPORARY HELPER METHOD BEING TESTED HERE FOR EASE
/*********************************************************************************/
#pragma  mark  -  Helper methods
/*********************************************************************************/
- (NSString*)createResultSummary
{
    //At this point we have the file
    
    /* Get the contents of the location file
     * Pass the contents into an object that will transform the data.
     * Let THAT object have it's own data sink that will flush the content right away.
     *
     *
     *
    */
    
    NSArray* locationData =

                @[
                      @{
                          @"altitude": @(-1.5396218299865723),
                          @"coordinate": @{
                              @"latitude": @(37.52551170711118),
                              @"longitude": @(-122.26207610808791)
                          },
                          @"horizontalAccuracy": @(65),
                          @"timestamp": @"2015-04-29T07:50:44-0700",
                          @"verticalAccuracy": @(10)
                      },
                      @{
                          @"altitude": @(-1.5396218299865723),
                          @"coordinate": @{
                              @"latitude": @(37.52550846481516),
                              @"longitude": @(-122.26207870196802)
                          },
                          @"horizontalAccuracy": @(65),
                          @"timestamp": @"2015-04-29T07:50:58-0700",
                          @"verticalAccuracy": @(10)
                      },
                      @{
                          @"altitude": @(-1.5396218299865723),
                          @"coordinate": @{
                              @"latitude": @(37.52550522475725),
                              @"longitude":@( -122.2620812940452)
                          },
                          @"horizontalAccuracy": @(65),
                          @"timestamp": @"2015-04-29T07:50:58-0700",
                          @"verticalAccuracy": @(10)
                      },
                      @{
                          @"altitude": @(-1.5804280042648318),
                          @"coordinate": @{
                              @"latitude": @(37.52548785521381),
                              @"longitude": @(-122.26208838954248)
                          },
                          @"horizontalAccuracy": @(65),
                          @"timestamp": @"2015-04-29T07:50:58-0700",
                          @"verticalAccuracy": @(10)
                      },
                      @{
                          @"altitude": @(-1.540157675743103),
                          @"coordinate": @{
                              @"latitude": @(37.525495069962595),
                              @"longitude": @(-122.26210175043981)
                          },
                          @"horizontalAccuracy": @(65),
                          @"timestamp": @"2015-04-29T07:51:00-0700",
                          @"verticalAccuracy": @(10)
                      }
                      ];

    
    __weak typeof (self) weakSelf = self;
    
    void(^LocationDataTransformer)(NSArray*) = ^(NSArray* locations)
    {
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
                    
                    if ([location objectForKey:@"coordinate"])
                    {
                        if ([[location objectForKey:@"coordinate"] objectForKey:@"longitude"])
                        {
                            lon = [[[location objectForKey:@"coordinate"] objectForKey:@"longitude"] floatValue];
                        }
                    }
                    
                    float lat = 0;
                    
                    if ([location objectForKey:@"coordinate"])
                    {
                        if ([[location objectForKey:@"coordinate"] objectForKey:@"latitude"])
                        {
                            lat = [[[location objectForKey:@"coordinate"] objectForKey:@"latitude"] floatValue];
                        }
                    }
                    
                    CLLocation* currentCoor = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                    
                    if(previousCoor)
                    {
                        id displacementDistance = [NSNull null];
                        id direction            = [NSNull null];
                        
                        if ([currentCoor distanceFromLocation:previousCoor])
                        {
                            displacementDistance = @([currentCoor distanceFromLocation:previousCoor]);
                        }
                        
                        NSDictionary* displacement = [strongSelf displacement:displacementDistance direction:direction fromLocationData:location];
                        
                        [displacementData addObject:displacement];
                    }
                    else
                    {
                        NSDictionary* displacement = [strongSelf displacement:[NSNull null] direction:[NSNull null]fromLocationData:location];
                        
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
    
    LocationDataTransformer(locationData);
    
    return nil;
}

- (NSDictionary*)displacement:(id)displacementDistance direction:(id)direction fromLocationData:(NSDictionary*)location
{
    id altitude             = [NSNull null];
    id timestamp            = [NSNull null];
    id horizontalAccuracy   = [NSNull null];
    id verticalAccuracy     = [NSNull null];
    
    //  Expecting an NSNumber or null. But just in case we have this check here.
    if (displacementDistance == nil)
    {
        displacementDistance = [NSNull null];
    }
    
    if (direction == nil)
    {
        direction = [NSNull null];
    }
    
    if ([location objectForKey:@"altitude"])
    {
        altitude = [location objectForKey:@"altitude"];
    }
    
    if ([location objectForKey:@"timestamp"])
    {
        timestamp = [location objectForKey:@"timestamp"];
    }
    
    if ([location objectForKey:@"horizontalAccuracy"])
    {
        horizontalAccuracy = [location objectForKey:@"horizontalAccuracy"];
    }
    
    if ([location objectForKey:@"verticalAccuracy"])
    {
        verticalAccuracy = [location objectForKey:@"verticalAccuracy"];
    }
    
    NSDictionary* displacement =
    @{
      @"altitude": altitude,
      @"displacement": displacementDistance,
      @"displacementUnit" : @"meters", //    always in meters
      @"direction": direction,
      @"direction": @"meters", //    always in meters
      @"horizontalAccuracy": horizontalAccuracy,
      @"timestamp": timestamp,
      @"verticalAccuracy": verticalAccuracy
      };
    
    return displacement;
}

@end
