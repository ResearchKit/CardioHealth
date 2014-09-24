//
//  APHLearnDetailViewController.m

//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

/* ViewControllers */
#import "APHLearnDetailViewController.h"

/* Views */
#import "APHLearnDetailViewCell.h"

static  NSString  *kLearnDetailViewCellIdentifier = @"LearnDetailTableViewCell";

static CGFloat kTableViewRowHeight        = 80;
static NSInteger kNumberOfRowsInTableView = 5;

@interface APHLearnDetailViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation APHLearnDetailViewController

#pragma mark - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"APHLearnDetailViewCell" bundle:nil] forCellReuseIdentifier:kLearnDetailViewCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRowsInTableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APHLearnDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLearnDetailViewCellIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewRowHeight;
}


@end
