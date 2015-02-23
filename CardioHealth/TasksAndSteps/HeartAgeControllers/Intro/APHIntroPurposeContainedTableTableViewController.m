//
//  APHIntroPurposeContainedTableTableViewController.m
//  MyHeart Counts 
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHIntroPurposeContainedTableTableViewController.h"
#import "APHIntroCellTableViewCell.h"

static NSString *kLengthBody = @"Entering the data for the risk score should take less than 2 minutes.";
@interface APHIntroPurposeContainedTableTableViewController ()

@end

@implementation APHIntroPurposeContainedTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // This will trigger self-sizing rows in the tableview
    self.tableView.estimatedRowHeight = 150.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section. One for purpose and one for length.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        APHIntroCellTableViewCell *purposeCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"
                                                                          forIndexPath:indexPath];
        purposeCell.purposeBody = self.purposeText;
        
        cell = purposeCell;
    } else {
        APHIntroCellTableViewCell *lengthCell = [tableView dequeueReusableCellWithIdentifier:@"LengthCellIdentifier"
                                                                          forIndexPath:indexPath];
        lengthCell.lengthBody = kLengthBody;
        
        cell = lengthCell;
    }
    
    return cell;
}

@end
