//
//  SignUpGeneralInfoViewController.m
//  OnBoarding
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSignUpGeneralInfoViewController.h"
#import "APHSignUpMedicalInfoViewController.h"

#define DEMO 0


@interface APHSignUpGeneralInfoViewController ()

@property (nonatomic, strong) APCPermissionsManager *permissionManager;
@property (nonatomic) BOOL permissionGranted;
@property (weak, nonatomic) IBOutlet APCPermissionButton *permissionButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButton;
@end

@implementation APHSignUpGeneralInfoViewController


#pragma mark - View Life Cycle

- (void) viewDidLoad {
    [super viewDidLoad];

    [self setupNavigationItems];
    [self prepareFields];
    
    self.permissionButton.unconfirmedTitle = NSLocalizedString(@"I agree to the Terms and Conditions", @"");
    self.permissionButton.confirmedTitle = NSLocalizedString(@"I agree to the Terms and Conditions", @"");
    
    //TODO: This permission request is temporary. Remove later.
    self.permissionManager = [[APCPermissionsManager alloc] init];
    
    [APCPermissionsManager setHealthKitTypesToRead:@[HKQuantityTypeIdentifierBodyMass, HKQuantityTypeIdentifierHeight, HKQuantityTypeIdentifierStepCount, HKQuantityTypeIdentifierHeartRate, HKQuantityTypeIdentifierDistanceWalkingRunning, HKQuantityTypeIdentifierFlightsClimbed, HKQuantityTypeIdentifierDistanceCycling]];
    [APCPermissionsManager setHealthKitTypesToWrite:@[HKQuantityTypeIdentifierBodyMass, HKQuantityTypeIdentifierHeight]];
    
    [self.permissionManager requestForPermissionForType:kSignUpPermissionsTypeHealthKit withCompletion:^(BOOL granted, NSError *error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.permissionGranted = YES;
                [self prepareFields];
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)setupAppearance
{
    [super setupAppearance];
}

- (void)setupNavigationItems
{
    self.nextBarButton.enabled = NO;
    
    UIBarButtonItem *hiddenButton = [[UIBarButtonItem alloc] initWithTitle:@"   " style:UIBarButtonItemStylePlain target:self action:@selector(secretButton)];
    
    [self.navigationItem setRightBarButtonItems:@[self.nextBarButton, hiddenButton]];
}

- (void) prepareFields {
    NSMutableArray *items = [NSMutableArray new];
    NSMutableArray *itemsOrder = [NSMutableArray new];
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Password", @"");
        field.placeholder = NSLocalizedString(@"Add Password", @"");
        field.secure = YES;
        field.keyboardType = UIKeyboardTypeDefault;
        field.returnKeyType = UIReturnKeyNext;
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.identifier = kAPCTextFieldTableViewCellIdentifier;
        
        [items addObject:field];
        
        [itemsOrder addObject:@(APCSignUpUserInfoItemPassword)];
    }
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Email", @"");
        field.placeholder = NSLocalizedString(@"Add Email Address", @"");
        field.keyboardType = UIKeyboardTypeEmailAddress;
        field.returnKeyType = UIReturnKeyNext;
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.identifier = kAPCTextFieldTableViewCellIdentifier;
        
        [items addObject:field];
        
        [itemsOrder addObject:@(APCSignUpUserInfoItemEmail)];
    }
    
    {
        APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"Birthdate", @"");
        field.placeholder = NSLocalizedString(@"MMMM DD, YYYY", @"");
        //        if (self.permissionGranted) {
        //            field.date = self.user.birthDate;
        //        }
        field.datePickerMode = UIDatePickerModeDate;
        field.identifier = kAPCDefaultTableViewCellIdentifier;
        
        [items addObject:field];
        
        [itemsOrder addObject:@(APCSignUpUserInfoItemDateOfBirth)];
    }
    
    {
        APCTableViewSegmentItem *field = [APCTableViewSegmentItem new];
        field.style = UITableViewCellStyleValue1;
        field.segments = [APCUser sexTypesInStringValue];
        //        if (self.permissionGranted) {
        //            field.selectedIndex = [APCUser stringIndexFromSexType:self.user.biologicalSex];
        //        }
        field.identifier = kAPCSegmentedTableViewCellIdentifier;
        
        [items addObject:field];
        
        [itemsOrder addObject:@(APCSignUpUserInfoItemGender)];
    }
    
    
    self.items = items;
    self.itemsOrder = itemsOrder;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [super textFieldShouldReturn:textField];
    
    [self.nextBarButton setEnabled:[self isContentValid:nil]];
    
    return YES;
}


#pragma mark - APCPickerTableViewCellDelegate methods

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell datePickerValueChanged:(NSDate *)date
{
    [super pickerTableViewCell:cell datePickerValueChanged:date];
}

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell pickerViewDidSelectIndices:(NSArray *)selectedIndices
{
    [super pickerTableViewCell:cell pickerViewDidSelectIndices:selectedIndices];
}

#pragma mark - APCTextFieldTableViewCellDelegate methods

- (void)textFieldTableViewCellDidBecomeFirstResponder:(APCTextFieldTableViewCell *)cell
{
    [super textFieldTableViewCellDidBecomeFirstResponder:cell];
}

- (void)textFieldTableViewCellDidReturn:(APCTextFieldTableViewCell *)cell
{
    [super textFieldTableViewCellDidReturn:cell];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewTextFieldItem *item = self.items[indexPath.row];
    if ([self.itemsOrder[indexPath.row] integerValue] == APCSignUpUserInfoItemPassword) {
        if ([[(APCTableViewTextFieldItem *)item value] length] == 0) {
            [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:NSLocalizedString(@"Please give a valid Password", @"")];
        }
        else if ([[(APCTableViewTextFieldItem *)item value] length] < 6) {
            [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:NSLocalizedString(@"Password should be at least 6 characters", @"")];
        }
    }
    else if ([self.itemsOrder[indexPath.row] integerValue] == APCSignUpUserInfoItemEmail) {
        if (![item.value isValidForRegex:kAPCGeneralInfoItemEmailRegEx]) {
            [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:NSLocalizedString(@"Please give a valid email address", @"")];
        }
        
    }
    
    self.nextBarButton.enabled = [self isContentValid:nil];

}

#pragma mark - APCSegmentedTableViewCellDelegate methods

- (void)segmentedTableViewcell:(APCSegmentedTableViewCell *)cell didSelectSegmentAtIndex:(NSInteger)index
{
    [super segmentedTableViewcell:cell didSelectSegmentAtIndex:index];
}

#pragma mark - Private Methods

- (BOOL) isContentValid:(NSString **)errorMessage {

    BOOL isContentValid = [super isContentValid:errorMessage];

    if (isContentValid) {
        
        for (int i = 0; i < self.itemsOrder.count; i++) {
            NSNumber *order = self.itemsOrder[i];
            
            APCTableViewItem *item = self.items[i];
            
            switch (order.integerValue) {
                    
                case APCSignUpUserInfoItemUserName:
                    isContentValid = [[(APCTableViewTextFieldItem *)item value] isValidForRegex:kAPCGeneralInfoItemUserNameRegEx];
                    if (errorMessage) {
                        *errorMessage = NSLocalizedString(@"Please enter valid Username.", @"");
                    }
                    break;
                    
                case APCSignUpUserInfoItemPassword:
                    if ([[(APCTableViewTextFieldItem *)item value] length] == 0) {
                        isContentValid = NO;
                        
                        if (errorMessage) {
                            *errorMessage = NSLocalizedString(@"Please enter a Password.", @"");
                        }
                    }
                    else if ([[(APCTableViewTextFieldItem *)item value] length] < 6) {
                        isContentValid = NO;
                        
                        if (errorMessage) {
                            *errorMessage = NSLocalizedString(@"Password should be at least 6 characters.", @"");
                        }
                    }
                    break;
                    
                case APCSignUpUserInfoItemEmail:
                    isContentValid = [[(APCTableViewTextFieldItem *)item value] isValidForRegex:kAPCGeneralInfoItemEmailRegEx];
                    
                    if (errorMessage) {
                        *errorMessage = NSLocalizedString(@"Please enter a valid email address.", @"");
                    }
                    break;
                    
                default:
//#warning ASSERT_MESSAGE Require
                    NSAssert(order.integerValue <= APCSignUpUserInfoItemWakeUpTime, @"ASSER_MESSAGE");
                    break;
            }
            
            // If any of the content is not valid the break the for loop
            // We doing this 'break' here because we cannot break a for loop inside switch-statements (switch already have break statement)
            if (!isContentValid) {
                break;
            }
        }
    }
    
    return isContentValid;
}

- (void) loadProfileValuesInModel {
    
    if (self.tableView.tableHeaderView) {
        self.user.name = self.nameTextField.text;
        self.user.userName = self.userNameTextField.text;
    }
    
    for (int i = 0; i < self.itemsOrder.count; i++) {
        NSNumber *order = self.itemsOrder[i];
        
        APCTableViewItem *item = self.items[i];
        
        switch (order.integerValue) {
                
            case APCSignUpUserInfoItemPassword:
                self.user.password = [(APCTableViewTextFieldItem *)item value];
                break;
                
            case APCSignUpUserInfoItemEmail:
                self.user.email = [(APCTableViewTextFieldItem *)item value];
                break;
            case APCSignUpUserInfoItemGender:{
                
            }
                break;
                
            default:
            {
                //Do nothing for some types as they are readonly attributes
            }
                break;
        }
    }
}

- (void) validateContent {
    [self.tableView endEditing:YES];
    
    NSString *message;
    if ([self isContentValid:&message]) {
        [self loadProfileValuesInModel];
        [self next];
    }
    else {
        [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:message];
    }
}

#pragma mark - IBActions

- (IBAction)termsAndConditions:(UIButton *)sender
{
    [self.permissionButton setSelected:!sender.selected];
}

- (void) secretButton
{
    self.nameTextField.text = @"John Appleseed";
    
    NSUInteger randomInteger = arc4random();
    
    self.userNameTextField.text = [NSString stringWithFormat:@"test_%@", @(randomInteger)];
    
    for (int i = 0; i < self.itemsOrder.count; i++) {
        NSNumber *order = self.itemsOrder[i];
        
        APCTableViewTextFieldItem *item = self.items[i];
        
        switch (order.integerValue) {
            case APCSignUpUserInfoItemPassword:
                item.value = @"Password123";
                break;
                
            case APCSignUpUserInfoItemEmail:
                item.value = [NSString stringWithFormat:@"dhanush.balachandran+%@@ymedialabs.com", @(randomInteger)];
                break;
                
            default:
            {
                //Do nothing for some types
            }
                break;
        }
        [self.tableView reloadData];
    }
    [self.nextBarButton setEnabled:[self isContentValid:nil]];
}

- (IBAction)next
{
    NSString *error;
    
    if ([self isContentValid:&error]) {
        
        [self loadProfileValuesInModel];
        
        APHSignUpMedicalInfoViewController *medicalInfoViewController =  [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpMedicalInfoVC"];
        medicalInfoViewController.user = self.user;
        
        [self.navigationController pushViewController:medicalInfoViewController animated:YES];
    } else{
        [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:error];
    }
    
}

- (IBAction)cancel:(id)sender
{
    
}

@end
