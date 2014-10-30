//
//  APHFitnessTestIntroStepViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/23/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHFitnessTestIntroStepViewController.h"
#import "APHIntroductionViewController.h"

static  NSString  *kViewControllerTitle = @"Interval Tapping";

static  NSString  *kIntroHeadingCaption = @"Tests for Bradykinesia";

@interface APHFitnessTestIntroStepViewController ()

@property  (nonatomic, strong)          APHIntroductionViewController  *instructionsController;
@property  (nonatomic, weak)  IBOutlet  UILabel  *introHeadingCaption;
@property  (nonatomic, weak)  IBOutlet  UIView   *instructionsContainer;

@property  (nonatomic, strong)          NSArray  *instructionalParagraphs;

@property  (nonatomic, weak)  IBOutlet  UILabel  *tapGetStarted;

//@property (weak, nonatomic) IBOutlet RKBoldTextCell *getStartedView;

@end

@implementation APHFitnessTestIntroStepViewController

#pragma  mark  -  Initialisation

+ (void)initialize
{
    kIntroHeadingCaption = NSLocalizedString(@"Fitness Test", nil);
}

#pragma  mark  -  Button Action Methods

- (IBAction)getStartedWasTapped:(id)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKStepViewControllerNavigationDirectionForward];
        }
    }
}

#pragma  mark  -  View Controller Methods

- (void)cancelButtonTapped:(id)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidCancel:)] == YES) {
            [self.delegate stepViewControllerDidCancel:self];
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSArray  *introImageNames = @[ @"6minwalk", @"6minwalk-Icon-1", @"6minwalk-Icon-2", @"Data-Analysis-Icon"];
    
    NSArray  *paragraphs = @[
                             @"Once you tap Get Started, you will have 5 seconds until this test begins tracking your movements.",
                             @"Begin walking at your fastest possible pace for 6 minutes.",
                             @"After 6 minutes expires, sit down and rest for 3 minutes.",
                             @"After the test is finished, your results will be analyzed and available on the dashboard. You will be notified when analysis is ready."
                             ];
    
    self.introHeadingCaption.text = kIntroHeadingCaption;
    
    self.instructionsController = [[APHIntroductionViewController alloc] initWithNibName:nil bundle:nil];
    [self.instructionsContainer addSubview:self.instructionsController.view];
    [self.instructionsController setupWithInstructionalImages:introImageNames andParagraphs:paragraphs];
}


- (void)viewDidLoad
{

    [super viewDidLoad];
    
    self.title = kViewControllerTitle;
    

    
   
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

@end
