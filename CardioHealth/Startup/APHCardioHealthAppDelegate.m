//
//  APHParkinsonAppDelegate.m

//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import APCAppleCore;
#import "APHCardioHealthAppDelegate.h"
#import "APHDataSubstrate.h"
#import "APHStudyOverviewViewController.h"
#import "APHIntroVideoViewController.h"

/*********************************************************************************/
#pragma mark - Initializations Options
/*********************************************************************************/
static NSString *const kCardioHealthIdentifier = @"com.ymedialabs.aph.cardiohealth";
static NSString *const kAppPrefix = @"pd"; //TODO: Change this the correct prefix for Cardio
static NSString *const kBaseURL = @"https://bridge-uat.herokuapp.com";
static NSString *const kDataSubstrateClassName = @"APHDataSubstrate";
static NSString *const kDatabaseName = @"db.sqlite";
static NSString *const kTasksAndSchedulesJSONFileName = @"APHTasksAndSchedules";

/*********************************************************************************/
#pragma mark - App Specific Constants
/*********************************************************************************/
static NSString *const kVideoShownKey = @"VideoShown";

static NSString *const kDashBoardStoryBoardKey     = @"APHDashboard";
static NSString *const kLearnStoryBoardKey         = @"APHLearn";
static NSString *const kActivitiesStoryBoardKey    = @"APHActivities";
static NSString *const kHealthProfileStoryBoardKey = @"APHHealthProfile";

@interface APHCardioHealthAppDelegate  ( )  <UITabBarControllerDelegate>

@property  (nonatomic, strong)  NSArray  *storyboardIdInfo;

@end

@implementation APHCardioHealthAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.initializationOptions = @{
                                   kStudyIdentifierKey                  : kCardioHealthIdentifier,
                                   kAppPrefixKey                        : kAppPrefix,
                                   kBaseURLKey                          : kBaseURL,
                                   kDatabaseNameKey                     : kDatabaseName,
                                   kTasksAndSchedulesJSONFileNameKey    : kTasksAndSchedulesJSONFileName,
                                   kDataSubstrateClassNameKey           : kDataSubstrateClassName
                                   };
    //Give chance for super to initialize AppleCore before doing app specific stuff
    BOOL returnValue = [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    [self setUpAppAppearance];
    
    if (self.dataSubstrate.currentUser.isSignedIn) {
        [self showTabBarController];
    }
    else if (self.dataSubstrate.currentUser.isSignedUp)
    {
        [self showVerifyEmailViewController];
    }
    else
    {
        [self showOnBoardingProcess];
    }
    
    return returnValue;
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/
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

- (void) showOnBoardingProcess
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

- (void) showVerifyEmailViewController
{
    APCEmailVerifyViewController * viewController = (APCEmailVerifyViewController*)[[UIStoryboard storyboardWithName:@"APCEmailVerify" bundle:[NSBundle appleCoreBundle]] instantiateInitialViewController];
    [self setUpRootViewController:viewController];
}

- (void) setUpRootViewController: (UIViewController*) viewController
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.navigationBar.translucent = NO;
    self.window.rootViewController = navController;
}

- (BOOL) isVideoShown
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVideoShownKey];
}

/*********************************************************************************/
#pragma mark - Tab Bar Stuff
/*********************************************************************************/
- (NSArray *)storyboardIdInfo
{
    if (!_storyboardIdInfo) {
        _storyboardIdInfo = @[
                              kDashBoardStoryBoardKey,
                              kLearnStoryBoardKey,
                              kActivitiesStoryBoardKey,
                              kHealthProfileStoryBoardKey
                              ];
    }
    return _storyboardIdInfo;
}

- (void)showTabBarController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"TabBar" bundle:[NSBundle appleCoreBundle]];
    
    UITabBarController *tabBarController = (UITabBarController *)[storyBoard instantiateInitialViewController];
    self.window.rootViewController = tabBarController;
    tabBarController.delegate = self;
    
    NSArray       *items = tabBarController.tabBar.items;
    UITabBarItem  *selectedItem = tabBarController.tabBar.selectedItem;
    
    NSUInteger     selectedItemIndex = 0;
    if (selectedItem != nil) {
        selectedItemIndex = [items indexOfObject:selectedItem];
    }
    
    NSArray  *controllers = tabBarController.viewControllers;
    [self tabBarController:tabBarController didSelectViewController:controllers[selectedItemIndex]];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    UITabBarController  *tabster = (UITabBarController  *)self.window.rootViewController;
    NSArray  *deselectedImageNames = @[ @"tab_dashboard",          @"tab_learn",          @"tab_activities",          @"tab_profile" ];
    NSArray  *selectedImageNames   = @[ @"tab_dashboard_selected", @"tab_learn_selected", @"tab_activities_selected", @"tab_profile_selected" ];
    
    if ([viewController isMemberOfClass: [UIViewController class]] == YES) {
        
        NSMutableArray  *controllers = [tabBarController.viewControllers mutableCopy];
        NSUInteger  controllerIndex = [controllers indexOfObject:viewController];
        
        NSString  *name = [self.storyboardIdInfo objectAtIndex:controllerIndex];
        UIStoryboard  *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
        UIViewController  *controller = [storyboard instantiateInitialViewController];
        [controllers replaceObjectAtIndex:controllerIndex withObject:controller];
        
        [tabster setViewControllers:controllers animated:NO];
        tabster.tabBar.tintColor = [UIColor appPrimaryColor];
        UITabBarItem  *item = tabster.tabBar.selectedItem;
        item.image = [UIImage imageNamed:deselectedImageNames[controllerIndex] inBundle:[NSBundle appleCoreBundle] compatibleWithTraitCollection:nil];
        item.selectedImage = [[UIImage imageNamed:selectedImageNames[controllerIndex] inBundle:[NSBundle appleCoreBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

/*********************************************************************************/
#pragma mark - Overridden Notification Methods
/*********************************************************************************/
- (void) signedUpNotification: (NSNotification*) notification
{
    [super signedUpNotification:notification];
    [self showVerifyEmailViewController];
}

- (void) signedInNotification:(NSNotification*) notification
{
    [super signedInNotification:notification];
    [self showTabBarController];
}

- (void) logOutNotification:(NSNotification*) notification
{
    [super logOutNotification:notification];
    [self showOnBoardingProcess];
}

@end
