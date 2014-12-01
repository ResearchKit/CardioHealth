//
//  APHParkinsonAppDelegate.m

//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import APCAppleCore;
#import "APHAppDelegate.h"

/*********************************************************************************/
#pragma mark - Initializations Options
/*********************************************************************************/
static NSString *const kStudyIdentifier = @"Cardiovascular";
static NSString *const kAppPrefix       = @"cardiovascular";

static NSString *const kVideoShownKey = @"VideoShown";

@interface APHAppDelegate ()

@property (nonatomic, strong) RKSTTaskViewController *consentVC;

@end

@implementation APHAppDelegate

- (void) setUpInitializationOptions
{
    NSMutableDictionary * dictionary = [super defaultInitializationOptions];
    [dictionary addEntriesFromDictionary:@{
                                           kStudyIdentifierKey                  : kStudyIdentifier,
                                           kAppPrefixKey                        : kAppPrefix,
                                           kBridgeEnvironmentKey                : @(SBBEnvironmentStaging),
                                           kHKReadPermissionsKey                : @[
                                                   HKQuantityTypeIdentifierBodyMass,
                                                   HKQuantityTypeIdentifierHeight
                                                   ],
                                           kHKWritePermissionsKey                : @[
                                                   HKQuantityTypeIdentifierBodyMass,
                                                   HKQuantityTypeIdentifierHeight
                                                   ],
                                           kAppServicesListRequiredKey           : @[
                                                   @(kSignUpPermissionsTypeLocation),
//                                                   @(kSignUpPermissionsTypePushNotifications),
                                                   @(kSignUpPermissionsTypeCoremotion)
                                                   ]
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
}

- (void) showOnBoarding
{
    [super showOnBoarding];
    
    if ([self isVideoShown]) {
        [self showStudyOverview];
    }
    else
    {
        NSURL *introFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Intro" ofType:@"mp4"]];
        APCIntroVideoViewController *introVideoController = [[APCIntroVideoViewController alloc] initWithContentURL:introFileURL];
        [self setUpRootViewController:introVideoController];
    }
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

/*********************************************************************************/
#pragma mark - Datasubstrate Delegate Methods
/*********************************************************************************/

-(void)setUpCollectors
{
    if (self.dataSubstrate.currentUser.isConsented) {
        NSError *error = nil;
        {
            //TODO Need to setup a mechanism to gather sleep data like passive data collection.
            //           HKCategorySample *sleepSampleType = [HKCategorySample categorySampleWithType:[HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis] value:HKCategoryValueSleepAnalysisAsleep startDate:[NSDate date] endDate:[NSDate date]];
            
            RKSTMotionActivityCollector *motionCollector = [self.dataSubstrate.study addMotionActivityCollectorWithStartDate:nil error:&error];
            if (!motionCollector)
            {
                NSLog(@"Error creating motion collector: %@", error);
                [self.dataSubstrate.studyStore removeStudy:self.dataSubstrate.study error:nil];
                goto errReturn;
            }
            
            HKQuantityType *quantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
            RKSTHealthCollector *healthCollector = [self.dataSubstrate.study addHealthCollectorWithSampleType:quantityType unit:[HKUnit countUnit] startDate:nil error:&error];
            if (!healthCollector)
            {
                NSLog(@"Error creating health collector: %@", error);
                [self.dataSubstrate.studyStore removeStudy:self.dataSubstrate.study error:nil];
                goto errReturn;
            }
            
            //Collectors below added specifically for the cardio health application.
            HKQuantityType *flightsClimbedQuantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
            RKSTHealthCollector *flightsClimbedHealthCollector = [self.dataSubstrate.study addHealthCollectorWithSampleType:flightsClimbedQuantityType unit:[HKUnit countUnit] startDate:nil error:&error];
            if (!flightsClimbedHealthCollector)
            {
                NSLog(@"Error creating flights climbed health collector: %@", error);
                [self.dataSubstrate.studyStore removeStudy:self.dataSubstrate.study error:nil];
                goto errReturn;
            }
            
            HKQuantityType *distanceWalkingRunningQuantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
            RKSTHealthCollector *distanceWalkingRunningHealthCollector = [self.dataSubstrate.study addHealthCollectorWithSampleType:distanceWalkingRunningQuantityType unit:[HKUnit countUnit] startDate:nil error:&error];
            if (!distanceWalkingRunningHealthCollector)
            {
                NSLog(@"Error creating flights climbed health collector: %@", error);
                [self.dataSubstrate.studyStore removeStudy:self.dataSubstrate.study error:nil];
                goto errReturn;
            }
            
            HKQuantityType *cyclingQuantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
            RKSTHealthCollector *cyclingHealthCollector = [self.dataSubstrate.study addHealthCollectorWithSampleType:cyclingQuantityType unit:[HKUnit countUnit] startDate:nil error:&error];
            if (!cyclingHealthCollector)
            {
                NSLog(@"Error creating flights climbed health collector: %@", error);
                [self.dataSubstrate.studyStore removeStudy:self.dataSubstrate.study error:nil];
                goto errReturn;
            }
        }
        
    errReturn:
        return;
    }
    
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

- (RKSTTaskViewController *)consentViewController
{
    if (!self.consentVC) {
        RKSTConsentDocument* consent = [[RKSTConsentDocument alloc] init];
        consent.title = @"Demo Consent";
        consent.signaturePageTitle = @"Consent";
        consent.signaturePageContent = @"I agree  to participate in this research Study.";
        
        
        //    RKSTConsentSignature *participantSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Participant" name:nil signatureImage:nil dateString:nil];
        RKSTConsentSignature *participantSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Participant"
                                                                                            name:nil
                                                                                  signatureImage:nil
                                                                                      dateString:nil
                                                                                      identifier:@"participant"];
        [consent addSignature:participantSig];
        
        //    RKSTConsentSignature *investigatorSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Investigator" name:@"Jake Clemson" signatureImage:[UIImage imageNamed:@"signature.png"] dateString:@"9/2/14"];
        RKSTConsentSignature *investigatorSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Investigator"
                                                                                             name:@"Jake Clemson"
                                                                                   signatureImage:[UIImage imageNamed:@"signature.png"]
                                                                                       dateString:@"9/2/14"
                                                                                       identifier:@"investigator"];
        [consent addSignature:investigatorSig];
        
        
        
        
        NSMutableArray* components = [NSMutableArray new];
        
        NSArray* scenes = @[@(RKSTConsentSectionTypeOverview),
                            @(RKSTConsentSectionTypeActivity),
                            @(RKSTConsentSectionTypeSensorData),
                            @(RKSTConsentSectionTypeDeIdentification),
                            @(RKSTConsentSectionTypeCombiningData),
                            @(RKSTConsentSectionTypeUtilizingData),
                            @(RKSTConsentSectionTypeImpactLifeTime),
                            @(RKSTConsentSectionTypePotentialRiskUncomfortableQuestion),
                            @(RKSTConsentSectionTypePotentialRiskSocial),
                            @(RKSTConsentSectionTypeAllowWithdraw)];
        for (NSNumber* type in scenes) {
            RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:type.integerValue];
            c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
            [components addObject:c];
        }
        
        {
            RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:RKSTConsentSectionTypeCustom];
            c.summary = @"Custom Scene summary";
            c.title = @"Custom Scene";
            c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
            c.customImage = [UIImage imageNamed:@"image_example.png"];
            [components addObject:c];
        }
        
        {
            RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:RKSTConsentSectionTypeOnlyInDocument];
            c.summary = @"OnlyInDocument Scene summary";
            c.title = @"OnlyInDocument Scene";
            c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
            [components addObject:c];
        }
        
        consent.sections = [components copy];
        
        RKSTVisualConsentStep *step = [[RKSTVisualConsentStep alloc] initWithDocument:consent];
        RKSTConsentReviewStep *reviewStep = [[RKSTConsentReviewStep alloc] initWithSignature:participantSig inDocument:consent];
        //    RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithidentifier:@"consent" steps:@[step,reviewStep]];
        RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithIdentifier:@"consent" steps:@[step, reviewStep]];
        //    RKSTTaskViewController *consentVC = [[RKSTTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
        _consentVC = [[RKSTTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    }
    
    return _consentVC;
}
@end
