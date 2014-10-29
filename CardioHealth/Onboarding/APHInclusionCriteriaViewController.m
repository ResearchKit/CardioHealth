//
//  APHInclusionCriteriaViewController.m
//  Parkinson
//
//  Created by Ramsundar Shandilya on 9/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//



#import "APHInclusionCriteriaViewController.h"
#import "APHSignUpGeneralInfoViewController.h"

@interface APHInclusionCriteriaViewController () <APCSegmentedButtonDelegate>

//Outlets
@property (weak, nonatomic) IBOutlet UILabel *question1Label;
@property (weak, nonatomic) IBOutlet UILabel *question2Label;

@property (weak, nonatomic) IBOutlet UIButton *question1Option1;
@property (weak, nonatomic) IBOutlet UIButton *question1Option2;

@property (weak, nonatomic) IBOutlet UIButton *question2Option1;
@property (weak, nonatomic) IBOutlet UIButton *question2Option2;

//Properties
@property (nonatomic, strong) NSArray * questions; //Of APCSegmentedButtons

@end

@implementation APHInclusionCriteriaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.questions = @[
                       [[APCSegmentedButton alloc] initWithButtons:@[self.question1Option1, self.question1Option2] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appPrimaryColor]],
                       [[APCSegmentedButton alloc] initWithButtons:@[self.question2Option1, self.question2Option2] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appPrimaryColor]],
                       ];
    [self.questions enumerateObjectsUsingBlock:^(APCSegmentedButton * obj, NSUInteger idx, BOOL *stop) {
        obj.delegate = self;
    }];
    [self setUpAppearance];
}

- (void) setUpAppearance
{
    self.question1Label.textColor = [UIColor appSecondaryColor1];
    self.question2Label.textColor = [UIColor appSecondaryColor1];
}

- (void)startSignUp
{
    APHSignUpGeneralInfoViewController *signUpVC = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpGeneralInfoVC"];
    [self.navigationController pushViewController:signUpVC animated:YES];

}

/*********************************************************************************/
#pragma mark - Misc Fix
/*********************************************************************************/
-(void)viewDidLayoutSubviews
{
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

/*********************************************************************************/
#pragma mark - Segmented Button Delegate
/*********************************************************************************/
- (void)segmentedButtonPressed:(UIButton *)button selectedIndex:(NSInteger)selectedIndex
{
    self.navigationItem.rightBarButtonItem.enabled = [self isContentValid];
}

/*********************************************************************************/
#pragma mark - Overridden methods
/*********************************************************************************/

- (void)next
{
#if DEVELOPMENT
    if (YES) {
#else
    if (((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.parameters.hideConsent) {
#endif
        APHSignUpGeneralInfoViewController *signUpVC = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpGeneralInfoVC"];
        [self.navigationController pushViewController:signUpVC animated:YES];
    }
    else
    {
        if ([self isEligible]) {
            
            [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"EligibleVC"] animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"InEligibleVC"] animated:YES];
        }
    }
}

- (BOOL) isEligible
{
    BOOL retValue = YES;
    APCSegmentedButton * question2Button = self.questions[1];
    if (question2Button.selectedIndex == 1) {
        retValue = NO;
    }
    return retValue;
}

- (BOOL)isContentValid
{
#ifdef DEVELOPMENT
    return YES;
#else
    __block BOOL retValue = YES;
    [self.questions enumerateObjectsUsingBlock:^(APCSegmentedButton* obj, NSUInteger idx, BOOL *stop) {
        if (obj.selectedIndex == -1) {
            retValue = NO;
            *stop = YES;
        }
    }];
    return retValue;
#endif
}

@end
