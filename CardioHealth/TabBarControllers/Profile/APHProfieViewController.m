//
//  APHProfieViewController.m
//  Parkinson
//
//  Created by Ramsundar Shandilya on 10/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHProfieViewController.h"
#import "APHWithdrawSurveyViewController.h"

@interface APHProfieViewController ()

@end

@implementation APHProfieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareFields];
    [self.tableView reloadData];
    
    self.firstNameTextField.text = self.user.firstName;
    self.firstNameTextField.enabled = NO;
    
    self.lastNameTextField.text = self.user.lastName;
    self.lastNameTextField.enabled = NO;
    
    self.profileImage = [UIImage imageWithData:self.user.profileImage];
    [self.profileImageButton setImage:self.profileImage forState:UIControlStateNormal];
    
    [self setupDataFromJSONFile:@"StudyOverview"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareFields
{
    [self.items removeAllObjects];
    
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Email", @"");
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.editable = NO;
            field.textAlignnment = NSTextAlignmentLeft;
            field.detailText = self.user.email;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCUserInfoItemTypeEmail;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Birthdate", @"");
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.editable = NO;
            field.textAlignnment = NSTextAlignmentRight;
            field.detailText = [self.user.birthDate toStringWithFormat:NSDateDefaultDateFormat];
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCUserInfoItemTypeDateOfBirth;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Biological Sex", @"");
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.editable = NO;
            field.textAlignnment = NSTextAlignmentRight;
            field.detailText = [APCUser stringValueFromSexType:self.user.biologicalSex];
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCUserInfoItemTypeBiologicalSex;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
            field.caption = NSLocalizedString(@"Medical Conditions", @"");
            field.pickerData = @[[APCUser medicalConditions]];
            field.textAlignnment = NSTextAlignmentRight;
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            
            if (self.user.medications) {
                field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:self.user.medicalConditions]) ];
            }
            else {
                field.selectedRowIndices = @[ @(0) ];
            }
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCUserInfoItemTypeMedicalCondition;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
            field.caption = NSLocalizedString(@"Medications", @"");
            field.pickerData = @[[APCUser medications]];
            field.textAlignnment = NSTextAlignmentRight;
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            
            if (self.user.medications) {
                field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:self.user.medications]) ];
            }
            else {
                field.selectedRowIndices = @[ @(0) ];
            }
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCUserInfoItemTypeMedication;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
            field.caption = NSLocalizedString(@"Height", @"");
            field.pickerData = [APCUser heights];
            field.textAlignnment = NSTextAlignmentRight;
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            
            if (self.user.height) {
                double heightInInches = roundf([APCUser heightInInches:self.user.height]);
                NSString *feet = [NSString stringWithFormat:@"%d'", (int)heightInInches/12];
                NSString *inches = [NSString stringWithFormat:@"%d''", (int)heightInInches%12];
                
                field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:feet]), @([field.pickerData[1] indexOfObject:inches]) ];
            }
            else {
                field.selectedRowIndices = @[ @(2), @(5) ];
            }
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCUserInfoItemTypeHeight;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
            field.caption = NSLocalizedString(@"Weight", @"");
            field.placeholder = NSLocalizedString(@"add weight (lb)", @"");
            field.regularExpression = kAPCMedicalInfoItemWeightRegEx;
            if (self.user.weight) {
                field.value = [NSString stringWithFormat:@"%.0f", [APCUser weightInPounds:self.user.weight]];
            }
            field.keyboardType = UIKeyboardTypeDecimalPad;
            field.textAlignnment = NSTextAlignmentRight;
            field.identifier = kAPCTextFieldTableViewCellIdentifier;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCUserInfoItemTypeWeight;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
            field.selectionStyle = UITableViewCellSelectionStyleGray;
            field.style = UITableViewCellStyleValue1;
            field.caption = NSLocalizedString(@"What time do you wake up?", @"");
            field.placeholder = NSLocalizedString(@"7:00 AM", @"");
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.datePickerMode = UIDatePickerModeTime;
            field.dateFormat = kAPCMedicalInfoItemSleepTimeFormat;
            field.textAlignnment = NSTextAlignmentRight;
            field.detailDiscloserStyle = YES;
            
            if (self.user.sleepTime) {
                field.date = self.user.wakeUpTime;
                field.detailText = [field.date toStringWithFormat:kAPCMedicalInfoItemSleepTimeFormat];
            }
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCUserInfoItemTypeWakeUpTime;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
            field.selectionStyle = UITableViewCellSelectionStyleGray;
            field.style = UITableViewCellStyleValue1;
            field.caption = NSLocalizedString(@"What time do you go to sleep?", @"");
            field.placeholder = NSLocalizedString(@"9:30 PM", @"");
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.datePickerMode = UIDatePickerModeTime;
            field.dateFormat = kAPCMedicalInfoItemSleepTimeFormat;
            field.textAlignnment = NSTextAlignmentRight;
            field.detailDiscloserStyle = YES;
            
            if (self.user.wakeUpTime) {
                field.date = self.user.sleepTime;
                field.detailText = [field.date toStringWithFormat:kAPCMedicalInfoItemSleepTimeFormat];
            }
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCUserInfoItemTypeSleepTime;
            [rowItems addObject:row];
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        [self.items addObject:section];
    }
    
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Share this Study", @"");
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.editable = YES;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCTableViewStudyItemTypeShare;
            [rowItems addObject:row];
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        section.sectionTitle = NSLocalizedString(@"Help us Spread the Word", @"");
        [self.items addObject:section];
    }
    
    
}

#pragma mark - Overriden Methods

- (void)loadProfileValuesInModel
{
    self.user.firstName = self.firstNameTextField.text;
    self.user.lastName = self.lastNameTextField.text;
    
    if (self.profileImage) {
        self.user.profileImage = UIImageJPEGRepresentation(self.profileImage, 1.0);
    }
    
    for (int j=0; j<self.items.count; j++) {
        
        APCTableViewSection *section = self.items[j];
        
        for (int i = 0; i < section.rows.count; i++) {
            
            APCTableViewRow *row = section.rows[i];
            
            APCTableViewItem *item = row.item;
            APCTableViewItemType itemType = row.itemType;
            
            switch (itemType) {
                case kAPCUserInfoItemTypeMedicalCondition:
                    self.user.medicalConditions = [(APCTableViewCustomPickerItem *)item stringValue];
                    break;
                    
                case kAPCUserInfoItemTypeMedication:
                    self.user.medications = [(APCTableViewCustomPickerItem *)item stringValue];
                    break;
                    
                case kAPCUserInfoItemTypeHeight:
                {
                    double height = [APCUser heightInInchesForSelectedIndices:[(APCTableViewCustomPickerItem *)item selectedRowIndices]];
                    HKUnit *inchUnit = [HKUnit inchUnit];
                    HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:inchUnit doubleValue:height];
                    
                    self.user.height = heightQuantity;
                }
                    
                    break;
                    
                case kAPCUserInfoItemTypeWeight:
                {
                    double weight = [[(APCTableViewTextFieldItem *)item value] floatValue];
                    HKUnit *poundUnit = [HKUnit poundUnit];
                    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:poundUnit doubleValue:weight];
                    
                    self.user.weight = weightQuantity;
                }
                    break;
                    
                case kAPCUserInfoItemTypeSleepTime:
                    self.user.sleepTime = [(APCTableViewDatePickerItem *)item date];
                    break;
                    
                case kAPCUserInfoItemTypeWakeUpTime:
                    self.user.wakeUpTime = [(APCTableViewDatePickerItem *)item date];
                    break;
                    
                default:
                    //#warning ASSERT_MESSAGE Require
                    NSAssert(itemType <= kAPCUserInfoItemTypeWakeUpTime, @"ASSER_MESSAGE");
                    break;
            }
        }
        
    }
    
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewItemType type = [self itemTypeForIndexPath:indexPath];
    
    switch (type) {
        case kAPCTableViewStudyItemTypeShare:
        {
            APCShareViewController *shareViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"ShareVC"];
            shareViewController.hidesOkayButton = YES;
            [self.navigationController pushViewController:shareViewController animated:YES];
        }
            break;
            
        default:{
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
            break;
    }
}

- (void)leaveStudy:(id)sender
{
    UINavigationController *withdrawViewController = [[UIStoryboard storyboardWithName:@"APHProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"WithdrawSurveyNC"];
    [self.navigationController presentViewController:withdrawViewController animated:YES completion:nil];
    
}
@end
