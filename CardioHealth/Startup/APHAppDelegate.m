// 
//  APHAppDelegate.m 
//  MyHeart Counts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
@import APCAppCore;
#import "APHAppDelegate.h"
#import "APHAppDelegate+APHMigration.h"

/*********************************************************************************/
#pragma mark - Initializations Options
/*********************************************************************************/
static NSString* const  kStudyIdentifier           = @"Cardiovascular";
static NSString* const  kAppPrefix                 = @"cardiovascular";
static NSString* const  kVideoShownKey             = @"VideoShown";
static NSString* const  kConsentPropertiesFileName = @"APHConsentSection";
static NSString* const  kFlurryApiKey              = @"9NPWCDZZY6KCXD4SCHWG";

@interface APHAppDelegate ()

@end

@implementation APHAppDelegate

/*********************************************************************************/
#pragma mark - App Specific Code
/*********************************************************************************/

- (void)performMigrationAfterDataSubstrateFrom:(NSInteger) __unused previousVersion currentVersion:(NSInteger) currentVersion
{
    NSDictionary*   infoDictionary      = [[NSBundle mainBundle] infoDictionary];
    NSString*       majorVersion        = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString*       minorVersion        = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    NSUserDefaults* defaults            = [NSUserDefaults standardUserDefaults];
    
    NSError*        migrationError      = nil;
    
    
    if ([self doesPersisteStoreExist] == NO)
    {
        APCLogEvent(@"This application is being launched for the first time. We know this because there is no persistent store.");
    }
    else if ( [defaults integerForKey:@"previousVersion"] == 0)
    {
        APCLogEvent(@"The entire data model version %d", kTheEntireDataModelOfTheApp);
        if ([self performMigrationFromOneToTwoWithError:&migrationError]) {
            
            APCLogEvent(@"Migration from version 1 to 2 has failed.");
        }
    }
    
    [defaults setObject:majorVersion
                 forKey:@"shortVersionString"];
    
    [defaults setObject:minorVersion
                 forKey:@"version"];
    
    
    if (!migrationError)
    {
        [defaults setInteger:currentVersion forKey:@"previousVersion"];
        [defaults synchronize];
    }
    
}

- (void) setUpInitializationOptions
{
    self.disableSignatureInConsent = YES;
    [APCUtilities setRealApplicationName: @"MyHeart Counts"];
    
    NSDictionary *permissionsDescriptions = @{
                                              @(kSignUpPermissionsTypeLocation) : NSLocalizedString(@"Using your GPS enables the app to accurately determine distances travelled. Your actual location will never be shared.", @""),
                                              @(kSignUpPermissionsTypeCoremotion) : NSLocalizedString(@"Using the motion co-processor allows the app to determine your activity, helping the study better understand how activity level may influence disease.", @""),
                                              @(kSignUpPermissionsTypeMicrophone) : NSLocalizedString(@"Access to microphone is required for your Voice Recording Activity.", @""),
                                              @(kSignUpPermissionsTypeLocalNotifications) : NSLocalizedString(@"Allowing notifications enables the app to show you reminders.", @""),
                                              @(kSignUpPermissionsTypeHealthKit) : NSLocalizedString(@"On the next screen, you will be prompted to grant MyHeart Counts access to read and write some of your general and health information, such as height, weight and steps taken so you don't have to enter it again.", @""),
                                              };
    
    NSMutableDictionary * dictionary = [super defaultInitializationOptions];
    dictionary = [self updateOptionsFor5OrOlder:dictionary];
    [dictionary addEntriesFromDictionary:@{
                                           kStudyIdentifierKey                  : kStudyIdentifier,
                                           kAppPrefixKey                        : kAppPrefix,
                                           kBridgeEnvironmentKey                : @(SBBEnvironmentProd),
                                           kHKReadPermissionsKey                : @[
                                                   HKQuantityTypeIdentifierBodyMass,
                                                   HKQuantityTypeIdentifierHeight,
                                                   HKQuantityTypeIdentifierHeartRate,
                                                   HKQuantityTypeIdentifierStepCount,
                                                   HKQuantityTypeIdentifierFlightsClimbed,
                                                   HKQuantityTypeIdentifierDistanceWalkingRunning,
                                                   HKQuantityTypeIdentifierDistanceCycling,
                                                   HKQuantityTypeIdentifierBloodPressureSystolic,
                                                   HKQuantityTypeIdentifierBloodGlucose,
                                                   HKQuantityTypeIdentifierBloodPressureDiastolic,
                                                   @{kHKCategoryTypeKey : HKCategoryTypeIdentifierSleepAnalysis}
                                                   ],
                                           kHKWritePermissionsKey                : @[
                                                   HKQuantityTypeIdentifierBodyMass,
                                                   HKQuantityTypeIdentifierHeight
                                                   ],
                                           kAppServicesListRequiredKey           : @[
                                                   @(kSignUpPermissionsTypeLocation),
                                                   @(kSignUpPermissionsTypeCoremotion),
                                                   @(kSignUpPermissionsTypeLocalNotifications)
                                                   ],
                                           kAppServicesDescriptionsKey : permissionsDescriptions,
                                           kAppProfileElementsListKey            : @[
                                                   @(kAPCUserInfoItemTypeEmail),
                                                   @(kAPCUserInfoItemTypeDateOfBirth),
                                                   @(kAPCUserInfoItemTypeBiologicalSex),
                                                   @(kAPCUserInfoItemTypeHeight),
                                                   @(kAPCUserInfoItemTypeWeight),
                                                   @(kAPCUserInfoItemTypeWakeUpTime),
                                                   @(kAPCUserInfoItemTypeSleepTime),
                                                   ],
                                           kAnalyticsOnOffKey  : @YES,
                                           kAnalyticsFlurryAPIKeyKey : kFlurryApiKey,
                                        kTaskReminderStartupDefaultTimeKey:@"9:00 AM"
                                           }];
    self.initializationOptions = dictionary;
}

- (void) setUpAppAppearance
{
    
    [APCAppearanceInfo setAppearanceDictionary:@{
                                                 kPrimaryAppColorKey : [UIColor colorWithRed:0.698 green:0.027 blue:0.220 alpha:1.000],
                                                 @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995" :[UIColor appTertiaryBlueColor],
                                                 @"3-APHSevenDayAllocation-00000000-1111-1111-1111-F810BE28D995":[UIColor appTertiaryRedColor],
                                                 @"2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF" : [UIColor lightGrayColor],
                                                 @"APHHeartAgeB-7259AC18-D711-47A6-ADBD-6CFCECDED1DF" : [UIColor lightGrayColor],
                                                 @"2-CardioActivityAndSleepSurvey-1E174061-5B02-11E4-8ED6-0800200C9A66" : [UIColor lightGrayColor],
                                                 @"3-CardioVascularHealthSurvey-1E174061-5B02-11E4-8ED6-0800200C9A66" : [UIColor lightGrayColor],
                                                 @"4-DietSurvey-1E174061-5B02-11E4-8ED6-0800200C9A66" : [UIColor lightGrayColor],
                                                 @"2-WellBeingAndRiskPerceptionSurvey-1E174061-5B02-11E4-8ED6-0800200C9A66" : [UIColor lightGrayColor],
                                                 @"1-parqquiz-1E174061-5B02-11E4-8ED6-0800200C9A77" : [UIColor lightGrayColor],
                                                 @"1-DailyCheckin-be42dc21-4706-478a-a398-10cabb9c7d78" : [UIColor lightGrayColor],
                                                 @"5-WellBeingAndRiskPerceptionSurvey-1E174061-5B02-11E4-8ED6-0800200C0000" : [UIColor lightGrayColor],
                                                 @"4-DayOne-be42dc21-4706-478a-a398-10cabb9c7d78" : [UIColor lightGrayColor],
                                                 
                                                 
                                                 }];
    [[UINavigationBar appearance] setTintColor:[UIColor appPrimaryColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName : [UIColor appSecondaryColor2],
                                                            NSFontAttributeName : [UIFont appNavBarTitleFont]
                                                            }];
    
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
    
}

- (void) showOnBoarding
{
    [super showOnBoarding];
    
    [self showStudyOverview];
}

- (void) showStudyOverview
{
    APCStudyOverviewViewController *studyController = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"StudyOverviewVC"];
    [self setUpRootViewController:studyController];
}

- (BOOL) isVideoShown
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVideoShownKey];
}

- (NSMutableDictionary *) updateOptionsFor5OrOlder:(NSMutableDictionary *)initializationOptions {
    if (![APCDeviceHardware isiPhone5SOrNewer]) {
        [initializationOptions setValue:@"APHTasksAndSchedules_NoM7" forKey:kTasksAndSchedulesJSONFileNameKey];
    }
    return initializationOptions;
}

/*********************************************************************************/
#pragma mark - Datasubstrate Delegate Methods
/*********************************************************************************/
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [super applicationDidBecomeActive:application];
    
    //For the Seven Day Fitness Allocation
    NSDate *fitnessStartDate = [self checkSevenDayFitnessStartDate];
    if (fitnessStartDate) {
        self.sevenDayFitnessAllocationData = [[APCFitnessAllocation alloc] initWithAllocationStartDate:fitnessStartDate];
        
        [self.sevenDayFitnessAllocationData startDataCollection];
    }
}
-(void)setUpCollectors
{

    APCCoreMotionTracker * motionTracker = [[APCCoreMotionTracker alloc] initWithIdentifier:@"motionTracker"];
    [self.passiveDataCollector addTracker:motionTracker];
    
    return;
    
}

- (NSDate *)checkSevenDayFitnessStartDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *fitnessStartDate = [defaults objectForKey:kSevenDayFitnessStartDateKey];
    
    return fitnessStartDate;
}

- (NSArray *)offsetForTaskSchedules
{
    return @[
             @{
                 kScheduleOffsetTaskIdKey: @"1-DailyCheckin-be42dc21-4706-478a-a398-10cabb9c7d78",
                 kScheduleOffsetOffsetKey: @(1)
                 },
             @{
                 kScheduleOffsetTaskIdKey: @"3-CardioVascularHealthSurvey-1E174061-5B02-11E4-8ED6-0800200C9A66",
                 kScheduleOffsetOffsetKey: @(1)
                 },
             @{
                 kScheduleOffsetTaskIdKey: @"4-DietSurvey-1E174061-5B02-11E4-8ED6-0800200C9A66",
                 kScheduleOffsetOffsetKey: @(1)
                 },
             @{
                 kScheduleOffsetTaskIdKey: @"2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF",
                 kScheduleOffsetOffsetKey: @(7)
                 },
             @{
                 kScheduleOffsetTaskIdKey: @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995",
                 kScheduleOffsetOffsetKey: @(7)
                 },
             @{
                 kScheduleOffsetTaskIdKey: @"2-WellBeingAndRiskPerceptionSurvey-1E174061-5B02-11E4-8ED6-0800200C9A66",
                 kScheduleOffsetOffsetKey: @(1)
                 },
             @{
                 kScheduleOffsetTaskIdKey: @"5-WellBeingAndRiskPerceptionSurvey-1E174061-5B02-11E4-8ED6-0800200C0000",
                 kScheduleOffsetOffsetKey: @(7)
                 }
             ];
}

- (NSArray *)allSetTextBlocks
{
    return @[
             @{
                 kAllSetActivitiesTextOriginal: NSLocalizedString(@"You’ll find your list of daily surveys and tasks on the “Activities” tab. New surveys and tasks will appear over the next few days.", @"")
               },
             @{
                 kAllSetDashboardTextOriginal: NSLocalizedString(@"To see your task results, check your “Dashboard” tab.",
                                                                 @"")}
             ];
}

/*********************************************************************************/
#pragma mark - APCOnboardingDelegate Methods
/*********************************************************************************/

- (APCScene *)inclusionCriteriaSceneForOnboarding:(APCOnboarding *) __unused onboarding
{
    APCScene *scene = [APCScene new];
    scene.name = @"APHInclusionCriteriaViewController";
    scene.storyboardName = @"APHOnboarding";
    scene.bundle = [NSBundle mainBundle];
    
    return scene;
}

/*********************************************************************************/
#pragma mark - Consent
/*********************************************************************************/

- (APCConsentTask*)consentTask
{
    NSString*   reason   = NSLocalizedString(@"By agreeing you confirm that you read the consent form and that you "
                                             @"wish to take part in this research study.", nil);
    APCConsentTask* task = [[APCConsentTask alloc] initWithIdentifier:@"Consent"
                                                   propertiesFileName:kConsentPropertiesFileName reasonForConsent:reason];
    return task;
}

- (ORKTaskViewController*)consentViewController
{
    ORKTaskViewController*  consentVC = [[ORKTaskViewController alloc] initWithTask:[self consentTask]
                                                                        taskRunUUID:[NSUUID UUID]];
    
    return consentVC;
}

@end
