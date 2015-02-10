// 
//  APHAppDelegate.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
@import APCAppCore;
#import "APHAppDelegate.h"
#import "APHFitnessAllocation.h"
#import <CoreMotion/CoreMotion.h>

/*********************************************************************************/
#pragma mark - Initializations Options
/*********************************************************************************/
static  NSString*       const   kStudyIdentifier                        = @"Cardiovascular";
static  NSString*       const   kAppPrefix                              = @"cardiovascular";
static  NSString*       const   kVideoShownKey                          = @"VideoShown";

@interface APHAppDelegate ()

@end

@implementation APHAppDelegate

- (void) setUpInitializationOptions
{
    NSMutableDictionary * dictionary = [super defaultInitializationOptions];
    dictionary = [self updateOptionsForNoM7Chip:dictionary];
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
                                           kAnalyticsOnOffKey  : @(YES),
                                           kAnalyticsFlurryAPIKeyKey : @"9NPWCDZZY6KCXD4SCHWG"
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

- (NSMutableDictionary *) updateOptionsForNoM7Chip:(NSMutableDictionary *)initializationOptions {
    if (![CMPedometer isStepCountingAvailable] || ![CMMotionActivityManager isActivityAvailable]) {
        [initializationOptions setValue:@"APHTasksAndSchedules_NoM7" forKey:kTasksAndSchedulesJSONFileNameKey];
    }
    return initializationOptions;
}

/*********************************************************************************/
#pragma mark - Datasubstrate Delegate Methods
/*********************************************************************************/

-(void)setUpCollectors
{
    //For the Seven Day Fitness Allocation
    NSDate *fitnessStartDate = [self checkSevenDayFitnessStartDate];
    if (fitnessStartDate) {
        self.sevenDayFitnessAllocationData = [[APHFitnessAllocation alloc] initWithAllocationStartDate:fitnessStartDate];
        
        [self.sevenDayFitnessAllocationData startDataCollection];
    }
    
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

- (id<RKSTTask>)makeConsent
{
    RKSTConsentDocument* consent = [[RKSTConsentDocument alloc] init];
    consent.title = @"Consent";
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree to participate in this research Study.";
    
    RKSTConsentSignature *participantSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Participant"
                                                                            dateFormatString:nil
                                                                                  identifier:@"participant"];
    [consent addSignature:participantSig];
    
    
    NSMutableArray* components = [NSMutableArray new];
    
    NSArray* scenes = @[
                        @(RKSTConsentSectionTypeOverview),
                        @(RKSTConsentSectionTypeDataGathering),
                        @(RKSTConsentSectionTypePrivacy),
                        @(RKSTConsentSectionTypeDataUse),
                        @(RKSTConsentSectionTypeTimeCommitment),
                        @(RKSTConsentSectionTypeStudySurvey),
                        @(RKSTConsentSectionTypeStudyTasks),
                        @(RKSTConsentSectionTypeWithdrawing),
                        @(RKSTConsentSectionTypeCustom),
                        @(RKSTConsentSectionTypeCustom),
                        @(RKSTConsentSectionTypeCustom),
                        @(RKSTConsentSectionTypeCustom)
                        ];
    
    for (int i = 0; i<scenes.count; i ++) {
        
        
        RKSTConsentSectionType sectionType = [scenes[i] integerValue];
        RKSTConsentSection *section = [[RKSTConsentSection alloc] initWithType:sectionType];
        
        switch (sectionType) {
            case RKSTConsentSectionTypeStudySurvey:
            {
                section.summary = NSLocalizedString(@"By analyzing de-identified data across all app users, researchers will be able to better understand the relationships.", @"");
            }
                break;
            case RKSTConsentSectionTypeOverview:
            {
                section.title = NSLocalizedString(@"Welcome", nil);
                section.summary = NSLocalizedString(@"This simple walkthrough will help you to understand the study, the impact it will have on your life, and will allow you to provide consent to participate.", @"");
            }
                break;
            case RKSTConsentSectionTypeStudyTasks:
            {
                section.content = NSLocalizedString(@"The MyHeartCounts app will ask you to do 3 activities:\n1) use your phone, or any wearable activity device you have, to collect activity data for 7 days;\n2) perform a 6-minute walk test of fitness; and\n3) enter information about risk factors and blood tests to calculate your American Heart Association risk score.", @"");
            }
                break;
            case RKSTConsentSectionTypeDataUse:
            {
                section.title = NSLocalizedString(@"Sensor and Health Data", "");
                section.summary = NSLocalizedString(@"This study will gather sensor and health data from your phone.", @"");
            }
                break;
            case RKSTConsentSectionTypePrivacy:
            {
                section.content = NSLocalizedString(@"De-identification: Your research data from the phone will go to a secure computer where your personal identifiers will be removed to protect your privacy.\n\nCombining Data: Once your data have had personal identifiers removed, it will go to another secure computer, with the data from other subjects, to be analyzed.\n\nUsing Data: Your de-identified data, when combined with data from many other people, serves as a rich database for research analysis. It also provides a safe way to share the data with other researchers.", @"");
            }
                break;
            case RKSTConsentSectionTypeDataGathering:
            {
                section.content = NSLocalizedString(@"De-identification: Your research data from the phone will go to a secure computer where your personal identifiers will be removed to protect your privacy.\n\nCombining Data: Once your data have had personal identifiers removed, it will go to another secure computer, with the data from other subjects, to be analyzed.\n\nUsing Data: Your de-identified data, when combined with data from many other people, serves as a rich database for research analysis. It also provides a safe way to share the data with other researchers.", @"");
            }
                break;
            case RKSTConsentSectionTypeTimeCommitment:
            {
                section.title = NSLocalizedString(@"Issues to Consider", @"");
                section.summary = NSLocalizedString(@"This study will take about 1 week every 3 months.", @"");
                section.content = NSLocalizedString(@"The 3 activities can be done in one week:\n1) use your phone, or any wearable activity device you have, to collect activity data for 7 days;\n2) perform a 6-minute walk test of fitness; and\n3) enter information about risk factors and blood tests to calculate your American Heart Association risk score. We will ask you to update these activities every 3 months.", @"");
            }
                break;
            case RKSTConsentSectionTypeWithdrawing:
            {
                section.content = NSLocalizedString(@"Your authorization for the use and/or disclosure of your health information will expire December 31, 2060.\n\nVOLUNTARY PARTICIPATION AND WITHDRAWAL\nYour participation in this study is voluntary. You do not have to sign this consent form. But if you do not, you will not be able to participate in this research study. You may decide not to participate or you may leave the study at any time. Your decision will not result in any penalty or loss of benefits to which you are entitled.\n● You are not obligated to participate in this study.\n● Your questions should be answered clearly and to your satisfaction, before you choose to participate in the study.\n● You have a right to download or transfer a copy of all of your study data.\n● By agreeing to participate you do not waive any of your legal rights.\n\nIf you choose to withdraw from the research study, we will stop collecting your study data. At the end of the study period we will stop collecting your data, even if the application remains on your phone and you keep using it. If you were interested in joining another study afterward, we would ask you to complete another consent, like this one, explaining the risks and benefits of the new study.\n\nThe Study Principal Investigator or the sponsor may also withdraw you from the study without your consent at any time for any reason, including if it is in your best interest, you do not consent to continue in the study after being told of changes in the research that may affect you, or if the study is cancelled.", @"");
            }
                break;

            case RKSTConsentSectionTypeCustom:
            {
                if (i == 8) {
                    section.title = NSLocalizedString(@"Potential Benefits", @"");
                    section.summary = NSLocalizedString(@"You will be able to visualize your data and potentially learn more about trends in your health.", @"");
                    section.customImage = [UIImage imageNamed:@"consent_visualize"];
                    section.content = NSLocalizedString(@"We will provide you with personalized feedback about your activity, your fitness, and your risk score and how they relate to national guidelines.", @"");
                    
                } else if (i == 9){
                    section.title = NSLocalizedString(@"Risk to Privacy", @"");
                    section.summary = NSLocalizedString(@"Some of the data that you provide may be sensitive. We will de-identify your data and use secure computers, but we cannot ensure complete privacy.", @"");
                    section.customImage = [UIImage imageNamed:@"consent_privacy"];
                    section.content = NSLocalizedString(@"We view your privacy very strongly. Thus, we are requesting the least amount of personal data possible. Also, we are using strict security protocols to protect your data. Importantly, your personal identifiers will be removed before the data goes to the large computer for storage and later analysis. We cannot completely guarantee that someone can gain access to your private data, but importantly the main data storage is de-identified.", @"");
                } else if (i == 10){
                    section.title = NSLocalizedString(@"Issues to Consider", @"");
                    section.summary = NSLocalizedString(@"Some questions may make you uncomfortable. Simply do not respond.", @"");
                    section.customImage = [UIImage imageNamed:@"consent_uncomfortablequestions"];
                    section.content = NSLocalizedString(@"We do ask survey questions about your health history. You may decline to answer if that makes you uncomfortable.", @"");
                }else if (i == 11){
                    section.title = NSLocalizedString(@"Risk and Benefits", @"");
                    section.summary = NSLocalizedString(@"Participating in this study may change how you feel. You may feel more tired, sad, energized, or happy.", @"");
                    section.customImage = [UIImage imageNamed:@"consent_mood"];
                    section.content = NSLocalizedString(@"The MyHeartCounts app will provide data about your activity, fitness, and cardiovascular risk. These results could certainly generate a wide range of emotions.", @"");
                }
                
            }
                break;
            default:
                break;
        }
        
        [components addObject:section];
    }
    
    consent.sections = [components copy];
    
    RKSTVisualConsentStep *consentStep = [[RKSTVisualConsentStep alloc] initWithIdentifier:@"visual"
                                                                                  document:consent];
    RKSTConsentReviewStep *reviewStep = nil;
    
    NSMutableArray *consentSteps = [NSMutableArray new];
    
    [consentSteps addObject:consentStep];
    
    if (!self.dataSubstrate.currentUser.isSignedIn) {
        reviewStep = [[RKSTConsentReviewStep alloc] initWithIdentifier:@"reviewStep"
                                                             signature:participantSig
                                                            inDocument:consent];
        reviewStep.reasonForConsent = @"By agreeing you are consenting to take part in this research study.";
        
        [consentSteps addObject:reviewStep];
    }
    
    RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithIdentifier:@"consent"
                                                                  steps:consentSteps];
    return task;
}

- (RKSTTaskViewController *)consentViewController
{
    id<RKSTTask> task = [self makeConsent];
    
    RKSTTaskViewController *consentVC = [[RKSTTaskViewController alloc] initWithTask:task
                                                                         taskRunUUID:[NSUUID UUID]];
    
    return consentVC;
}

@end
