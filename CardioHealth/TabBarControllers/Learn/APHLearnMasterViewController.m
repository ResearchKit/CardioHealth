//
//  APHLearnMasterViewController.m
//  CardioHealth
//
//  Created by Ramsundar Shandilya on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHLearnMasterViewController.h"
#import "APHLearnStudyDetailsViewController.h"

static CGFloat kSectionHeaderHeight = 40.f;

@interface APHLearnMasterViewController ()

@end

@implementation APHLearnMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareContent
{
    [self studyDetailsFromJSONFile:@"Learn"];
    [self.tableView reloadData];
}

#pragma UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        APHLearnStudyDetailsViewController *detailViewController = [[UIStoryboard storyboardWithName:@"APHLearn" bundle:nil] instantiateViewControllerWithIdentifier:@"StudyDetailsVC"];
        [self.navigationController pushViewController:detailViewController animated:YES];
        
    } else {
        
        APCStudyDetailsViewController *detailViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"StudyDetailsVC"];
        detailViewController.studyDetails = [self itemForIndexPath:indexPath];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height;
    
    if (section == 0) {
        height = 0;
    } else {
        height = kSectionHeaderHeight;
    }
    
    return height;
}
@end
