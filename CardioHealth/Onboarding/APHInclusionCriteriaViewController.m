//
//  APHInclusionCriteriaViewController.m
//  Parkinson
//
//  Created by Ramsundar Shandilya on 9/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//



#import "APHInclusionCriteriaViewController.h"
#import "APHSignUpGeneralInfoViewController.h"

static NSInteger kDatePickerCellRow = 3;

@interface APHInclusionCriteriaViewController () <APCSegmentedButtonDelegate>

//Outlets
@property (weak, nonatomic) IBOutlet UILabel *question1Label;
@property (weak, nonatomic) IBOutlet UILabel *question2Label;
@property (weak, nonatomic) IBOutlet UILabel *question3Label;
@property (weak, nonatomic) IBOutlet UILabel *question4Label;

@property (weak, nonatomic) IBOutlet UIButton *question1Option1;
@property (weak, nonatomic) IBOutlet UIButton *question1Option2;

@property (weak, nonatomic) IBOutlet UIButton *question2Option1;
@property (weak, nonatomic) IBOutlet UIButton *question2Option2;
@property (weak, nonatomic) IBOutlet UIButton *question2Option3;

@property (weak, nonatomic) IBOutlet UIButton *question4Option1;
@property (weak, nonatomic) IBOutlet UIButton *question4Option2;
@property (weak, nonatomic) IBOutlet UIButton *question4Option3;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *datePickerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dateTitleCell;

//Properties
@property (nonatomic, strong) NSArray * questions; //Of APCSegmentedButtons

@property (nonatomic, strong) NSDate* diagnosisDate;
@property (nonatomic, getter = isDateOpen) BOOL dateOpen;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation APHInclusionCriteriaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.questions = @[
                       [[APCSegmentedButton alloc] initWithButtons:@[self.question1Option1, self.question1Option2] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appPrimaryColor]],
                       [[APCSegmentedButton alloc] initWithButtons:@[self.question2Option1, self.question2Option2, self.question2Option3] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appPrimaryColor]],
                       [[APCSegmentedButton alloc] initWithButtons:@[self.question4Option1, self.question4Option2, self.question4Option3] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appPrimaryColor]]
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
    self.question3Label.textColor = [UIColor appSecondaryColor1];
    self.question4Label.textColor = [UIColor appSecondaryColor1];
    
    self.dateLabel.textColor = [UIColor appSecondaryColor3];
    self.dateLabel.font = [UIFont appRegularFontWithSize:16];
    self.dateLabel.text = NSLocalizedString(@"Enter Date", "");
    
    self.question2Option3.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.question2Option3.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.question2Option3 setTitle:NSLocalizedString(@"Not\nSure", @"Question Option") forState:UIControlStateNormal];
}

- (void)startSignUp
{
    APHSignUpGeneralInfoViewController *signUpVC = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpGeneralInfoVC"];
    [self.navigationController pushViewController:signUpVC animated:YES];

}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == kDatePickerCellRow && !self.isDateOpen){
        return 0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView beginUpdates];
    if (cell == self.dateTitleCell) {
        self.dateOpen = !self.isDateOpen;
        if (self.dateOpen) {
            if (self.diagnosisDate) {
                self.datePicker.date = self.diagnosisDate;
            }
            else
            {
                self.diagnosisDate = self.datePicker.date;
                self.dateLabel.text = [self.dateFormatter stringFromDate:self.datePicker.date];
            }
        }
    }
    [self.tableView endUpdates];
    if (cell == self.dateTitleCell) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (IBAction)datePickerChanged:(UIDatePicker*)sender
{
    self.diagnosisDate = sender.date;
    self.dateLabel.text = [self.dateFormatter stringFromDate:sender.date];
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
    //TODO: Remove comments in Dev branch
//#ifdef DEVELOPMENT
//        APHSignUpGeneralInfoViewController *signUpVC = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpGeneralInfoVC"];
//        [self.navigationController pushViewController:signUpVC animated:YES];
//#else
    if ([self isEligible]) {
        
        [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"EligibleVC"] animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"InEligibleVC"] animated:YES];
    }
//#endif
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
    if (!self.diagnosisDate) {
        retValue = NO;
    }
    
    return retValue;
#endif
}

@end
