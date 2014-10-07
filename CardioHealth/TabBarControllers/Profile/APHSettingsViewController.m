//
//  SettingsViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import APCAppleCore;
#import "APHUserInfoCell.h"
#import "APHSettingsViewController.h"


static NSString * const kAPHGeneralInfoItemUserNameRegEx            = @"[A-Za-z0-9_.]+";

static NSString * const kAPHGeneralInfoItemEmailRegEx               = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

static NSString * const kAPHMedicalInfoItemWeightRegEx              = @"[0-9]{1,3}";

static NSString * const kAPHMedicalInfoItemSleepTimeFormate         = @"HH:mm a";

@interface APHSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIView *footerConsentView;

@property (weak, nonatomic) IBOutlet UILabel *footerDiseaseLabel;

@property (weak, nonatomic) IBOutlet UILabel *studyPeriodLabel;

@property (weak, nonatomic) IBOutlet UIButton *reviewConsentButton;

@property (weak, nonatomic) IBOutlet UIButton *leaveStudyButton;

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (nonatomic, strong) NSArray *itemsOrder;

@end

@implementation APHSettingsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self prepareFields];
    [self addHeaderView];
    [self addFooterView];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [self.tableView reloadData];
}

- (void) viewWillLayoutSubviews {
//    self.tableView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI Methods

- (void) addHeaderView {
    [super addHeaderView];
    
    [self.profileImageButton setImage:[UIImage imageNamed:@"img_user_placeholder"] forState:UIControlStateNormal];
    
    self.firstNameTextField.text = self.user.firstName;
    self.lastNameTextField.text = self.user.lastName;
}

- (void) addFooterView {
    UIView *footerView = [[UINib nibWithNibName:@"APHSettingsTableFooterView" bundle:nil] instantiateWithOwner:self options:nil][0];
    self.tableView.tableFooterView = footerView;
    
    UIColor *color = [UITableView controlsBorderColor];
    
    self.footerConsentView.layer.borderWidth = 1.0;
    self.footerConsentView.layer.borderColor = color.CGColor;
    
    self.reviewConsentButton.layer.borderWidth = 1.0;
    self.reviewConsentButton.layer.borderColor = color.CGColor;
    
    self.leaveStudyButton.layer.borderWidth = 1.0;
    self.leaveStudyButton.layer.borderColor = color.CGColor;
}


#pragma mark - Getter Methods

- (APCUser *) user {
    if (!_user) {
        _user = ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
    }
    
    return _user;
}


#pragma mark - Private Methods

- (void) prepareFields {
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *itemsOrder = [NSMutableArray new];
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Username", @"");
        field.placeholder = NSLocalizedString(@"Add Username", @"");
        field.value = self.user.userName;
        field.keyboardType = UIKeyboardTypeDefault;
        field.regularExpression = kAPHGeneralInfoItemUserNameRegEx;
        field.identifier = NSStringFromClass([APCTableViewTextFieldItem class]);
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemUserName)];
    }
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Password", @"");
        field.placeholder = NSLocalizedString(@"Add Password", @"");
//        field.value = self.profile.password;
        field.secure = YES;
        field.keyboardType = UIKeyboardTypeDefault;
        field.identifier = NSStringFromClass([APCTableViewTextFieldItem class]);
        
        [items addObject:field];
        
        [itemsOrder addObject:@(APCSignUpUserInfoItemPassword)];
    }
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Email", @"");
        field.placeholder = NSLocalizedString(@"Add Email Address", @"");
        field.value = self.user.email;
        field.keyboardType = UIKeyboardTypeEmailAddress;
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
        field.date = self.user.birthDate;
        field.identifier = NSStringFromClass([APCTableViewDatePickerItem class]);
        
        [items addObject:field];
        
        [itemsOrder addObject:@(APCSignUpUserInfoItemDateOfBirth)];
    }
    
    {
        APCTableViewSegmentItem *field = [APCTableViewSegmentItem new];
        field.style = UITableViewCellStyleValue1;
        field.segments = [APCUser sexTypesInStringValue];
        field.selectedIndex = [APCUser stringIndexFromSexType:self.user.biologicalSex];
        field.identifier = NSStringFromClass([APCTableViewSegmentItem class]);
        
        [items addObject:field];
        
        [itemsOrder addObject:@(APCSignUpUserInfoItemGender)];
    }
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"Medical Conditions", @"");
        field.detailDiscloserStyle = YES;
        field.pickerData = @[ [APCUser medicalConditions] ];
        
        if (self.user.medicalConditions) {
            field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:self.user.medicalConditions]) ];
        }
        else {
            field.selectedRowIndices = @[ @(0) ];
        }
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemMedicalCondition)];
    }
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"Medication", @"");
        field.detailDiscloserStyle = YES;
        field.pickerData = @[ [APCUser medications] ];
        
        if (self.user.medications) {
            field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:self.user.medications]) ];
        }
        else {
            field.selectedRowIndices = @[ @(0) ];
        }
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemMedication)];
    }
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"Blood Type", @"");
        field.detailDiscloserStyle = YES;
        field.selectedRowIndices = @[ @(self.user.bloodType) ];
        field.pickerData = @[ [APCUser bloodTypeInStringValues] ];
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemBloodType)];
    }
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"Height", @"");
        field.detailDiscloserStyle = YES;
        field.pickerData = [APCUser heights];
        if (self.user.height) {
            double heightInInches = [APCUser heightInInches:self.user.height];
            NSString *feet = [NSString stringWithFormat:@"%d'", (int)heightInInches/12];
            NSString *inches = [NSString stringWithFormat:@"%d''", (int)heightInInches%12];
            
            field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:feet]), @([field.pickerData[1] indexOfObject:inches]) ];
        }
        else {
            field.selectedRowIndices = @[ @(2), @(5) ];
        }
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemHeight)];
    }
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Weight", @"");
        field.placeholder = NSLocalizedString(@"lb", @"");
        field.regularExpression = kAPHMedicalInfoItemWeightRegEx;
        field.value = [NSString stringWithFormat:@"%.1f", [APCUser weightInPounds:self.user.weight]];;
        field.keyboardType = UIKeyboardTypeNumberPad;
        field.textAlignnment = NSTextAlignmentRight;
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemWeight)];
    }
    
    {
        APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"What time do you wake up?", @"");
        field.placeholder = NSLocalizedString(@"7:00 AM", @"");
        field.identifier = NSStringFromClass([APCTableViewDatePickerItem class]);
        field.datePickerMode = UIDatePickerModeTime;
        field.dateFormat = @"HH:mm a";
        field.detailDiscloserStyle = YES;
        
        if (self.user.sleepTime) {
            field.date = self.user.sleepTime;
        }
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemSleepTime)];
    }
    
    {
        APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"What time do you go to sleep?", @"");
        field.placeholder = NSLocalizedString(@"9:30 PM", @"");
        field.identifier = NSStringFromClass([APCTableViewDatePickerItem class]);
        field.datePickerMode = UIDatePickerModeTime;
        field.dateFormat = @"HH:mm a";
        field.detailDiscloserStyle = YES;
        
        if (self.user.wakeUpTime) {
            field.date = self.user.wakeUpTime;
        }
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemWakeUpTime)];
    }
    
    self.items = items;
    self.itemsOrder = itemsOrder;
}


#pragma mark - IBActions

- (IBAction) profileImageViewTapped:(UITapGestureRecognizer *)sender {
    
}


- (IBAction) reviewConsent {
    
}


- (IBAction) leaveStudy {
    
}

- (IBAction) logout {
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserLogOutNotification object:self];
    
}


#pragma mark - Public Methods

- (Class) cellClass {
    return [APHUserInfoCell class];
}


@end
