// 
//  APHAppDelegate.m 
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
 
@import APCAppCore;
#import "APHAppDelegate.h"
#import "APHAppDelegate+APHMigration.h"

/*********************************************************************************/
#pragma mark - Survey Identifiers
/*********************************************************************************/
static NSString* const  kFitnessTestSurveyIdentifier                    = @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995";
static NSString* const  kSevenDaySurveyIdentifier                       = @"3-APHSevenDayAllocation-00000000-1111-1111-1111-F810BE28D995";
static NSString* const  kHeartStrokeRiskSurveyIdentifier                = @"2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";
static NSString* const  kHeartAgeBSurveyIdentifier                      = @"APHHeartAgeB-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";
static NSString* const  kCardioActivityAndSleepSurveyIdentifier         = @"2-CardioActivityAndSleepSurvey-1E174061-5B02-11E4-8ED6-0800200C9A66";
static NSString* const  kCardioVascularHealthSurveyIdentifer            = @"3-CardioVascularHealthSurvey-1E174061-5B02-11E4-8ED6-0800200C9A66";
static NSString* const  kDietSurveyIdentifier                           = @"4-DietSurvey-1E174061-5B02-11E4-8ED6-0800200C9A66";
static NSString* const  kWellBeingAndRiskPerceptionP1SurveyIdentifier   = @"2-WellBeingAndRiskPerceptionSurvey-1E174061-5B02-11E4-8ED6-0800200C9A66";
static NSString* const  kWellBeingAndRiskPerceptionP2SurveyIdentifier   = @"5-WellBeingAndRiskPerceptionSurvey-1E174061-5B02-11E4-8ED6-0800200C0000";
static NSString* const  kPhysicalActivityReadinessSurveyIdentifier      = @"1-parqquiz-1E174061-5B02-11E4-8ED6-0800200C9A77";
static NSString* const  kDailyCheckinSurveyIdentifier                   = @"1-DailyCheckin-be42dc21-4706-478a-a398-10cabb9c7d78";
static NSString* const  kDayOneCheckinSurveyIdentifier                  = @"4-DayOne-be42dc21-4706-478a-a398-10cabb9c7d78";

/*********************************************************************************/
#pragma mark - Initializations Options
/*********************************************************************************/
static NSString* const  kStudyIdentifier           = @"Cardiovascular";
static NSString* const  kAppPrefix                 = @"cardiovascular";
static NSString* const  kVideoShownKey             = @"VideoShown";
static NSString* const  kConsentPropertiesFileName = @"APHConsentSection";

static NSString* const kPreviousVersion            = @"previousVersion";
static NSString* const kCFBundleVersion            = @"CFBundleVersion";
static NSString* const kCFBundleShortVersionString = @"CFBundleShortVersionString";

static NSString* const kShortVersionStringKey      = @"shortVersionString";
static NSString* const kMinorVersion               = @"version";

@interface APHAppDelegate ()

@property  (nonatomic, assign)  NSInteger environment;

@end

@implementation APHAppDelegate

- (BOOL)application:(UIApplication*) __unused application willFinishLaunchingWithOptions:(NSDictionary*) __unused launchOptions
{
    [super application:application willFinishLaunchingWithOptions:launchOptions];
    
    NSArray* dataTypesWithReadPermission = self.initializationOptions[kHKReadPermissionsKey];
    
    if (dataTypesWithReadPermission)
    {
        for (id dataType in dataTypesWithReadPermission)
        {
            HKObjectType*   sampleType  = nil;
            
            if ([dataType isKindOfClass:[NSDictionary class]])
            {
                NSDictionary* categoryType = (NSDictionary*) dataType;
                
                //Distinguish
                if (categoryType[kHKWorkoutTypeKey])
                {
                    sampleType = [HKObjectType workoutType];
                }
                else if (categoryType[kHKCategoryTypeKey])
                {
                    sampleType = [HKObjectType categoryTypeForIdentifier:categoryType[kHKCategoryTypeKey]];
                }
            }
            else
            {
                sampleType = [HKObjectType quantityTypeForIdentifier:dataType];
            }
        
            if (sampleType)
            {
                [self.dataSubstrate.healthStore enableBackgroundDeliveryForType:sampleType
                                                                      frequency:HKUpdateFrequencyImmediate
                                                                 withCompletion:^(BOOL success, NSError *error)
                 {
                     if (!success)
                     {
                         if (error)
                         {
                             APCLogError2(error);
                         }
                     }
                     else
                     {
                         APCLogDebug(@"Enabling background delivery for healthkit");
                     }
                 }];
            }
        }
    }
    
    return YES;
}

- (void)setUpCollectors
{
    [self configureObserverQueries];
}

/*********************************************************************************/
#pragma mark - App Specific Code
/*********************************************************************************/

- (void)performMigrationAfterDataSubstrateFrom:(NSInteger) __unused previousVersion currentVersion:(NSInteger) currentVersion
{
    NSDictionary*   infoDictionary      = [[NSBundle mainBundle] infoDictionary];
    NSString*       majorVersion        = [infoDictionary objectForKey:kCFBundleShortVersionString];
    NSString*       minorVersion        = [infoDictionary objectForKey:kCFBundleVersion];
    NSUserDefaults* defaults            = [NSUserDefaults standardUserDefaults];
    NSError*        migrationError      = nil;
    
    if ([self doesPersisteStoreExist] == NO)
    {
        APCLogEvent(@"This application is being launched for the first time. We know this because there is no persistent store.");
    }
    else if ( [defaults integerForKey:kPreviousVersion] == 0)
    {
        APCLogEvent(@"The entire data model version %d", kTheEntireDataModelOfTheApp);
        if ([self performMigrationFromOneToTwoWithError:&migrationError]) {
            
            APCLogEvent(@"Migration from version 1 to 2 has failed.");
        }
    }
    
    [defaults setObject:majorVersion
                 forKey:kShortVersionStringKey];
    
    [defaults setObject:minorVersion
                 forKey:kMinorVersion];
    
    if (!migrationError)
    {
        [defaults setInteger:currentVersion forKey:kPreviousVersion];
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
#ifdef DEBUG
    self.environment = SBBEnvironmentStaging;
#else
    self.environment = SBBEnvironmentProd;
#endif
    
    dictionary = [self updateOptionsFor5OrOlder:dictionary];
    [dictionary addEntriesFromDictionary:@{
                                           kStudyIdentifierKey                  : kStudyIdentifier,
                                           kAppPrefixKey                        : kAppPrefix,
                                           kBridgeEnvironmentKey                : @(self.environment),
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
                                                   HKQuantityTypeIdentifierOxygenSaturation,
                                                   @{kHKWorkoutTypeKey  : HKWorkoutTypeIdentifier},
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
                                           kTaskReminderStartupDefaultTimeKey:@"9:00 AM"
                                           }];
    self.initializationOptions = dictionary;
}

-(void)setUpTasksReminder{
    
    APCTaskReminder *sevenDaySurveyReminder = [[APCTaskReminder alloc]initWithTaskID:kSevenDaySurveyIdentifier reminderBody:NSLocalizedString(@"Activity and Sleep Assessment", nil)];
    APCTaskReminder *dailyCheckinReminder = [[APCTaskReminder alloc]initWithTaskID:kDailyCheckinSurveyIdentifier reminderBody:NSLocalizedString(@"Daily Check-in", nil)];
    
    [self.tasksReminder manageTaskReminder:sevenDaySurveyReminder];
    [self.tasksReminder manageTaskReminder:dailyCheckinReminder];
    
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
    
    self.dataSubstrate.parameters.hideExampleConsent = YES;    
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

- (void)configureObserverQueries
{
    NSDate* (^LaunchDate)() = ^
    {
        APCUser*    user        = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
        NSDate*     consentDate = nil;
        
        if (user.consentSignatureDate)
        {
            consentDate = user.consentSignatureDate;
        }
        else
        {
            NSFileManager*  fileManager = [NSFileManager defaultManager];
            NSString*       filePath    = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"db.sqlite"];
            
            if ([fileManager fileExistsAtPath:filePath])
            {
                NSError*        error       = nil;
                NSDictionary*   attributes  = [fileManager attributesOfItemAtPath:filePath error:&error];
                
                if (error)
                {
                    APCLogError2(error);
                    
                    consentDate = [[NSDate date] startOfDay];
                }
                else
                {
                    consentDate = [attributes fileCreationDate];
                }
            }
        }
        
        return consentDate;
    };
    
    NSString*(^QuantityDataSerializer)(id) = ^NSString*(id dataSample)
    {
        HKQuantitySample*   qtySample           = (HKQuantitySample *)dataSample;
        NSString*           startDateTimeStamp  = [qtySample.startDate toStringInISO8601Format];
        NSString*           endDateTimeStamp    = [qtySample.endDate toStringInISO8601Format];
        NSString*           healthKitType       = qtySample.quantityType.identifier;
        NSString*           quantityValueRep    = [NSString stringWithFormat:@"%@", qtySample.quantity];
        NSArray*            valueSplit          = [quantityValueRep componentsSeparatedByString:@" "];
        NSString*           quantityValue       = [valueSplit objectAtIndex:0];
        NSString*           quantityUnit        = @"";
        
        for (int i = 1; i < (int)[valueSplit count]; i++)
        {
            quantityUnit = [quantityUnit stringByAppendingString:valueSplit[i]];
        }
        
        NSString*           quantitySource      = qtySample.source.name;
        
        if (quantitySource == nil)
        {
            quantitySource = @"";
        }
        else if ([[[UIDevice currentDevice] name] isEqualToString:quantitySource])
        {
            quantitySource = @"iPhone";
        }
        
        
        NSString *stringToWrite = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@\n",
                                   startDateTimeStamp,
                                   endDateTimeStamp,
                                   healthKitType,
                                   quantityValue,
                                   quantityUnit,
                                   quantitySource];
        
        return stringToWrite;
    };
    
    NSString*(^WorkoutDataSerializer)(id) = ^(id dataSample)
    {
        HKWorkout*  sample                      = (HKWorkout*)dataSample;
        NSString*   startDateTimeStamp          = [sample.startDate toStringInISO8601Format];
        NSString*   endDateTimeStamp            = [sample.endDate toStringInISO8601Format];
        NSString*   healthKitType               = sample.sampleType.identifier;
        NSString*   activityType                = [HKWorkout workoutActivityTypeStringRepresentation:(int)sample.workoutActivityType];
        double      energyConsumedValue         = [sample.totalEnergyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
        NSString*   energyConsumed              = [NSString stringWithFormat:@"%f", energyConsumedValue];
        NSString*   energyUnit                  = [HKUnit kilocalorieUnit].description;
        double      totalDistanceConsumedValue  = [sample.totalDistance doubleValueForUnit:[HKUnit meterUnit]];
        NSString*   totalDistance               = [NSString stringWithFormat:@"%f", totalDistanceConsumedValue];
        NSString*   distanceUnit                = [HKUnit meterUnit].description;
        NSString*   quantitySource              = sample.source.name;
        NSError*    error                       = nil;
        NSString*   metaData                    = [NSDictionary convertDictionary:sample.metadata ToStringWithReturningError:&error];
        NSString*   metaDataStringified         = [NSString stringWithFormat:@"\"%@\"", metaData];
        NSString*   stringToWrite               = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                                                   startDateTimeStamp,
                                                   endDateTimeStamp,
                                                   healthKitType,
                                                   activityType,
                                                   totalDistance,
                                                   distanceUnit,
                                                   energyConsumed,
                                                   energyUnit,
                                                   quantitySource,
                                                   metaDataStringified];
        
        return stringToWrite;
    };
    
    NSString*(^CategoryDataSerializer)(id) = ^NSString*(id dataSample)
    {
        HKCategorySample*   catSample       = (HKCategorySample *)dataSample;
        NSString*           startDateTime   = [catSample.startDate toStringInISO8601Format];
        NSString*           healthKitType   = catSample.sampleType.identifier;
        NSString*           categoryValue   = nil;
        
        if (catSample.value == HKCategoryValueSleepAnalysisAsleep)
        {
            categoryValue = @"HKCategoryValueSleepAnalysisAsleep";
        }
        else
        {
            categoryValue = @"HKCategoryValueSleepAnalysisInBed";
        }
        
        NSString*           quantityUnit    = [HKUnit secondUnit].description;
        NSString*           quantitySource  = catSample.source.name;
        
        // Get the difference in seconds between the start and end date for the sample
        NSDateComponents* secondsSpentInBedOrAsleep = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond
                                                                                      fromDate:catSample.startDate
                                                                                        toDate:catSample.endDate
                                                                                       options:NSCalendarWrapComponents];
        NSString*           quantityValue   = [NSString stringWithFormat:@"%ld", (long)secondsSpentInBedOrAsleep.second];
        NSString*           stringToWrite   = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@\n",
                                               startDateTime,
                                               healthKitType,
                                               categoryValue,
                                               quantityValue,
                                               quantityUnit,
                                               quantitySource];
        
        return stringToWrite;
        
    };
    
    NSString*(^CoreMotionDataSerializer)(id) = ^NSString *(id dataSample)
    {
        CMMotionActivity* motionActivitySample  = (CMMotionActivity*)dataSample;
        NSString* motionActivity                = [CMMotionActivity activityTypeName:motionActivitySample];
        NSNumber* motionConfidence              = @(motionActivitySample.confidence);
        NSString* stringToWrite                 = [NSString stringWithFormat:@"%@,%@,%@\n",
                                                   motionActivitySample.startDate.toStringInISO8601Format,
                                                   motionActivity,
                                                   motionConfidence];
        
        return stringToWrite;
    };
    
    NSArray* dataTypesWithReadPermission = self.initializationOptions[kHKReadPermissionsKey];
    
    if (!self.passiveHealthKitCollector)
    {
        self.passiveHealthKitCollector = [[APCPassiveDataCollector alloc] init];
    }
    
    // Just a note here that we are using n collectors to 1 data sink for quantity sample type data.
    NSArray*                    quantityColumnNames = @[@"startTime,endTime,type,value,unit,source"];
    APCPassiveDataSink*         quantityreceiver    = [[APCPassiveDataSink alloc] initWithIdentifier:@"HealthKitDataCollector"
                                                                                         columnNames:quantityColumnNames
                                                                                  operationQueueName:@"APCHealthKitQuantity Activity Collector"
                                                                                    andDataProcessor:QuantityDataSerializer];
    
    NSArray*                    workoutColumnNames  = @[@"startTime,endTime,type,workoutType,total distance,unit,energy consumed,unit,source,metadata"];
    APCPassiveDataSink*         workoutReceiver     = [[APCPassiveDataSink alloc] initWithIdentifier:@"HealthKitWorkoutCollector"
                                                                                         columnNames:workoutColumnNames
                                                                                  operationQueueName:@"APCHealthKitWorkout Activity Collector"
                                                                                    andDataProcessor:WorkoutDataSerializer];
    NSArray*                    categoryColumnNames = @[@"startTime,type,category value,value,unit,source"];
    APCPassiveDataSink*         sleepReceiver       = [[APCPassiveDataSink alloc] initWithIdentifier:@"HealthKitSleepCollector"
                                                                                         columnNames:categoryColumnNames
                                                                                  operationQueueName:@"APCHealthKitSleep Activity Collector"
                                                                                    andDataProcessor:CategoryDataSerializer];

    if (dataTypesWithReadPermission)
    {
        for (id dataType in dataTypesWithReadPermission)
        {
            HKSampleType* sampleType = nil;
            
            if ([dataType isKindOfClass:[NSDictionary class]])
            {
                NSDictionary* categoryType = (NSDictionary *) dataType;
                
                //Distinguish
                if (categoryType[kHKWorkoutTypeKey])
                {
                    sampleType = [HKObjectType workoutType];
                }
                else if (categoryType[kHKCategoryTypeKey])
                {
                    sampleType = [HKObjectType categoryTypeForIdentifier:categoryType[kHKCategoryTypeKey]];
                }
            }
            else
            {
                sampleType = [HKObjectType quantityTypeForIdentifier:dataType];
            }

            if (sampleType)
            {
                // This is really important to remember that we are creating as many user defaults as there are healthkit permissions here.
                NSString*                               uniqueAnchorDateName    = [NSString stringWithFormat:@"APCHealthKit%@AnchorDate", dataType];
                APCHealthKitBackgroundDataCollector*    collector               = [[APCHealthKitBackgroundDataCollector alloc] initWithIdentifier:sampleType.identifier
                                                                                                                                       sampleType:sampleType anchorName:uniqueAnchorDateName
                                                                                                                                 launchDateAnchor:LaunchDate];
                
                //If the HKObjectType is a HKWorkoutType then set a different receiver/data sink.
                if ([sampleType isKindOfClass:[HKWorkoutType class]])
                {
                    [collector setReceiver:workoutReceiver];
                    [collector setDelegate:workoutReceiver];
                }
                else if ([sampleType isKindOfClass:[HKCategoryType class]])
                {
                    [collector setReceiver:sleepReceiver];
                    [collector setDelegate:sleepReceiver];
                }
                else
                {
                    [collector setReceiver:quantityreceiver];
                    [collector setDelegate:quantityreceiver];
                }
                
                [collector start];
                [self.passiveHealthKitCollector addDataSink:collector];
            }
        }
    }
    
    APCCoreMotionBackgroundDataCollector *motionCollector = [[APCCoreMotionBackgroundDataCollector alloc] initWithIdentifier:@"motionActivityCollector"
                                                                                                              dateAnchorName:@"APCCoreMotionCollectorAnchorName"
                                                                                                            launchDateAnchor:LaunchDate];
    
    NSArray*            motionColumnNames   = @[@"startTime",@"activityType",@"confidence"];
    APCPassiveDataSink* receiver            = [[APCPassiveDataSink alloc] initWithIdentifier:@"motionActivityCollector"
                                                                                 columnNames:motionColumnNames
                                                                          operationQueueName:@"APCCoreMotion Activity Collector"
                                                                            andDataProcessor:CoreMotionDataSerializer];
    
    [motionCollector setReceiver:receiver];
    [motionCollector setDelegate:receiver];
    [motionCollector start];
    [self.passiveHealthKitCollector addDataSink:motionCollector];
}

- (NSDate*)checkSevenDayFitnessStartDate
{
    NSUserDefaults*     defaults            = [NSUserDefaults standardUserDefaults];
    NSDate*             fitnessStartDate    = [defaults objectForKey:kSevenDayFitnessStartDateKey];
    
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
