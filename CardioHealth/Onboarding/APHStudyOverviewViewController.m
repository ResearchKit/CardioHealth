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
@property (nonatomic, strong) NSArray * imagesArray;
@property (nonatomic, strong) NSArray * colorsArray;

@end

@implementation APHStudyOverviewViewController

- (void)prepareContent
{
    _studyDetailsArray = [self studyDetailsFromJSONFile:@"StudyOverview"];
}

- (NSArray *)imagesArray
{
    return @[
             @"paperplus_icon",
             @"rulerpencil_icon",
             @"stethescope_icon",
             @"clipboard_icon",
             @"stopwatch_icon"
             ];
}

- (NSArray *)colorsArray
{
    return @[
             [UIColor colorWithRed:0.132 green:0.684 blue:0.959 alpha:1.000],
             [UIColor colorWithRed:0.919 green:0.226 blue:0.342 alpha:1.000],
             [UIColor colorWithRed:0.195 green:0.830 blue:0.443 alpha:1.000],
             [UIColor colorWithRed:0.994 green:0.709 blue:0.278 alpha:1.000],
             [UIColor colorWithRed:0.574 green:0.252 blue:0.829 alpha:1.000]
             ];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareContent];
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
    
    UIView * view = [cell viewWithTag:100];
    view.backgroundColor = self.colorsArray[indexPath.row];
    
    UIImageView * imageView = (UIImageView*) [cell viewWithTag:200];
    imageView.image = [UIImage imageNamed:self.imagesArray[indexPath.row]];
    
    UILabel * label = (UILabel*) [cell viewWithTag:300];
    label.text = studyDetails.title;
    
    [self setUpCellAppearance:cell];
    return cell;
}

- (void) setUpCellAppearance: (UITableViewCell*) cell
{
    UILabel * label = (UILabel*) [cell viewWithTag:300];
    label.font = [UIFont appRegularFontWithSize:16];
    label.textColor = [UIColor appSecondaryColor1];
}

#pragma mark - IBActions

- (void)signInTapped:(id)sender
{
    APCForgotPasswordViewController *signInViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"SignInVC"];
    [self.navigationController pushViewController:signInViewController animated:YES];
}

- (void)signUpTapped:(id)sender
{
    [self.navigationController pushViewController: [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"InclusionCriteriaVC"] animated:YES];
}

/*********************************************************************************/
#pragma mark - Misc Fix
/*********************************************************************************/
-(void)viewDidLayoutSubviews
{
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    APCStudyDetails *studyDetails = self.studyDetailsArray[indexPath.row];
    
    APCStudyDetailsViewController *detailsViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"StudyDetailsVC"];
    detailsViewController.iconImageView.image = [UIImage imageNamed:self.imagesArray[indexPath.row]];
    detailsViewController.title = studyDetails.title;
    [self.navigationController pushViewController:detailsViewController animated:YES];
}

@end
