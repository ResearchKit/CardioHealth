//
//  APHIntroPurposeContainedTableTableViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 1/13/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHIntroPurposeContainedTableTableViewController.h"
#import "APHIntroCellTableViewCell.h"

@interface APHIntroPurposeContainedTableTableViewController ()

@end

@implementation APHIntroPurposeContainedTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    [self.tableView registerClass:[APHIntroCellTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    
    // This will trigger self-sizing rows in the tableview
    self.tableView.estimatedRowHeight = 150.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        APHIntroCellTableViewCell *purposeCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"
                                                                          forIndexPath:indexPath];
        purposeCell.purposeBody = @"The American Heart Association and the American College of Cardiology developed a risk score for heart disease and stroke as the first step for prevention. It is based on following healthy individuals for many years to understand which risk factors predicted cardiovascular disease. By entering your own data, requiring blood pressure and cholesterol values, the app will provide a personalized estimate of your risk of heart attack or stroke over the next 10 years, as well as over your lifetime. It will also provide optimal risk scores for someone your age, gender, and race.\n[Note the 10-year risk score only applies to ages 40-79, while the lifetime risk score is calculated for ages 20-59.]";
        cell = purposeCell;
    } else {
        APHIntroCellTableViewCell *lengthCell = [tableView dequeueReusableCellWithIdentifier:@"LengthCellIdentifier"
                                                                          forIndexPath:indexPath];
        lengthCell.lengthBody = @"Entering the data for the risk score should take less than 2 minutes.";
        
        cell = lengthCell;
    }
    
    return cell;
}

@end
