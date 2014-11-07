//
//  APHSettingsViewController.m
//  CardioHealth
//
//  Created by Ramsundar Shandilya on 11/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSettingsViewController.h"
#import "APHChangePasscodeViewController.h"

static NSString * const kAPCBasicTableViewCellIdentifier = @"APCBasicTableViewCell";
static NSString * const kAPCRightDetailTableViewCellIdentifier = @"APCRightDetailTableViewCell";

@interface APHSettingsViewController ()

@end

@implementation APHSettingsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    [self prepareFields];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareFields
{
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        {
            APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.selectionStyle = UITableViewCellSelectionStyleGray;
            field.caption = NSLocalizedString(@"Auto-Lock", @"");
            field.detailDiscloserStyle = YES;
            field.textAlignnment = NSTextAlignmentRight;
            field.pickerData = @[[APCParameters autoLockOptionStrings]];
        
            NSNumber *numberOfMinutes = [self.parameters numberForKey:kNumberOfMinutesForPasscodeKey];
            NSInteger index = [[APCParameters autoLockValues] indexOfObject:numberOfMinutes];
            field.selectedRowIndices = @[@(index)];
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypeAutoLock;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Change Passcode", @"");
            field.identifier = kAPCBasicTableViewCellIdentifier;
            field.textAlignnment = NSTextAlignmentRight;
            field.editable = NO;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypePasscode;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Change Password", @"");
            field.identifier = kAPCBasicTableViewCellIdentifier;
            field.textAlignnment = NSTextAlignmentRight;
            field.editable = NO;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypePassword;
            [rowItems addObject:row];
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        [self.items addObject:section];
    }
    
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        {
            APCTableViewSwitchItem *field = [APCTableViewSwitchItem new];
            field.caption = NSLocalizedString(@"Push Notifications", @"");
            field.identifier = kAPCSwitchCellIdentifier;
            field.editable = NO;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypePushNotifications;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Devices", @"");
            field.detailText = NSLocalizedString(@"Detail", nil);
            field.identifier = kAPCRightDetailTableViewCellIdentifier;
            field.textAlignnment = NSTextAlignmentRight;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypeDevices;
            [rowItems addObject:row];
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        [self.items addObject:section];
    }
    
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewItemType itemType = [self itemTypeForIndexPath:indexPath];
    
    switch (itemType) {
        case kAPCSettingsItemTypePasscode:
        {
            APHChangePasscodeViewController *changePasscodeViewController = [[UIStoryboard storyboardWithName:@"APHProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"ChangePasscodeVC"];
            [self.navigationController presentViewController:changePasscodeViewController animated:YES completion:nil];
        }
            break;
            
        default:
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell pickerViewDidSelectIndices:(NSArray *)selectedIndices
{
    [super pickerTableViewCell:cell pickerViewDidSelectIndices:selectedIndices];
    
    NSInteger index = ((NSNumber *)selectedIndices[0]).integerValue;
    
    [self.parameters setNumber:[APCParameters autoLockValues][index] forKey:kNumberOfMinutesForPasscodeKey];
}
@end
