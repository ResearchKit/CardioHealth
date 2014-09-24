//
//  APHLearnMasterViewController.m

//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//


/* ViewControllers */
#import "APHLearnMasterViewController.h"
#import "APHLearnDetailViewController.h"

/* Views */
#import "APHLearnMasterTableViewCell.h"
#import "APHLearnResourceViewCell.h"

static  NSString  *LearnMasterViewCellIdentifier   = @"LearnMasterTableViewCell";
static  NSString  *LearnResourceViewCellIdentifier = @"LearnResourceTableViewCell";

static NSInteger kNumberOfSectionsinTableView = 2;
static CGFloat kMasterTableViewCellHeight     = 166.0;
static CGFloat kResourceTableViewCellHeight   = 120.0;

@interface APHLearnMasterViewController ()  <APHLearnMasterTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *learnTableView;

@end

@implementation APHLearnMasterViewController

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        self.title = NSLocalizedString(@"Learn", nil);
    }
    
    return self;
}

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeNone;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  kNumberOfSectionsinTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Not a constant. Varies according to content.
    return  3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            APHLearnMasterTableViewCell  *cell = (APHLearnMasterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:LearnMasterViewCellIdentifier];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return  cell;
        }
            break;
        case 1:
        {
            APHLearnResourceViewCell  *cell = (APHLearnResourceViewCell *)[tableView dequeueReusableCellWithIdentifier:LearnResourceViewCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return  cell;
        }
            break;
        default:{
            NSAssert(0, @"Invalid section");
        }
            break;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    switch (indexPath.section) {
        case 0:
        {
            height = kMasterTableViewCellHeight;
        }
            break;
        case 1:
        {
            height = kResourceTableViewCellHeight;
        }
            break;
        default:{
            height = 0;
        }
            break;
    }
    
    return  height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            
        }
            break;
        default:{
            NSAssert(0, @"Invalid Section");
        }
            break;
    }
}

#pragma mark - APHLearnMasterTableViewCellDelegate methods

- (void)learnMasterTableViewCellDidTapReadMoreForCell:(APHLearnMasterTableViewCell *)cell
{
    APHLearnDetailViewController *learnDetailViewController = [[APHLearnDetailViewController alloc] initWithNibName:@"APHLearnDetailViewController" bundle:nil];
    learnDetailViewController.title = cell.titleLabel.text;
    
    [self.navigationController pushViewController:learnDetailViewController animated:YES];
}


@end
