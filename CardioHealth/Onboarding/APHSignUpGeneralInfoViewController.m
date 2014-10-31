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


@interface APHSignUpGeneralInfoViewController () <APCTermsAndConditionsViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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
    self.permissionButton.attributed = NO;
    self.permissionButton.alignment = kAPCPermissionButtonAlignmentLeft;
    
    //TODO: This permission request is temporary. Remove later.
    self.permissionManager = [[APCPermissionsManager alloc] init];
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
    
#if DEVELOPMENT
    UIBarButtonItem *hiddenButton = [[UIBarButtonItem alloc] initWithTitle:@"   " style:UIBarButtonItemStylePlain target:self action:@selector(secretButton)];
    
    [self.navigationItem setRightBarButtonItems:@[self.nextBarButton, hiddenButton]];
#endif
}

- (void) prepareFields {
    NSMutableArray *items = [NSMutableArray new];
    NSMutableArray *itemsOrder = [NSMutableArray new];
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Password", @"");
        field.placeholder = NSLocalizedString(@"add password", @"");
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
        field.placeholder = NSLocalizedString(@"add email", @"");
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
        field.placeholder = NSLocalizedString(@"add birthdate", @"");
        if (self.permissionGranted && self.user.birthDate) {
            field.date = self.user.birthDate;
            field.detailText = [field.date toStringWithFormat:field.dateFormat];
            field.editable = NO;
        }
        field.datePickerMode = UIDatePickerModeDate;
        field.identifier = kAPCDefaultTableViewCellIdentifier;
    
        [items addObject:field];
        
        [itemsOrder addObject:@(APCSignUpUserInfoItemDateOfBirth)];
    }
    
    {
        APCTableViewSegmentItem *field = [APCTableViewSegmentItem new];
        field.style = UITableViewCellStyleValue1;
        field.segments = [APCUser sexTypesInStringValue];
        if (self.permissionGranted && self.user.biologicalSex) {
            field.selectedIndex = [APCUser stringIndexFromSexType:self.user.biologicalSex];
            field.editable = NO;
        }
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.nextBarButton setEnabled:[self isContentValid:nil]];
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

- (void)textFieldTableViewCellDidEndEditing:(APCTextFieldTableViewCell *)cell
{
    [super textFieldTableViewCellDidEndEditing:cell];
    
    self.nextBarButton.enabled = [self isContentValid:nil];
}

- (void)textFieldTableViewCell:(APCTextFieldTableViewCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [super textFieldTableViewCell:cell shouldChangeCharactersInRange:range replacementString:string];
    
    self.nextBarButton.enabled = [self isContentValid:nil];
}

- (void)textFieldTableViewCellDidReturn:(APCTextFieldTableViewCell *)cell
{
    [super textFieldTableViewCellDidReturn:cell];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewTextFieldItem *item = self.items[indexPath.row];
    if ([self.itemsOrder[indexPath.row] integerValue] == APCSignUpUserInfoItemPassword) {
        if ([[(APCTableViewTextFieldItem *)item value] length] == 0) {
            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:@"Please give a valid Password"];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if ([[(APCTableViewTextFieldItem *)item value] length] < 6) {
            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:@"Password should be at least 6 characters"];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else if ([self.itemsOrder[indexPath.row] integerValue] == APCSignUpUserInfoItemEmail) {
        if (![item.value isValidForRegex:kAPCGeneralInfoItemEmailRegEx]) {
            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:@"Please give a valid email address"];
            [self presentViewController:alert animated:YES completion:nil];
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
    
    if (isContentValid) {
        isContentValid = self.permissionButton.isSelected;
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
                self.user.biologicalSex = [APCUser sexTypeForIndex:((APCTableViewSegmentItem *)item).selectedIndex];
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
        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:message];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - APCTermsAndConditionsViewControllerDelegate methods

- (void)termsAndConditionsViewControllerDidAgree
{
    [self.permissionButton setSelected:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.nextBarButton setEnabled:[self isContentValid:nil]];
    }];
}

- (void)termsAndConditionsViewControllerDidCancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    [self.profileImageButton setImage:image forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)termsAndConditions:(UIButton *)sender
{
    APCTermsAndConditionsViewController *termsViewController =  [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"TermsVC"];
    termsViewController.delegate = self;
    [self.navigationController presentViewController:termsViewController animated:YES completion:nil];
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
    
    [self.permissionButton setSelected:YES];
    
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
        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:error];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (IBAction)cancel:(id)sender
{
    
}

- (IBAction)changeProfileImage:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.editing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertController addAction:cameraAction];
    }
    
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.editing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    [alertController addAction:libraryAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
