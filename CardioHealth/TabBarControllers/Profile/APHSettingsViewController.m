//
//  APHSettingsViewController.m
//  CardioHealth
//
//  Created by Ramsundar Shandilya on 11/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSettingsViewController.h"
#import "APHChangePasscodeViewController.h"

@interface APHSettingsViewController ()

@end

@implementation APHSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1){
            APHChangePasscodeViewController *changePasscodeViewController = [[UIStoryboard storyboardWithName:@"APHProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"ChangePasscodeVC"];
            [self.navigationController presentViewController:changePasscodeViewController animated:YES completion:nil];
            
        } else if (indexPath.row == 2){
            
        }
        
    } else {
        if (indexPath.row == 0) {
            
        }else {
            
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
