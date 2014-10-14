//
//  APHSpecialSurveyTaskViewController.m

//
//  Created by Henry McGilton on 9/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSpecialSurveyTaskViewController.h"

static NSString *MainStudyIdentifier = @"com.ymedialabs.sleepSurvey";

@interface APHSpecialSurveyTaskViewController ()
@property (strong, nonatomic) RKDataArchive *taskArchive;
@end

@implementation APHSpecialSurveyTaskViewController

/*********************************************************************************/
#pragma  mark  -  View Controller Methods
/*********************************************************************************/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self beginTask];
}

/*********************************************************************************/
#pragma  mark  -  Initialisation
/*********************************************************************************/
+ (RKTask *)createTask: (APCScheduledTask*) scheduledTask
{
    RKTask * task = [scheduledTask.task generateRKTaskFromTaskDescription];
    return  task;
}

- (instancetype)initWithTask:(id<RKLogicalTask>)task taskInstanceUUID:(NSUUID *)taskInstanceUUID
{
    self = [super initWithTask:task taskInstanceUUID:taskInstanceUUID];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*********************************************************************************/
#pragma  mark  - Private methods
/*********************************************************************************/

- (void)beginTask
{
    if (self.taskArchive)
    {
        [self.taskArchive resetContent];
    }
    
    self.taskArchive = [[RKDataArchive alloc] initWithItemIdentifier:[RKItemIdentifier itemIdentifierForTask:self.task] studyIdentifier:MainStudyIdentifier taskInstanceUUID:self.taskInstanceUUID extraMetadata:nil fileProtection:RKFileProtectionCompleteUnlessOpen];
    
}

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/

-(void)sendResult:(RKResult*)result
{
    // In a real application, consider adding to the archive on a concurrent queue.
    NSError *err = nil;
    if (![result addToArchive:self.taskArchive error:&err])
    {
        // Error adding the result to the archive; archive may be invalid. Tell
        // the user there's been a problem and stop the task.
        NSLog(@"Error adding %@ to archive: %@", result, err);
    }
}


/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/
- (void)taskViewController:(RKTaskViewController *)taskViewController
willPresentStepViewController:(RKStepViewController *)stepViewController{
    
//    if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep101]) {
//        UIView* customView = [UIView new];
//        customView.backgroundColor = [UIColor cyanColor];
//        
//        // Have the custom view request the space it needs.
//        // A little tricky because we need to let it size to fit if there's not enough space.
//        [customView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[c(>=160)]" options:0 metrics:nil views:@{@"c":customView}];
//        for (NSLayoutConstraint *constraint in verticalConstraints)
//        {
//            constraint.priority = UILayoutPriorityFittingSizeLevel;
//        }
//        [customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=280)]" options:0 metrics:nil views:@{@"c":customView}]];
//        [customView addConstraints:verticalConstraints];
//        
//        [(RKActiveStepViewController*)stepViewController setCustomView:customView];
//        
//        // Set custom button on navi bar
//        stepViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Custom button"
//                                                                                               style:UIBarButtonItemStylePlain
//                                                                                              target:nil
//                                                                                              action:nil];
//        
//        
//        
//        stepViewController.learnMoreButton =[[UIBarButtonItem alloc] initWithTitle:@"View Important Details" style:stepViewController.continueButton.style target:self action:@selector(importantDetails:)];
//        
//        
//        
//        
//        
//        stepViewController.continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Get Started" style:stepViewController.continueButton.style target:stepViewController.continueButton.target action:stepViewController.continueButton.action];
//        
//        //        [stepViewController.continueButton.tintColor = UIColor colorWithRed:0.83 green:0.43 blue:0.57 alpha:1];
//        
//        
//        stepViewController.skipButton = nil;
//        
//    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep102]) {
//        
//        stepViewController.continueButton = nil;
//        stepViewController.skipButton = nil;
//        
//    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep103]) {
//        
//        stepViewController.continueButton = nil;
//        stepViewController.skipButton = nil;
//        
//    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep104]) {
//        
//        stepViewController.continueButton = nil;
//        stepViewController.skipButton = nil;
//        
//    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep105]) {
//        
//        stepViewController.continueButton = nil;
//        stepViewController.skipButton = nil;
//        
//    }else if ([stepViewController.step.identifier isEqualToString:kFitnessTestStep106]) {
//        
//        stepViewController.continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Well done!" style:stepViewController.continueButton.style target:stepViewController.continueButton.target action:stepViewController.continueButton.action];
//        
//    }
}

- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKResult *)result {
    NSLog(@"didProduceResult = %@", result);
    
    if ([result isKindOfClass:[RKSurveyResult class]]) {
        RKSurveyResult* sresult = (RKSurveyResult*)result;
        
        for (RKQuestionResult* qr in sresult.surveyResults) {
            NSLog(@"%@ = [%@] %@ ", [[qr itemIdentifier] stringValue], [qr.answer class], qr.answer);
        }
    }
    
    
    [self sendResult:result];
}

- (void)taskViewControllerDidFail: (RKTaskViewController *)taskViewController withError:(NSError*)error{
    
    [self.taskArchive resetContent];
    self.taskArchive = nil;
    
}

- (void)taskViewControllerDidCancel:(RKTaskViewController *)taskViewController{
    
    [taskViewController suspend];
    
    [self.taskArchive resetContent];
    self.taskArchive = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewControllerDidComplete: (RKTaskViewController *)taskViewController{
    
    [taskViewController suspend];
    
    NSError *err = nil;
    NSURL *archiveFileURL = [self.taskArchive archiveURLWithError:&err];
    if (archiveFileURL)
    {
        NSURL *documents = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        NSURL *outputUrl = [documents URLByAppendingPathComponent:[archiveFileURL lastPathComponent]];
        
        // This is where you would queue the archive for upload. In this demo, we move it
        // to the documents directory, where you could copy it off using iTunes, for instance.
        [[NSFileManager defaultManager] moveItemAtURL:archiveFileURL toURL:outputUrl error:nil];
        
        NSLog(@"outputUrl= %@", outputUrl);
        
        // When done, clean up:
        self.taskArchive = nil;
        if (archiveFileURL)
        {
            [[NSFileManager defaultManager] removeItemAtURL:archiveFileURL error:nil];
        }
    }
    
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
