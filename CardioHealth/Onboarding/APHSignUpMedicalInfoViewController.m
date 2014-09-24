//
//  APHSignUpMedicalInfoViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import APCAppleCore;
#import "APHSignUpMedicalInfoViewController.h"


#define DEMO    1


@interface APHSignUpMedicalInfoViewController ()

@end

@implementation APHSignUpMedicalInfoViewController

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepareFields];
    }
    return self;
}

- (void) prepareFields {
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *itemsOrder = [NSMutableArray new];
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"Medical Conditions", @"");
        field.detailDiscloserStyle = YES;
        field.pickerData = @[ [APCProfile medicalConditions] ];
        
        if (self.profile.medicalCondition) {
            field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:self.profile.medicalCondition]) ];
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
        field.pickerData = @[ [APCProfile medications] ];
        
        if (self.profile.medication) {
            field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:self.profile.medication]) ];
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
        field.selectedRowIndices = @[ @(self.profile.bloodType) ];
        field.pickerData = @[ [APCProfile bloodTypeInStringValues] ];
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemBloodType)];
    }
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"Height", @"");
        field.detailDiscloserStyle = YES;
        field.pickerData = [APCProfile heights];
        if (self.profile.height) {
            NSArray *split = [self.profile.height componentsSeparatedByString:@" "];
            field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:split[0]]), @([field.pickerData[1] indexOfObject:split[1]]) ];
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
        field.regularExpression = kAPCMedicalInfoItemWeightRegEx;
        field.value = self.profile.weight.stringValue;
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
        field.dateFormat = kAPCMedicalInfoItemSleepTimeFormate;
        field.detailDiscloserStyle = YES;
        
        if (self.profile.sleepTime) {
            field.date = self.profile.sleepTime;
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
        field.dateFormat = kAPCMedicalInfoItemSleepTimeFormate;
        field.detailDiscloserStyle = YES;
        
        if (self.profile.wakeUpTime) {
            field.date = self.profile.wakeUpTime;
        }
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemWakeUpTime)];
    }
    
    self.items = items;
    self.itemsOrder = itemsOrder;
}


#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = nil;
    
    [self addNavigationItems];
    [self setupProgressBar];
    [self addFooterView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:1 animation:YES];
}


#pragma mark - UIMethods

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"Medical Information", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(signup)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

- (void) setupProgressBar {
    self.stepProgressBar.rightLabel.text = NSLocalizedString(@"optional", @"");
}

- (void) addFooterView {
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(0, 0, self.tableView.width, 44);
    label.font = [UITableView footerFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UITableView footerTextColor];
    label.text = NSLocalizedString(@"All fields on this screen are optional.", @"");
    self.tableView.tableFooterView = label;
}


#pragma mark - Private Methods

- (void) loadProfileValuesInModel {
    for (int i = 0; i < self.itemsOrder.count; i++) {
        NSNumber *order = self.itemsOrder[i];
        
        APCTableViewItem *item = self.items[i];
        
        switch (order.integerValue) {
            case APCSignUpUserInfoItemMedicalCondition:
                self.profile.medicalCondition = [(APCTableViewCustomPickerItem *)item stringValue];
                break;
                
            case APCSignUpUserInfoItemMedication:
                self.profile.medication = [(APCTableViewCustomPickerItem *)item stringValue];
                break;
                
            case APCSignUpUserInfoItemBloodType:
                self.profile.bloodType = [APCProfile bloodTypeFromStringValue:[(APCTableViewCustomPickerItem *)item stringValue]];
                break;
                
            case APCSignUpUserInfoItemHeight:
                self.profile.height = [(APCTableViewCustomPickerItem *)item stringValue];
                break;
                
            case APCSignUpUserInfoItemWeight:
                self.profile.weight = @([[(APCTableViewTextFieldItem *)item value] floatValue]);
                break;
                
            case APCSignUpUserInfoItemSleepTime:
                self.profile.sleepTime = [(APCTableViewDatePickerItem *)item date];
                break;
                
            case APCSignUpUserInfoItemWakeUpTime:
                self.profile.wakeUpTime = [(APCTableViewDatePickerItem *)item date];
                break;
                
            default:
//#warning ASSERT_MESSAGE Require
                NSAssert(order.integerValue <= APCSignUpUserInfoItemWakeUpTime, @"ASSER_MESSAGE");
                break;
        }
    }
}

- (void) signup {
#ifdef DEMO
    [self next];
#else
    [self loadProfileValuesInModel];
    
    APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
    [self presentViewController:spinnerController animated:YES completion:nil];
    
    typeof(self) __weak weakSelf = self;
    
    APCSageNetworkManager *networkManager = (APCSageNetworkManager *)[(APHParkinsonAppDelegate *)[[UIApplication sharedApplication] delegate] networkManager];
    [networkManager signUp:self.profile.email username:self.profile.userName password:self.profile.password success:^(NSURLSessionDataTask *task, id responseObject) {
        [NSObject performInMainThread:^{
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                [self next];
            }];
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [NSObject performInMainThread:^{
            [spinnerController dismissViewControllerAnimated:YES completion:nil];
            
            if (error.code == kAPCServerPreconditionNotMet) {
                [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign Up", @"") message:NSLocalizedString(@"User account successfully created waiting for consent.", @"")];
                [weakSelf next];
            }
            else {
                [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign Up", @"") message:error.message];
            }
        }];
    }];
#endif
}

- (void) next {
    APCSignupTouchIDViewController *touchIDViewController = [[APCSignupTouchIDViewController alloc] initWithNibName:@"APCSignupTouchIDViewController" bundle:[NSBundle appleCoreBundle]];
    touchIDViewController.profile = self.profile;
    [self.navigationController pushViewController:touchIDViewController animated:YES];
}

@end
