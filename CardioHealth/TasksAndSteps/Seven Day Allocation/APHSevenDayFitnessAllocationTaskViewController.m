//
//  APHSevenDayFitnessAllocationViewController.m
//  MyHeart Counts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import "APHSevenDayFitnessAllocationTaskViewController.h"
#import "APHActivityTrackingStepViewController.h"

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

+ (ORKOrderedTask *)createTask:(APCScheduledTask *)scheduledTask
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

- (ORKStepViewController *)taskViewController:(ORKTaskViewController *)taskViewController viewControllerForStep:(ORKStep *)step
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
                                     NSLocalizedString(@"To ensure the accuracy of this task, keep your phone on you at all times.", @""),
                                     NSLocalizedString(@"During the next week, your fitness allocation will be monitored, analyzed, and available to you in real time.", @"")
                                    ];
        
        controller.delegate = self;
        controller.step = step;
        
        stepVC = controller;
    } else if (step.identifier == kSevenDayFitnessActivityStep) {
        UIStoryboard *sbActivityTracking = [UIStoryboard storyboardWithName:@"APHActivityTracking" bundle:nil];
        APHActivityTrackingStepViewController *activityVC = [sbActivityTracking instantiateInitialViewController];
        
        activityVC.delegate = self;
        activityVC.step = step;
        
        stepVC = activityVC;
    }
    
    return stepVC;
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithResult:(ORKTaskViewControllerResult)result error:(NSError *)error
{
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
    
    [super taskViewController:taskViewController didFinishWithResult:result error:error];
}


@end
