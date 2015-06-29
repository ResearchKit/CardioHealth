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
#import "APHHeartRateSink.h"

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
static NSString* const  kStudyIdentifier           = @"studyname";
static NSString* const  kAppPrefix                 = @"studyname";
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
    
    [self enableBackgroundDeliveryForHealthKitTypes];
    
    return YES;
}

- (void)enableBackgroundDeliveryForHealthKitTypes
{
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
                                                                      frequency:HKUpdateFrequencyHourly
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
}

- (void)setUpCollectors
{
    if (self.dataSubstrate.currentUser.userConsented)
    {
        if (!self.passiveDataCollector)
        {
            self.passiveDataCollector = [[APCPassiveDataCollector alloc] init];
        }
        
        [self configureObserverQueries];
        [self configureMotionActivityObserver];
    }
}

/*********************************************************************************/
#pragma mark - App Specific Code
/*********************************************************************************/

- (void) setUpInitializationOptions
{
    self.disableSignatureInConsent = YES;
    [APCUtilities setRealApplicationName: @"MyHeart Counts"];
    
    NSDictionary *permissionsDescriptions = @{
                                              @(kAPCSignUpPermissionsTypeLocation) : NSLocalizedString(@"Using your GPS enables the app to accurately determine distances travelled. Your actual location will never be shared.", @""),
                                              @(kAPCSignUpPermissionsTypeCoremotion) : NSLocalizedString(@"Using the motion co-processor allows the app to determine your activity, helping the study better understand how activity level may influence disease.", @""),
                                              @(kAPCSignUpPermissionsTypeMicrophone) : NSLocalizedString(@"Access to microphone is required for your Voice Recording Activity.", @""),
                                              @(kAPCSignUpPermissionsTypeLocalNotifications) : NSLocalizedString(@"Allowing notifications enables the app to show you reminders.", @""),
                                              @(kAPCSignUpPermissionsTypeHealthKit) : NSLocalizedString(@"On the next screen, you will be prompted to grant MyHeart Counts access to read and write some of your general and health information, such as height, weight and steps taken so you don't have to enter it again.", @""),
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
                                                   @(kAPCSignUpPermissionsTypeLocation),
                                                   @(kAPCSignUpPermissionsTypeCoremotion),
                                                   @(kAPCSignUpPermissionsTypeLocalNotifications)
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
                                           kTaskReminderStartupDefaultTimeKey:@"9:00 AM",
                                           kShareMessageKey : NSLocalizedString(@"Check out My Heart Counts, a research study app about Cardiovascular Disease.  Download it for iPhone at http://apple.co/1Iz7H6L", nil)
                                           }];
    
    self.initializationOptions = dictionary;
}

- (void)setUpTasksReminder
{
    APCTaskReminder *sevenDaySurveyReminder = [[APCTaskReminder alloc]initWithTaskID:kSevenDaySurveyIdentifier
                                                                        reminderBody:NSLocalizedString(@"Activity and Sleep Assessment", nil)];
    APCTaskReminder *dailyCheckinReminder = [[APCTaskReminder alloc]initWithTaskID:kDailyCheckinSurveyIdentifier
                                                                      reminderBody:NSLocalizedString(@"Daily Check-in", nil)];
    
    [self.tasksReminder.reminders removeAllObjects];
    [self.tasksReminder manageTaskReminder:sevenDaySurveyReminder];
    [self.tasksReminder manageTaskReminder:dailyCheckinReminder];
    
    if ([self doesPersisteStoreExist] == NO)
    {
        APCLogEvent(@"This app is being launched for the first time. Turn all reminders on");
        for (APCTaskReminder *reminder in self.tasksReminder.reminders)
        {
            [[NSUserDefaults standardUserDefaults]setObject:reminder.reminderBody forKey:reminder.reminderIdentifier];
        }
        
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone)
        {
            [self.tasksReminder setReminderOn:@YES];
        }
    }
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
    
    self.dataSubstrate.parameters.hideExampleConsent = NO;
    self.dataSubstrate.parameters.bypassServer = YES;
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

/*********************************************************************************/
#pragma mark - Helper Method for Datasubstrate Delegate Methods
/*********************************************************************************/

static NSDate *determineConsentDate(id object)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString      *filePath    = [[object applicationDocumentsDirectory] stringByAppendingPathComponent:@"db.sqlite"];
    NSDate        *consentDate = nil;
    
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError      *error      = nil;
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:&error];
        
        if (error != nil) {
            APCLogError2(error);
            consentDate = [[NSDate date] startOfDay];
        } else {
            consentDate = [attributes fileCreationDate];
        }
    }
    return consentDate;
}

- (NSDictionary*)researcherSpecifiedUnits
{
    NSDictionary* hkUnits =
    @{
      HKQuantityTypeIdentifierStepCount               : [HKUnit countUnit],
      HKQuantityTypeIdentifierBodyMass                : [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo],
      HKQuantityTypeIdentifierHeight                  : [HKUnit meterUnit],
      HKQuantityTypeIdentifierHeartRate               : [[HKUnit countUnit] unitDividedByUnit:[HKUnit secondUnit]],
      HKQuantityTypeIdentifierFlightsClimbed          : [HKUnit countUnit],
      HKQuantityTypeIdentifierDistanceWalkingRunning  : [HKUnit meterUnit],
      HKQuantityTypeIdentifierDistanceCycling         : [HKUnit meterUnit],
      HKQuantityTypeIdentifierBloodPressureSystolic   : [HKUnit millimeterOfMercuryUnit],
      HKQuantityTypeIdentifierBloodGlucose            : [[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] unitDividedByUnit:[HKUnit literUnitWithMetricPrefix:HKMetricPrefixDeci]],
      HKQuantityTypeIdentifierBloodPressureDiastolic  : [HKUnit millimeterOfMercuryUnit],
      HKQuantityTypeIdentifierOxygenSaturation        : [HKUnit percentUnit]
      };
    
    return hkUnits;
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
            consentDate = determineConsentDate(self);
        }
        return consentDate;
    };
    
    NSString *(^determineQuantitySource)(NSString *) = ^(NSString  *source)
    {
        NSString  *answer = nil;
        if (source == nil) {
            answer = @"not available";
        } else if ([UIDevice.currentDevice.name isEqualToString:source] == YES) {
            if ([APCDeviceHardware platformString] != nil) {
                answer = [APCDeviceHardware platformString];
            } else {
                answer = @"iPhone";    //    theoretically should not happen
            }
        }
        return answer;
    };
    
    NSString*(^QuantityDataSerializer)(id, HKUnit*) = ^NSString*(id dataSample, HKUnit* unit)
    {
        HKQuantitySample*   qtySample           = (HKQuantitySample *)dataSample;
        NSString*           startDateTimeStamp  = [qtySample.startDate toStringInISO8601Format];
        NSString*           endDateTimeStamp    = [qtySample.endDate toStringInISO8601Format];
        NSString*           healthKitType       = qtySample.quantityType.identifier;
        NSNumber*           quantityValue       = @([qtySample.quantity doubleValueForUnit:unit]);
        NSString*           quantityUnit        = unit.unitString;
        NSString*           sourceIdentifier    = qtySample.source.bundleIdentifier;
        NSString*           quantitySource      = qtySample.source.name;
        
        quantitySource = determineQuantitySource(quantitySource);
        
        NSString *stringToWrite = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@\n",
                                   startDateTimeStamp,
                                   endDateTimeStamp,
                                   healthKitType,
                                   quantityValue,
                                   quantityUnit,
                                   quantitySource,
                                   sourceIdentifier];
        
        return stringToWrite;
    };
    
    NSString*(^WorkoutDataSerializer)(id) = ^(id dataSample)
    {
        HKWorkout*  sample                      = (HKWorkout*)dataSample;
        NSString*   startDateTimeStamp          = [sample.startDate toStringInISO8601Format];
        NSString*   endDateTimeStamp            = [sample.endDate toStringInISO8601Format];
        NSString*   healthKitType               = sample.sampleType.identifier;
        NSString*   activityType                = [HKWorkout apc_workoutActivityTypeStringRepresentation:(int)sample.workoutActivityType];
        double      energyConsumedValue         = [sample.totalEnergyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
        NSString*   energyConsumed              = [NSString stringWithFormat:@"%f", energyConsumedValue];
        NSString*   energyUnit                  = [HKUnit kilocalorieUnit].description;
        double      totalDistanceConsumedValue  = [sample.totalDistance doubleValueForUnit:[HKUnit meterUnit]];
        NSString*   totalDistance               = [NSString stringWithFormat:@"%f", totalDistanceConsumedValue];
        NSString*   distanceUnit                = [HKUnit meterUnit].description;
        NSString*   sourceIdentifier            = sample.source.bundleIdentifier;
        NSString*   quantitySource              = sample.source.name;
        
        quantitySource = determineQuantitySource(quantitySource);
        
        NSError*    error                       = nil;
        NSString*   metaData                    = [NSDictionary apc_stringFromDictionary:sample.metadata error:&error];
        
        if (!metaData)
        {
            if (error)
            {
                APCLogError2(error);
            }
            
            metaData = @"";
        }
        
        NSString*   metaDataStringified         = [NSString stringWithFormat:@"\"%@\"", metaData];
        NSString*   stringToWrite               = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                                                   startDateTimeStamp,
                                                   endDateTimeStamp,
                                                   healthKitType,
                                                   activityType,
                                                   totalDistance,
                                                   distanceUnit,
                                                   energyConsumed,
                                                   energyUnit,
                                                   quantitySource,
                                                   sourceIdentifier,
                                                   metaDataStringified];
        
        return stringToWrite;
    };
    
    NSString*(^CategoryDataSerializer)(id) = ^NSString*(id dataSample)
    {
        HKCategorySample*   catSample       = (HKCategorySample *)dataSample;
        NSString*           stringToWrite   = nil;
        
        if ([catSample.categoryType.identifier isEqualToString:HKCategoryTypeIdentifierSleepAnalysis])
        {
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
            
            NSString*           quantityUnit        = [[HKUnit secondUnit] unitString];
            NSString*           sourceIdentifier    = catSample.source.bundleIdentifier;
            NSString*           quantitySource      = catSample.source.name;
            
            quantitySource = determineQuantitySource(quantitySource);
            
            // Get the difference in seconds between the start and end date for the sample
            NSDateComponents* secondsSpentInBedOrAsleep = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond
                                                                                          fromDate:catSample.startDate
                                                                                            toDate:catSample.endDate
                                                                                           options:NSCalendarWrapComponents];
            NSString*           quantityValue   = [NSString stringWithFormat:@"%ld", (long)secondsSpentInBedOrAsleep.second];
            
            stringToWrite = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@\n",
                             startDateTime,
                             healthKitType,
                             categoryValue,
                             quantityValue,
                             quantityUnit,
                             sourceIdentifier,
                             quantitySource];
        }
        
        return stringToWrite;
    };
    
    NSArray* dataTypesWithReadPermission = self.initializationOptions[kHKReadPermissionsKey];
    
    if (!self.passiveDataCollector)
    {
        self.passiveDataCollector = [[APCPassiveDataCollector alloc] init];
    }
    
    // Just a note here that we are using n collectors to 1 data sink for quantity sample type data.
    NSArray*                    quantityColumnNames = @[@"startTime,endTime,type,value,unit,source,sourceIdentifier"];
    APCPassiveDataSink*         quantityreceiver    =[[APCPassiveDataSink alloc] initWithQuantityIdentifier:@"HealthKitDataCollector"
                                                                                                columnNames:quantityColumnNames
                                                                                         operationQueueName:@"APCHealthKitQuantity Activity Collector"
                                                                                              dataProcessor:QuantityDataSerializer
                                                                                          fileProtectionKey:NSFileProtectionCompleteUnlessOpen];
    NSArray*                    workoutColumnNames  = @[@"startTime,endTime,type,workoutType,total distance,unit,energy consumed,unit,source,sourceIdentifier,metadata"];
    APCPassiveDataSink*         workoutReceiver     = [[APCPassiveDataSink alloc] initWithIdentifier:@"HealthKitWorkoutCollector"
                                                                                         columnNames:workoutColumnNames
                                                                                  operationQueueName:@"APCHealthKitWorkout Activity Collector"
                                                                                       dataProcessor:WorkoutDataSerializer
                                                                                   fileProtectionKey:NSFileProtectionCompleteUnlessOpen];
    NSArray*                    categoryColumnNames = @[@"startTime,type,category value,value,unit,source,sourceIdentifier"];
    APCPassiveDataSink*         sleepReceiver       = [[APCPassiveDataSink alloc] initWithIdentifier:@"HealthKitSleepCollector"
                                                                                         columnNames:categoryColumnNames
                                                                                  operationQueueName:@"APCHealthKitSleep Activity Collector"
                                                                                       dataProcessor:CategoryDataSerializer
                                                                                   fileProtectionKey:NSFileProtectionCompleteUnlessOpen];
    
    typeof(self) __weak weakSelf = self;
    
    self.heartRateSink = [[APHHeartRateSink alloc] initWithQuantityIdentifier:@"HealthKitDataCollector"
                                                                  columnNames:quantityColumnNames
                                                           operationQueueName:@"APCHealthKitQuantity Activity Collector"
                                                                dataProcessor:QuantityDataSerializer
                                                            fileProtectionKey:NSFileProtectionCompleteUnlessOpen
                                                                 andAppLaunch:^NSDate*
                          {
                              __typeof(self)   strongSelf = weakSelf;
                              NSDate*          activeDate = [strongSelf applicationBecameActiveDate];
                              
                              return activeDate;
                          }];
    
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
                APCHealthKitBackgroundDataCollector*    collector               = nil;
                
                //If the HKObjectType is a HKWorkoutType then set a different receiver/data sink.
                if ([sampleType isKindOfClass:[HKWorkoutType class]])
                {
                    collector = [[APCHealthKitBackgroundDataCollector alloc] initWithIdentifier:sampleType.identifier
                                                                                     sampleType:sampleType anchorName:uniqueAnchorDateName
                                                                               launchDateAnchor:LaunchDate
                                                                                    healthStore:self.dataSubstrate.healthStore];
                    [collector setReceiver:workoutReceiver];
                    [collector setDelegate:workoutReceiver];
                }
                else if ([sampleType isKindOfClass:[HKCategoryType class]])
                {
                    collector = [[APCHealthKitBackgroundDataCollector alloc] initWithIdentifier:sampleType.identifier
                                                                                     sampleType:sampleType anchorName:uniqueAnchorDateName
                                                                               launchDateAnchor:LaunchDate
                                                                                    healthStore:self.dataSubstrate.healthStore];
                    [collector setReceiver:sleepReceiver];
                    [collector setDelegate:sleepReceiver];
                }
                else if ([sampleType isKindOfClass:[HKQuantityType class]])
                {
                    NSDictionary* hkUnitKeysAndValues = [self researcherSpecifiedUnits];
                    
                    collector = [[APCHealthKitBackgroundDataCollector alloc] initWithQuantityTypeIdentifier:sampleType.identifier
                                                                                                 sampleType:sampleType anchorName:uniqueAnchorDateName
                                                                                           launchDateAnchor:LaunchDate
                                                                                                healthStore:self.dataSubstrate.healthStore
                                                                                                       unit:[hkUnitKeysAndValues objectForKey:sampleType.identifier]];
                    
                    if ([sampleType.identifier isEqualToString:HKQuantityTypeIdentifierHeartRate])
                    {
                        [collector setReceiver:self.heartRateSink];
                        [collector setDelegate:self.heartRateSink];
                    }
                    else
                    {
                        [collector setReceiver:quantityreceiver];
                        [collector setDelegate:quantityreceiver];
                    }
                }
                
                [collector start];
                [self.passiveDataCollector addDataSink:collector];
            }
        }
    }
}

- (void)configureMotionActivityObserver
{
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
            consentDate = determineConsentDate(self);
        }
        return consentDate;
    };
    
    APCCoreMotionBackgroundDataCollector *motionCollector = [[APCCoreMotionBackgroundDataCollector alloc] initWithIdentifier:@"motionActivityCollector"
                                                                                                              dateAnchorName:@"APCCoreMotionCollectorAnchorName"
                                                                                                            launchDateAnchor:LaunchDate];
    
    NSArray*            motionColumnNames   = @[@"startTime",@"activityType",@"confidence"];
    APCPassiveDataSink* receiver            = [[APCPassiveDataSink alloc] initWithIdentifier:@"motionActivityCollector"
                                                                                 columnNames:motionColumnNames
                                                                          operationQueueName:@"APCCoreMotion Activity Collector"
                                                                               dataProcessor:CoreMotionDataSerializer
                                                                           fileProtectionKey:NSFileProtectionCompleteUntilFirstUserAuthentication];
    
    [motionCollector setReceiver:receiver];
    [motionCollector setDelegate:receiver];
    [motionCollector start];
    [self.passiveDataCollector addDataSink:motionCollector];
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
