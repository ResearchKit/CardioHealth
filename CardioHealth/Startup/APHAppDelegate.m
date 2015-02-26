// 
//  APHAppDelegate.m 
//  MyHeart Counts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
@import APCAppCore;
#import "APHAppDelegate.h"
#import "APHFitnessAllocation.h"

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

- (void) setUpInitializationOptions
{
    NSMutableDictionary * dictionary = [super defaultInitializationOptions];
    dictionary = [self updateOptionsFor5OrOlder:dictionary];
    [dictionary addEntriesFromDictionary:@{
                                           kStudyIdentifierKey                  : kStudyIdentifier,
                                           kAppPrefixKey                        : kAppPrefix,
                                           kBridgeEnvironmentKey                : @(SBBEnvironmentStaging),
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
                                           kAnalyticsFlurryAPIKeyKey : kFlurryApiKey
                                           }];
    self.initializationOptions = dictionary;
}

- (void) setUpAppAppearance
{
    [APCAppearanceInfo setAppearanceDictionary:@{
                                                 kPrimaryAppColorKey : [UIColor colorWithRed:0.698 green:0.027 blue:0.220 alpha:1.000]
                                                 }];
    [[UINavigationBar appearance] setTintColor:[UIColor appPrimaryColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName : [UIColor appSecondaryColor2],
                                                            NSFontAttributeName : [UIFont appMediumFontWithSize:17.0f]
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
        self.sevenDayFitnessAllocationData = [[APHFitnessAllocation alloc] initWithAllocationStartDate:fitnessStartDate];
        
        [self.sevenDayFitnessAllocationData startDataCollection];
    }
    
}
-(void)setUpCollectors
{
    //For the Seven Day Fitness Allocation
    NSDate *fitnessStartDate = [self checkSevenDayFitnessStartDate];
    if (fitnessStartDate) {
        self.sevenDayFitnessAllocationData = [[APHFitnessAllocation alloc] initWithAllocationStartDate:fitnessStartDate];
        
        [self.sevenDayFitnessAllocationData startDataCollection];
    }

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

/*********************************************************************************/
#pragma mark - APCOnboardingDelegate Methods
/*********************************************************************************/

- (APCScene *)inclusionCriteriaSceneForOnboarding:(APCOnboarding *)onboarding
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

- (NSArray*)makeConsentSections
{
    NSString*               agreement = @"By agreeing you confirm that you have read the Consent, that you understand it and that you wish to take part in this research study.";
    NSString*               docHtml   = nil;
    NSArray*                sections  = [super consentSectionsAndHtmlContent:&docHtml];
    ORKConsentDocument*     document  = [[ORKConsentDocument alloc] init];
    ORKConsentSignature*    signature = [ORKConsentSignature signatureForPersonWithTitle:NSLocalizedString(@"Participant", nil)
                                                                        dateFormatString:nil
                                                                              identifier:@"participant"];
    
    signature.requiresSignatureImage = NO;
    document.title                   = NSLocalizedString(@"Consent", nil);
    document.signaturePageTitle      = NSLocalizedString(@"Consent", nil);
    document.signaturePageContent    = NSLocalizedString(agreement, nil);
    document.sections                = sections;
    document.htmlReviewContent       = docHtml;
    
    [document addSignature:signature];
    
    
    ORKVisualConsentStep*   step         = [[ORKVisualConsentStep alloc] initWithIdentifier:@"visual" document:document];
    ORKConsentReviewStep*   reviewStep   = nil;
    NSMutableArray*         consentSteps = [NSMutableArray arrayWithObject:step];
    
    reviewStep                  = [[ORKConsentReviewStep alloc] initWithIdentifier:@"reviewStep" signature:signature inDocument:document];
    reviewStep.reasonForConsent = NSLocalizedString(@"By agreeing you confirm that you have read the Consent, that you understand it and that you wish to take part in this research study.", nil);
    
    [consentSteps addObject:reviewStep];
    
    return consentSteps;
//    
//    ORKOrderedTask* task = [[ORKOrderedTask alloc] initWithIdentifier:@"consent" steps:consentSteps];
//    
//    return task;
}

- (ORKTaskViewController *)consentViewController
{
    APCConsentTask* task = [[APCConsentTask alloc] initWithIdentifier:@"Consent"
                                                   propertiesFileName:kConsentPropertiesFileName];

    
    ORKTaskViewController *consentVC = [[ORKTaskViewController alloc] initWithTask:task
                                                                         taskRunUUID:[NSUUID UUID]];
    
    return consentVC;
}

@end
