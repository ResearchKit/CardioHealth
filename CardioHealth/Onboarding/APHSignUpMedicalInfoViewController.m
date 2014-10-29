//
//  APHSignUpMedicalInfoViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSignUpMedicalInfoViewController.h"


#define DEMO    0


@interface APHSignUpMedicalInfoViewController ()

@end

@implementation APHSignUpMedicalInfoViewController

#pragma mark - Init

- (void) prepareFields {
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *itemsOrder = [NSMutableArray new];
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.identifier = kAPCDefaultTableViewCellIdentifier;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"Medical Conditions", @"");
        field.detailDiscloserStyle = YES;
        field.pickerData = @[ [APCUser medicalConditions] ];
        field.textAlignnment = NSTextAlignmentRight;
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
        field.identifier = kAPCDefaultTableViewCellIdentifier;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"Medication", @"");
        field.detailDiscloserStyle = YES;
        field.textAlignnment = NSTextAlignmentRight;
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
        field.identifier = kAPCDefaultTableViewCellIdentifier;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"Blood Type", @"");
        field.detailDiscloserStyle = YES;
        
        if (self.user.bloodType) {
            field.selectedRowIndices = @[ @(self.user.bloodType) ];
            field.editable = NO;
        } 
        
        field.textAlignnment = NSTextAlignmentRight;
        field.pickerData = @[ [APCUser bloodTypeInStringValues] ];
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemBloodType)];
    }
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.identifier = kAPCDefaultTableViewCellIdentifier;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"Height", @"");
        field.detailDiscloserStyle = YES;
        field.textAlignnment = NSTextAlignmentRight;
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
        field.identifier = kAPCTextFieldTableViewCellIdentifier;
        field.caption = NSLocalizedString(@"Weight", @"");
        field.placeholder = NSLocalizedString(@"add weight", @"");
        field.regularExpression = kAPCMedicalInfoItemWeightRegEx;
        field.value = [NSString stringWithFormat:@"%.1f", [APCUser weightInPounds:self.user.weight]];
        field.keyboardType = UIKeyboardTypeDecimalPad;
        field.textAlignnment = NSTextAlignmentRight;
        
        [items addObject:field];
        [itemsOrder addObject:@(APCSignUpUserInfoItemWeight)];
    }
    
    {
        APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
        field.identifier = kAPCDefaultTableViewCellIdentifier;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"What time do you wake up?", @"");
        field.placeholder = @"--:--";
        field.datePickerMode = UIDatePickerModeTime;
        field.dateFormat = kAPCMedicalInfoItemSleepTimeFormat;
        field.textAlignnment = NSTextAlignmentRight;
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
        field.identifier = kAPCDefaultTableViewCellIdentifier;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.caption = NSLocalizedString(@"What time do you go to sleep?", @"");
        field.placeholder = @"--:--";
        field.datePickerMode = UIDatePickerModeTime;
        field.dateFormat = kAPCMedicalInfoItemSleepTimeFormat;
        field.textAlignnment = NSTextAlignmentRight;
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

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = nil;
    
    [self prepareFields];
    [self setupProgressBar];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:1 animation:YES];
}

#pragma mark - UIMethods

- (void) setupProgressBar {
    [self.stepProgressBar setCompletedSteps:0 animation:NO];
}


#pragma mark - Private Methods

- (void) loadProfileValuesInModel {
    for (int i = 0; i < self.itemsOrder.count; i++) {
        NSNumber *order = self.itemsOrder[i];
        
        APCTableViewItem *item = self.items[i];
        
        switch (order.integerValue) {
            case APCSignUpUserInfoItemMedicalCondition:
                self.user.medicalConditions = [(APCTableViewCustomPickerItem *)item stringValue];
                break;
                
            case APCSignUpUserInfoItemMedication:
                self.user.medications = [(APCTableViewCustomPickerItem *)item stringValue];
                break;
                
            case APCSignUpUserInfoItemHeight:
            {
                double height = [APCUser heightInInchesForSelectedIndices:[(APCTableViewCustomPickerItem *)item selectedRowIndices]];
                HKUnit *inchUnit = [HKUnit inchUnit];
                HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:inchUnit doubleValue:height];
                
                self.user.height = heightQuantity;
            }
                
                break;
                
            case APCSignUpUserInfoItemWeight:
            {
                double weight = [[(APCTableViewTextFieldItem *)item value] floatValue];
                HKUnit *poundUnit = [HKUnit poundUnit];
                HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:poundUnit doubleValue:weight];
                
                self.user.weight = weightQuantity;
            }
                break;
                
            case APCSignUpUserInfoItemSleepTime:
                self.user.sleepTime = [(APCTableViewDatePickerItem *)item date];
                break;
                
            case APCSignUpUserInfoItemWakeUpTime:
                self.user.wakeUpTime = [(APCTableViewDatePickerItem *)item date];
                break;
                
            default:
//#warning ASSERT_MESSAGE Require
                NSAssert(order.integerValue <= APCSignUpUserInfoItemWakeUpTime, @"ASSER_MESSAGE");
                break;
        }
    }
}

- (void) signup {
    
#if DEMO
    [self next];
#else
    
    APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
    [self presentViewController:spinnerController animated:YES completion:nil];
    
    typeof(self) __weak weakSelf = self;
    [self.user signUpOnCompletion:^(NSError *error) {
        if (error) {
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign Up", @"") message:error.message];
            }];
        }
        else
        {
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                [weakSelf next];
            }];
        }
    }];
#endif
}

- (IBAction) next {
    [self loadProfileValuesInModel];
    
    APCSignupTouchIDViewController *touchIDViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"PasscodeVC"];
    touchIDViewController.user = self.user;
    [self.navigationController pushViewController:touchIDViewController animated:YES];
}

@end
