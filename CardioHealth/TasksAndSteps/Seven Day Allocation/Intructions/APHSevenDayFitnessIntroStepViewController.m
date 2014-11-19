//
//  APHSevenDayFitnessIntroStepViewController.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSevenDayFitnessIntroStepViewController.h"
#import "APHIntroductionViewController.h"

@interface APHSevenDayFitnessIntroStepViewController () <APHIntroductionViewControllerDelegate>

@property (nonatomic, strong) APHIntroductionViewController *instructionsController;

@property (nonatomic, weak) IBOutlet UILabel  *introHeadingCaption;
@property (nonatomic, weak) IBOutlet UIView   *instructionsContainer;
@property (nonatomic, weak) IBOutlet UIButton *btnGetStarted;

@property (nonatomic, strong) NSArray *instructionalParagraphs;

@end

@implementation APHSevenDayFitnessIntroStepViewController

#pragma  mark  -  Actions

- (IBAction)handleGetStarted:(UIButton *)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKStepViewControllerNavigationDirectionForward];
        }
    }
}

- (void)handleCancel:(id)sender
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
    
    NSArray  *introImageNames = @[@"tutorial-1", @"tutorial-2"];
    
    NSArray  *paragraphs = @[
                             NSLocalizedString(@"During the next week, your fitness allocation will be monitored, analyzed, and available to you in real time.",
                                               @"During the next week, your fitness allocation will be monitored, analyzed, and available to you in real time."),
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
    
    [self.btnGetStarted setBackgroundColor:[UIColor appPrimaryColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(handleCancel:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
