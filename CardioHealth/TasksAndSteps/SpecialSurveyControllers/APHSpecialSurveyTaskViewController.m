//
//  APHSpecialSurveyTaskViewController.m

//
//  Created by Henry McGilton on 9/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSpecialSurveyTaskViewController.h"

static NSString *MainStudyIdentifier = @"com.specialSurvey.sleepSurvey";

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
    RKTask * task = [scheduledTask.task rkTask];
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
- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKResult *)result {
    
    NSLog(@"didProduceResult = %@", result);
    
    if ([result isKindOfClass:[RKSurveyResult class]]) {
        RKSurveyResult* sresult = (RKSurveyResult*)result;
        
        for (RKQuestionResult* qr in sresult.surveyResults) {
            NSLog(@"%@ = [%@] %@ ", [[qr itemIdentifier] stringValue], [qr.answer class], qr.answer);
        }
    }
    
    
    [self sendResult:result];
    
    [super taskViewController:taskViewController didProduceResult:result];
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
    
    [super taskViewControllerDidComplete:taskViewController];
}


@end
