//
//  APHParkinsonAppDelegate.m

//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import APCAppleCore;
#import "APHAppDelegate.h"
#import "APHDataSubstrate.h"
#import "APHStudyOverviewViewController.h"
#import "APHIntroVideoViewController.h"

/*********************************************************************************/
#pragma mark - Initializations Options
/*********************************************************************************/
static NSString *const kStudyIdentifier = @"com.ymedialabs.aph.cardiohealth";
static NSString *const kAppPrefix = @"pd"; //TODO: Change this the correct prefix for Cardio
static NSString *const kBaseURL = @"https://bridge-uat.herokuapp.com";

static NSString *const kVideoShownKey = @"VideoShown";

@implementation APHAppDelegate
/*********************************************************************************/
#pragma mark - App Specific Code
/*********************************************************************************/
- (void) setUpInitializationOptions
{
    NSMutableDictionary * dictionary = [super defaultInitializationOptions];
    [dictionary addEntriesFromDictionary:@{
                                          kStudyIdentifierKey                  : kStudyIdentifier,
                                          kAppPrefixKey                        : kAppPrefix,
                                          kBaseURLKey                          : kBaseURL,
                                          kHKReadPermissionsKey                : @[
                                                                                    HKQuantityTypeIdentifierBodyMass,
                                                                                    HKQuantityTypeIdentifierHeight,
                                                                                    HKQuantityTypeIdentifierStepCount,
                                                                                    HKQuantityTypeIdentifierHeartRate,
                                                                                    HKQuantityTypeIdentifierDistanceWalkingRunning,
                                                                                    HKQuantityTypeIdentifierFlightsClimbed,
                                                                                    HKQuantityTypeIdentifierDistanceCycling
                                                                                    ],
                                          kHKWritePermissionsKey                : @[
                                                                                    HKQuantityTypeIdentifierBodyMass,
                                                                                    HKQuantityTypeIdentifierHeight
                                                                                    ]
                                          }];
    self.initializationOptions = dictionary;
}

- (void) setUpAppAppearance
{
    [APCAppearanceInfo setAppearanceDictionary:@{
 //                                                 kPrimaryAppColorKey : [UIColor colorWithRed:0.176 green:0.706 blue:0.980 alpha:1.000]  //#2db4fa Parkinson's
 //                                                 kPrimaryAppColorKey : [UIColor colorWithRed:0.937 green:0.004 blue:0.553 alpha:1.000]  //#ef018d Breast Cancer
                                                 kPrimaryAppColorKey : [UIColor colorWithRed:0.698 green:0.027 blue:0.220 alpha:1.000]  //#b20738 Cardio
 //                                                 kPrimaryAppColorKey : [UIColor colorWithRed:0.008 green:0.498 blue:1.000 alpha:1.000]  //#027fff Cognitive
 //                                                 kPrimaryAppColorKey : [UIColor colorWithRed:0.133 green:0.122 blue:0.447 alpha:1.000]  //#221f72 Asthma
 //                                                 kPrimaryAppColorKey : [UIColor colorWithRed:0.020 green:0.549 blue:0.737 alpha:1.000]  //#058cbc Diabetes
                                                 }];

    //Appearance
    [[UINavigationBar appearance] setTintColor:[UIColor appPrimaryColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName : [UIColor appSecondaryColor2],
                                                            NSFontAttributeName : [UIFont appMediumFontWithSize:17.0f]
                                                            }];
    
}

- (void) showOnBoarding
{
    if ([self isVideoShown]) {
        [self showStudyOverview];
    }
    else
    {
        NSURL *introFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Intro" ofType:@"mp4"]];
        APHIntroVideoViewController *introVideoController = [[APHIntroVideoViewController alloc] initWithContentURL:introFileURL];
        [self setUpRootViewController:introVideoController];
    }
}

- (void) showStudyOverview
{
    APHStudyOverviewViewController *studyController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"StudyOverviewVC"];
    [self setUpRootViewController:studyController];
}

- (BOOL) isVideoShown
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVideoShownKey];
}

@end
