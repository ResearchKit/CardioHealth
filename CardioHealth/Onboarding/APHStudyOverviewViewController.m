//
//  APHStudyOverviewViewController.m
//  Parkinson
//
//  Created by Ramsundar Shandilya on 9/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHStudyOverviewViewController.h"
#import "APHSignInViewController.h"
#import "APHSignUpGeneralInfoViewController.h"
#import "APHInclusionCriteriaViewController.h"

static NSString * const kStudyOverviewCellIdentifier = @"kStudyOverviewCellIdentifier";

@interface APHStudyOverviewViewController ()

@property (nonatomic, strong) NSArray *studyDetailsArray;

@end

@implementation APHStudyOverviewViewController

- (instancetype)init
{
    if (self = [super init]) {
        [self prepareContent];
    }
    return self;
}

- (void)prepareContent
{
    _studyDetailsArray = [self studyDetailsFromJSONFile:@"StudyOverview"];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.diseaseNameLabel.text = self.diseaseName;
    self.logoImageView.image = [UIImage imageNamed:@"logo_research_institute"];
    [self setupTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTable
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kStudyOverviewCellIdentifier];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.studyDetailsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStudyOverviewCellIdentifier forIndexPath:indexPath];
    
    APCStudyDetails *studyDetails = self.studyDetailsArray[indexPath.row];
    
    cell.textLabel.text = studyDetails.title;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - IBActions

- (void)signInTapped:(id)sender
{
    APCSignInViewController *signInViewController = [[APHSignInViewController alloc] initWithNibName:@"APCSignInViewController" bundle:[NSBundle appleCoreBundle]];
    [self.navigationController pushViewController:signInViewController animated:YES];
}

- (void)signUpTapped:(id)sender
{
    [self.navigationController pushViewController:[APHInclusionCriteriaViewController new] animated:YES];
}

@end
