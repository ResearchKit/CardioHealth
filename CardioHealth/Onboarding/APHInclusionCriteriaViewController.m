// 
//  APHInclusionCriteriaViewController.m 
//  MyHeart Counts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 


#import "APHInclusionCriteriaViewController.h"
#import "APHAppDelegate.h"

@interface APHInclusionCriteriaViewController () <APCSegmentedButtonDelegate>

//Outlets
@property (weak, nonatomic) IBOutlet UILabel *question1Label;
@property (weak, nonatomic) IBOutlet UIButton *question1Option1;
@property (weak, nonatomic) IBOutlet UIButton *question1Option2;

@property (weak, nonatomic) IBOutlet UILabel *question2Label;
@property (weak, nonatomic) IBOutlet UIButton *question2Option1;
@property (weak, nonatomic) IBOutlet UIButton *question2Option2;

@property (weak, nonatomic) IBOutlet UILabel *question3Label;
@property (weak, nonatomic) IBOutlet UIButton *question3Option1;
@property (weak, nonatomic) IBOutlet UIButton *question3Option2;

//Properties
@property (nonatomic, strong) NSArray * questions; //Of APCSegmentedButtons

@end

@implementation APHInclusionCriteriaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.questions = @[
                       [[APCSegmentedButton alloc] initWithButtons:@[self.question1Option1, self.question1Option2] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appPrimaryColor]],
                       [[APCSegmentedButton alloc] initWithButtons:@[self.question2Option1, self.question2Option2] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appPrimaryColor]],
                       [[APCSegmentedButton alloc] initWithButtons:@[self.question3Option1, self.question3Option2] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appPrimaryColor]],
                       ];
    [self.questions enumerateObjectsUsingBlock:^(APCSegmentedButton * obj, NSUInteger __unused idx, BOOL * __unused stop) {
        obj.delegate = self;
    }];
    [self setUpAppearance];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void) setUpAppearance
{
    {
        self.question1Label.textColor = [UIColor blackColor];
        self.question1Label.font = [UIFont appRegularFontWithSize:17.0f];
        
        [self.question1Option1.titleLabel setFont:[UIFont appRegularFontWithSize:44.0]];
        [self.question1Option2.titleLabel setFont:[UIFont appRegularFontWithSize:44.0]];
    }
    
    {
        self.question2Label.textColor = [UIColor blackColor];
        self.question2Label.font = [UIFont appRegularFontWithSize:17.0f];
        
        [self.question2Option1.titleLabel setFont:[UIFont appRegularFontWithSize:44.0]];
        [self.question2Option2.titleLabel setFont:[UIFont appRegularFontWithSize:44.0]];
    }
    
    {
        self.question3Label.textColor = [UIColor blackColor];
        self.question3Label.font = [UIFont appRegularFontWithSize:17.0f];
        
        [self.question3Option1.titleLabel setFont:[UIFont appRegularFontWithSize:44.0]];
        [self.question3Option2.titleLabel setFont:[UIFont appRegularFontWithSize:44.0]];
    }
    
}

- (APCOnboarding *)onboarding
{
    return ((APHAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

/*********************************************************************************/
#pragma mark - Misc Fix
/*********************************************************************************/
-(void)viewDidLayoutSubviews
{
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
}

-(void)tableView:(UITableView *) __unused tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

/*********************************************************************************/
#pragma mark - Segmented Button Delegate
/*********************************************************************************/
- (void)segmentedButtonPressed:(UIButton *) __unused button selectedIndex:(NSInteger) __unused selectedIndex
{
    self.navigationItem.rightBarButtonItem.enabled = [self isContentValid];
    
}

/*********************************************************************************/
#pragma mark - Overridden methods
/*********************************************************************************/

- (void)next
{
    [self onboarding].onboardingTask.eligible = [self isEligible];
    
    UIViewController *viewController = [[self onboarding] nextScene];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL) isEligible
{
    BOOL retValue = YES;
    
    APCSegmentedButton * question1 = self.questions[0];
    APCSegmentedButton * question2 = self.questions[1];
    APCSegmentedButton * question3 = self.questions[2];
    
    if ((question1.selectedIndex == 1) ||
        (question2.selectedIndex == 1) ||
        (question3.selectedIndex == 1)) {
        retValue = NO;
    }
    return retValue;
}

- (BOOL)isContentValid
{
    __block BOOL retValue = YES;
    [self.questions enumerateObjectsUsingBlock:^(APCSegmentedButton* obj, NSUInteger __unused idx, BOOL *stop) {
    if (obj.selectedIndex == -1) {
        retValue = NO;
        *stop = YES;
    }
    }];
    return retValue;
}

@end
