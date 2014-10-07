//
//  SignUpGeneralInfoViewController.m
//  OnBoarding
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSignUpGeneralInfoViewController.h"
#import "APHSignUpMedicalInfoViewController.h"
#import "APHUserInfoCell.h"

#define DEMO 0


@interface APHSignUpGeneralInfoViewController ()

@property (nonatomic, strong) APCPermissionsManager *permissionManager;
@property (nonatomic) BOOL permissionGranted;

@end

@implementation APHSignUpGeneralInfoViewController


#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.user = ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
        self.itemsOrder = [NSMutableArray new];
        
        [self prepareFields];
    }
    return self;
}

- (void) prepareFields {
    NSMutableArray *items = [NSMutableArray new];
    NSMutableArray *itemsOrder = [NSMutableArray new];
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Username", @"");
        field.placeholder = NSLocalizedString(@"Add Username", @"");
        field.keyboardType = UIKeyboardTypeDefault;
        field.returnKeyType = UIReturnKeyNext;
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.regularExpression = kAPCGeneralInfoItemUserNameRegEx;
        field.identifier = NSStringFromClass([APCTableViewTextFieldItem class]);
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemUserName)];
    }
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Password", @"");
        field.placeholder = NSLocalizedString(@"Add Password", @"");
        field.secure = YES;
        field.keyboardType = UIKeyboardTypeDefault;
        field.returnKeyType = UIReturnKeyNext;
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.identifier = NSStringFromClass([APCTableViewTextFieldItem class]);
        
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
        field.identifier = NSStringFromClass([APCTableViewTextFieldItem class]);
        
        [items addObject:field];
        
        [itemsOrder addObject:@(APCSignUpUserInfoItemEmail)];
    }
    
    {
        APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"Birthdate", @"");
        field.placeholder = NSLocalizedString(@"MMMM DD, YYYY", @"");
        if (self.permissionGranted) {
            field.date = self.user.birthDate;
        }
        field.datePickerMode = UIDatePickerModeDate;
        field.identifier = NSStringFromClass([APCTableViewDatePickerItem class]);
        
        [items addObject:field];
        
        [itemsOrder addObject:@(APCSignUpUserInfoItemDateOfBirth)];
    }
    
    {
        APCTableViewSegmentItem *field = [APCTableViewSegmentItem new];
        field.style = UITableViewCellStyleValue1;
        field.segments = [APCUser sexTypesInStringValue];
        if (self.permissionGranted) {
            field.selectedIndex = [APCUser stringIndexFromSexType:self.user.biologicalSex];
        }
        field.identifier = NSStringFromClass([APCTableViewSegmentItem class]);
        
        [items addObject:field];
        
        [itemsOrder addObject:@(APCSignUpUserInfoItemGender)];
    }
    
    
    self.items = items;
    self.itemsOrder = itemsOrder;
}


#pragma mark - View Life Cycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationItems];
    [self addHeaderView];
    [self addFooterView];
    [self setupProgressBar];
    

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

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeNone;
}

#pragma mark - UI Methods

- (void) addNavigationItems {
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(validateContent)];
    nextBarButton.enabled = [self isContentValid:nil];
    //TODO: Remove secret button for production
    UIBarButtonItem *secretBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@" ", @"") style:UIBarButtonItemStylePlain target:self action:@selector(secretButton)];
    self.navigationItem.rightBarButtonItems = @[nextBarButton, secretBarButton];
    
}

- (void) setupProgressBar {
    [self setStepNumber:1 title:NSLocalizedString(@"General Information", @"")];
    self.stepProgressBar.rightLabel.text = NSLocalizedString(@"Mandatory", @"");
}

- (void) addHeaderView {
    [super addHeaderView];
    
    [self.profileImageButton setImage:[UIImage imageNamed:@"img_user_placeholder"] forState:UIControlStateNormal];
}

- (void) addFooterView {
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(0, 0, self.tableView.width, 44);
    label.font = [UITableView footerFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UITableView footerTextColor];
    label.text = NSLocalizedString(@"All fields on this screen are required.", @"");
    self.tableView.tableFooterView = label;
}


#pragma mark - APCConfigurableCell

- (void) configurableCell:(APCUserInfoCell *)cell textValueChanged:(NSString *)text {
    [super configurableCell:cell textValueChanged:text];
    
    self.navigationItem.rightBarButtonItem.enabled = [self isContentValid:nil];
    
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
}

- (void) configurableCell:(APCUserInfoCell *)cell switchValueChanged:(BOOL)isOn {
    [super configurableCell:cell switchValueChanged:isOn];
    
#if DEMO
    self.navigationItem.rightBarButtonItem.enabled = YES;
#else
    self.navigationItem.rightBarButtonItem.enabled = [self isContentValid:nil];
#endif
}

- (void) configurableCell:(APCUserInfoCell *)cell segmentIndexChanged:(NSUInteger)index {
    [super configurableCell:cell segmentIndexChanged:index];
    
#if DEMO
    self.navigationItem.rightBarButtonItem.enabled = YES;
#else
    self.navigationItem.rightBarButtonItem.enabled = [self isContentValid:nil];
#endif
}

- (void) configurableCell:(APCUserInfoCell *)cell dateValueChanged:(NSDate *)date {
    [super configurableCell:cell dateValueChanged:date];
    
#if DEMO
    self.navigationItem.rightBarButtonItem.enabled = YES;
#else
    self.navigationItem.rightBarButtonItem.enabled = [self isContentValid:nil];
#endif
}

- (void) configurableCell:(APCUserInfoCell *)cell customPickerValueChanged:(NSArray *)selectedRowIndices {
    [super configurableCell:cell customPickerValueChanged:selectedRowIndices];
#if DEMO
    self.navigationItem.rightBarButtonItem.enabled = YES;
#else
    self.navigationItem.rightBarButtonItem.enabled = [self isContentValid:nil];
#endif
}



#pragma mark - Public Methods

- (Class) cellClass {
    return [APHUserInfoCell class];
}


#pragma mark - Private Methods

- (BOOL) isContentValid:(NSString **)errorMessage {

#if DEMO
    return YES;
#else
    BOOL isContentValid = [super isContentValid:errorMessage];
    // If super returned false then we dont need to check any content further unnecessary,
    // because if any one of the content is invalid then we are immediatly returing false
    if (isContentValid) {
        for (int i = 0; i < self.itemsOrder.count; i++) {
            NSNumber *order = self.itemsOrder[i];
            
            APCTableViewItem *item = self.items[i];
            
            switch (order.integerValue) {
                    //TODO: Enable it for production
                    /*
                case APCSignUpUserInfoItemUserName:
                    isContentValid = [[(APCTableViewTextFieldItem *)item value] isValidForRegex:kAPCGeneralInfoItemUserNameRegEx];
                    if (errorMessage) {
                        *errorMessage = NSLocalizedString(@"Please give a valid Username", @"");
                    }
                    break;
                     */
                    
                case APCSignUpUserInfoItemPassword:
                    if ([[(APCTableViewTextFieldItem *)item value] length] == 0) {
                        isContentValid = NO;
                        
                        if (errorMessage) {
                            *errorMessage = NSLocalizedString(@"Please give a valid Password", @"");
                        }
                    }
                    else if ([[(APCTableViewTextFieldItem *)item value] length] < 6) {
                        isContentValid = NO;
                        
                        if (errorMessage) {
                            *errorMessage = NSLocalizedString(@"Password should be at least 6 characters", @"");
                        }
                    }
                    break;
                    
                case APCSignUpUserInfoItemEmail:
                    isContentValid = [[(APCTableViewTextFieldItem *)item value] isValidForRegex:kAPCGeneralInfoItemEmailRegEx];
                    
                    if (errorMessage) {
                        *errorMessage = NSLocalizedString(@"Please give a valid Email", @"");
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
#endif
}

- (void) loadProfileValuesInModel {
    
    if (self.tableView.tableHeaderView) {
        self.user.firstName = self.firstNameTextField.text;
        self.user.lastName = self.lastNameTextField.text;
    }
    
    for (int i = 0; i < self.itemsOrder.count; i++) {
        NSNumber *order = self.itemsOrder[i];
        
        APCTableViewItem *item = self.items[i];
        
        switch (order.integerValue) {
            case APCSignUpUserInfoItemUserName:
                self.user.userName = [(APCTableViewTextFieldItem *)item value];
                break;
                
            case APCSignUpUserInfoItemPassword:
                self.user.password = [(APCTableViewTextFieldItem *)item value];
                break;
                
            case APCSignUpUserInfoItemEmail:
                self.user.email = [(APCTableViewTextFieldItem *)item value];
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

- (void) secretButton
{
    NSUInteger randomInteger = arc4random();
    self.firstNameTextField.text = @"Test";
    self.lastNameTextField.text = [NSString stringWithFormat:@"%@", @(randomInteger)];
    
    for (int i = 0; i < self.itemsOrder.count; i++) {
        NSNumber *order = self.itemsOrder[i];
        
        APCTableViewTextFieldItem *item = self.items[i];
        
        switch (order.integerValue) {
            case APCSignUpUserInfoItemUserName:
                item.value = [NSString stringWithFormat:@"test_%@", @(randomInteger)];
                break;
                
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
        self.navigationItem.rightBarButtonItem.enabled = [self isContentValid:nil];
    }
}

- (void) next {
    APHSignUpMedicalInfoViewController *medicalInfoViewController = [APHSignUpMedicalInfoViewController new];
    medicalInfoViewController.user = self.user;
    
    [self.navigationController pushViewController:medicalInfoViewController animated:YES];
}

@end
