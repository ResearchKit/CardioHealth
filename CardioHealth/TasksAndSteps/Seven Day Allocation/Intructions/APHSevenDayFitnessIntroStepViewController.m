//
//  APHSevenDayFitnessIntroStepViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSevenDayFitnessIntroStepViewController.h"
#import "APHIntroductionViewController.h"

static  NSString  *kViewControllerTitle = @"Interval Tapping";

static  NSString  *kIntroHeadingCaption = @"Tests for Bradykinesia";

@interface APHSevenDayFitnessIntroStepViewController () <APHIntroductionViewControllerDelegate>

@property (nonatomic, strong) APHIntroductionViewController *instructionsController;

@property (nonatomic, weak) IBOutlet UILabel  *introHeadingCaption;
@property (nonatomic, weak) IBOutlet UIView   *instructionsContainer;
@property (nonatomic, weak) IBOutlet UIButton *getStartedButton;

@property (nonatomic, strong) NSArray *instructionalParagraphs;

@end

@implementation APHSevenDayFitnessIntroStepViewController

#pragma  mark  -  Initialisation

+ (void)initialize
{
    kIntroHeadingCaption = NSLocalizedString(@"7 Day Fitness Test", nil);
}

#pragma  mark  -  Actions

- (IBAction)getStartedWasTapped:(id)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKStepViewControllerNavigationDirectionForward];
        }
    }
}

- (void)cancelButtonTapped:(id)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidCancel:)] == YES) {
            [self.delegate stepViewControllerDidCancel:self];
        }
    }
}

#pragma mark - Lifecycle

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSArray  *introImageNames = @[@"6minwalk", @"Updated-Data-Cardio"];
    
    NSArray  *paragraphs = @[
                             NSLocalizedString(@"During the next week, your fitness allocation will be monitored, analyed, and available to you in real time.",
                                               @"During the next week, your fitness allocation will be monitored, analyed, and available to you in real time."),
                             NSLocalizedString(@"To ensure the accuracy of this task, keep your phone on you at all times.",
                                               @"To ensure the accuracy of this task, keep your phone on you at all times.")
                             ];
    
    self.introHeadingCaption.text = NSLocalizedString(@"7 Day Fitness Allocation", @"7 Day Fitness Allocation");
    
    self.instructionsController = [[APHIntroductionViewController alloc] initWithNibName:nil bundle:nil];
    [self.instructionsController.view setFrame:self.instructionsContainer.bounds];
    [self.instructionsContainer addSubview:self.instructionsController.view];
    [self.instructionsController setDelegate:self];

    [self.instructionsController.view layoutIfNeeded];
    [self.instructionsController setupWithInstructionalImages:introImageNames andParagraphs:paragraphs];
}


- (void)viewDidLoad
{

    [super viewDidLoad];
    
    self.title = kViewControllerTitle;
    [self.getStartedButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = kViewControllerTitle;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.title = kViewControllerTitle;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//- (void)viewImportantDetailsSelected:(APHIntroductionViewController *)introductionViewController {
//    NSLog(@"clicky");
//    
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"APHImportantDetailsTableViewController" bundle:nil];
//    UITableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"APHImportantDetailsTableViewController"];
//    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    
//    
//    
//    [self presentViewController:vc animated:YES completion:NULL];
//}

@end
