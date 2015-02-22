// 
//  APHHeartAgeResultsViewController.m 
//  MyHeartCounts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHHeartAgeResultsViewController.h"
#import "APHHeartAgeTodaysActivitiesCell.h"
#import "APHHeartAgeSummaryCell.h"
#import "APHHeartAgeRiskEstimateCell.h"
#import "APHHeartAgeRecommendationCell.h"
#import "APHRiskEstimatorWebViewController.h"
#import "APHHeartAgeSummaryTitleCell.h"
#import "APHInstructionsForBelowTwentyTableViewCell.h"

#import "APHHeartAgeTenYearRecommendationCell.h"


typedef NS_ENUM(NSUInteger, APHHeartAgeSummarySections)
{
    APHHeartAgeSummarySectionHeartAge = 0,
    APHHeartAgeSummarySectionTenYearRiskEstimate,
    APHHeartAgeSummarySectionLifetimeRiskEstimate,
    APHHeartAgeSummaryNumberOfSections
};

typedef NS_ENUM(NSUInteger, APHHeartAgeSummaryRows)
{
    APHHeartAgeSummaryRowBanner = 0,
    APHHeartAgeSummaryRowRecommendation,
    APHHeartAgeSummaryNumberOfRows
};

// Cell Identifiers
static NSString *kTodaysActivitiesCellIdentifier = @"TodaysActivitiesCell";
static NSString *kHeartAgeCellIdentifier         = @"HeartAgeCell";
static NSString *kRiskEstimateCellIdenfier       = @"RiskEstimateCell";
static NSString *kRecommendationsCellIdentifier  = @"RecommendationCell";
static NSString *kKludgeIdentifierForHeartAgeTaskB = @"APHHeartAgeB-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";

// Cells
static NSString *kHeartAgeResults               = @"heartAgeResults";
static NSString *kTenYearRisk                   = @"tenYearRisk";
static NSString *kLifeTimeRisk                  = @"lifeTimeRisk";
static NSString *kHeartAgeSummaryTitle          = @"heartAgeSummaryTitle";
static NSString *kEighteenToTwentyInstructions  = @"eighteenToTwentyInstructions";



@interface APHHeartAgeResultsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *heartAndRiskData;
@property (strong, nonatomic)NSMutableArray *summaryData;

@property (strong, nonatomic) NSAttributedString *tenYearRiskDescriptionAttributedText;
@property (strong, nonatomic) NSAttributedString *lifeTimeRiskDescriptionAttributedText;

@property (nonatomic) NSInteger numberOfSections;

- (IBAction)ASCVDRiskEstimatorActionButton:(id)sender;
@end

@implementation APHHeartAgeResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSLog(@"Task Identifier : %@", self.taskViewController.task.identifier);
    
    UIColor *viewBackgroundColor = [UIColor appSecondaryColor4];
    
    [self.view setBackgroundColor:viewBackgroundColor];
    [self.tableView setBackgroundColor:viewBackgroundColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTapped:)];
    
    // This will trigger self-sizing rows in the tableview
    self.tableView.estimatedRowHeight = 90.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.heartAndRiskData = [NSMutableArray new];
    self.summaryData = [NSMutableArray new];
    
    self.numberOfSections = 2;
    
    if ((self.actualAge > 40) && (self.actualAge < 59))
    {
        [self.heartAndRiskData addObject:kHeartAgeResults];
        [self.heartAndRiskData addObject:kTenYearRisk];
        [self.heartAndRiskData addObject:kLifeTimeRisk];
        
        [self.summaryData addObject:kHeartAgeSummaryTitle];
        [self.summaryData addObject:kTenYearRisk];
        [self.summaryData addObject:kLifeTimeRisk];
    }
    
    else if ((self.actualAge >= 20) && (self.actualAge <= 59))
        
    {
        [self.heartAndRiskData addObject:kHeartAgeResults];
        [self.heartAndRiskData addObject:kLifeTimeRisk];
        
        [self.summaryData addObject:kHeartAgeSummaryTitle];
        [self.summaryData addObject:kLifeTimeRisk];
    }
    
    else if ((self.actualAge >= 40) && (self.actualAge <= 79))
        
    {
        [self.heartAndRiskData addObject:kHeartAgeResults];
        [self.heartAndRiskData addObject:kTenYearRisk];
        
        [self.summaryData addObject:kHeartAgeSummaryTitle];
        [self.summaryData addObject:kTenYearRisk];
    }
    
    else if ((self.actualAge >= 18) && (self.actualAge <= 20))
        
    {
        [self.heartAndRiskData addObject:kHeartAgeResults];
        
        [self.summaryData addObject:kEighteenToTwentyInstructions];
    }
    
    else {
        self.numberOfSections = 1;
        [self.heartAndRiskData addObject:kHeartAgeResults];
    }
    
    [self.tableView reloadData];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    [self createAttributedStrings];
}

#pragma mark - Actions

- (void)doneButtonTapped:(UIBarButtonItem *)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)] == YES) {
            [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
        }
    }
}

#pragma mark - TableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = tableView.rowHeight;
    
    NSString *objectId = [self.heartAndRiskData objectAtIndex:indexPath.row];
    
    if (indexPath.section) {
        
        objectId = [self.summaryData objectAtIndex:indexPath.row];
        
        if ([objectId isEqualToString:kLifeTimeRisk])
        {
            height = tableView.rowHeight;
        }

        else if ([objectId isEqualToString:kTenYearRisk]) {
            
            height = tableView.rowHeight;
        }
        
        else if ([objectId isEqualToString:kEighteenToTwentyInstructions]) {
            
            height = tableView.rowHeight;
        }
        
        else if ([objectId isEqualToString:kHeartAgeSummaryTitle]) {
            
            height = 50;
        }
        
        else
        {
            height = tableView.rowHeight;
        }
    } else {
        
        objectId = [self.heartAndRiskData objectAtIndex:indexPath.row];
        
        if ([objectId isEqualToString:kHeartAgeResults])
        {
            height = 190;
        }
        
        else if ([objectId isEqualToString:kLifeTimeRisk] || [objectId isEqualToString:kTenYearRisk])
        {
            height = 220;
        }
        
        else if ([objectId isEqualToString:kEighteenToTwentyInstructions]) {
            
            height = tableView.rowHeight;
        }
        
        else if ([objectId isEqualToString:kHeartAgeSummaryTitle]) {
            
            height = 50;
        }
        
        else
        {
            height = tableView.rowHeight;
        }
    }

    
    return height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    if (section)
    {
        height = 20.0;
    }
    else
    {
        height = 0;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rows = 0;
    
    if (section)
    {
        rows = self.summaryData.count;
    }
    else
    {
        rows = self.heartAndRiskData.count;
    }

    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section) {
        
        NSString *objectId = [self.summaryData objectAtIndex:indexPath.row];
        
        if ([objectId isEqualToString:kHeartAgeResults])
        {
            cell = [self configureHeartAgeEstimateCellAtIndexPath:indexPath];
        }
        else if ([objectId isEqualToString:kLifeTimeRisk])
        {
            APHHeartAgeRecommendationCell *titleSummaryCell = [tableView dequeueReusableCellWithIdentifier:@"LifeTimeRiskScoreSummaryCell"];
            
            titleSummaryCell.recommendationText.attributedText = self.lifeTimeRiskDescriptionAttributedText;
            
            cell = titleSummaryCell;

        }
        else if ([objectId isEqualToString:kTenYearRisk])
        {
            APHHeartAgeTenYearRecommendationCell *titleSummaryCell = [tableView dequeueReusableCellWithIdentifier:@"TenYearRiskScoreSummaryCell"];
            
            titleSummaryCell.recommendationText.attributedText = self.tenYearRiskDescriptionAttributedText;
            
            cell = titleSummaryCell;
        }
        else if ([objectId isEqualToString:kHeartAgeSummaryTitle])
        {
            APHHeartAgeSummaryTitleCell *titleSummaryCell = [tableView dequeueReusableCellWithIdentifier:@"HeartAgeSummaryTitleCell"];
            
            cell = titleSummaryCell;
        }
        else if ([objectId isEqualToString:kEighteenToTwentyInstructions]) {
            APHInstructionsForBelowTwentyTableViewCell *titleSummaryCell = [tableView dequeueReusableCellWithIdentifier:@"eighteenToTwentyInstructions"];
            
            titleSummaryCell.descriptionLabel.text = @"Due to your current age we have no way to perform any calculations to give you any further information about your risk for ASVCD."; 
            cell = titleSummaryCell;
        }
    }
    
    else
        
    {
        NSString *objectId = [self.heartAndRiskData objectAtIndex:indexPath.row];
        
        if ([objectId isEqualToString:kHeartAgeResults])
        {
            cell = [self configureHeartAgeEstimateCellAtIndexPath:indexPath];
        }
        else if ([objectId isEqualToString:kLifeTimeRisk])
        {
            cell = [self configureRiskEstimateCellAtIndexPath:objectId];
        }
        else if ([objectId isEqualToString:kTenYearRisk])
        {
            cell = [self configureRiskEstimateCellAtIndexPath:objectId];
        }
    }
    return cell;
}

#pragma mark Cell Configurations

- (APHHeartAgeSummaryCell *)configureHeartAgeEstimateCellAtIndexPath:(NSIndexPath *)indexPath
{
    APHHeartAgeSummaryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kHeartAgeCellIdentifier];
    
    cell.heartAgeTitle = NSLocalizedString(@"Your Heart Age Estimate", @"Your Heart Age Estimate");
    cell.actualAgeLabel = NSLocalizedString(@"Actual Age", @"Actual Age");
    cell.heartAgeLabel = NSLocalizedString(@"Heart Age", @"Heart Age");
    
    cell.actualAgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)self.actualAge];
    cell.heartAgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)self.heartAge];
    
    if (self.heartAge <= self.actualAge)
    {
        cell.heartAge.textColor = [UIColor appTertiaryColor1];
    }
    else
    {
        cell.heartAge.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (APHHeartAgeRiskEstimateCell *)configureRiskEstimateCellAtIndexPath:(NSString *)objectId
{
    APHHeartAgeRiskEstimateCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kRiskEstimateCellIdenfier];

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [numberFormatter setMaximumFractionDigits:0];
    
    NSString *calculatedRisk = nil;
    NSString *optimalRisk = nil;
    static double kOnePercent = 0.01;
    
    if ([objectId  isEqual: kTenYearRisk]) {

        cell.riskCellTitle.text = NSLocalizedString(@"10-Year Risk Estimate", @"10-year risk estimate");
        
        cell.riskEstimateDescription.text = @"According to your answers, your calculated risk of developing ASCVD within 10 years is:";
        
        if ([self.tenYearRisk doubleValue] < kOnePercent) {
            calculatedRisk = @"< 1%";
        } else {
            calculatedRisk = [numberFormatter stringFromNumber:self.tenYearRisk];
        }
        
        if ([self.optimalTenYearRisk doubleValue] < kOnePercent) {
            optimalRisk = @"< 1%";
        } else {
            optimalRisk = [numberFormatter stringFromNumber:self.optimalTenYearRisk];
        }
        
        if ([self.tenYearRisk doubleValue] > 7.5)
        {
            cell.calculatedRisk.textColor = [UIColor blackColor];
        }
        else
        {
            cell.calculatedRisk.textColor = [UIColor appTertiaryColor1];
        }

        
    } else {
        cell.riskCellTitle.text = NSLocalizedString(@"Lifetime Risk Estimate", @"Lifetime risk estimate");
        
        calculatedRisk = [NSString stringWithFormat:@"%lu%%", (long)[self.lifetimeRisk integerValue]];
        
        optimalRisk = [NSString stringWithFormat:@"%lu%%", (long)[self.optimalLifetimeRisk integerValue]];
        
        cell.riskEstimateDescription.text = @"According to your answers, your calculated risk of developing ASCVD within your lifetime is:";
        
        if ([self.lifetimeRisk floatValue] > 7.5)
        {
            cell.calculatedRisk.textColor = [UIColor blackColor];
        }
        else
        {
            cell.calculatedRisk.textColor = [UIColor appTertiaryColor1];
        }        
    }

    cell.calculatedRisk.text = calculatedRisk;
    cell.optimalFactorRisk.text = optimalRisk;
    
    return cell;
}


- (IBAction)ASCVDRiskEstimatorActionButton:(id)sender {
    
    APHRiskEstimatorWebViewController *viewController = [[APHRiskEstimatorWebViewController alloc] init];
    

    [self presentViewController:viewController animated:YES completion:nil];
    
}

#pragma mark - Helper methods 

- (void)createAttributedStrings {
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        
        NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:@"10-Year Risk Score: "];
        [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [@"10-Year Risk Score: " length])];
        
        [attribString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[attribString length])];
        [attribString addAttribute:NSFontAttributeName value:[UIFont fontWithName: @"Helvetica-Bold" size:17.0] range:NSMakeRange(0,[attribString length])];
        
        NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithString:@"In general a 10-year risk > 7.5% is considered high and warrants discussion with your doctor. There may be other medical or family history that can increase your risk and these should be discussed with your doctor."];
        
        NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle2.lineBreakMode = NSLineBreakByWordWrapping;
        [finalString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [finalString length])];
        
        [finalString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[finalString length])];
        
        [attribString appendAttributedString:finalString];
        
        
        self.tenYearRiskDescriptionAttributedText = attribString;
    }
    
    {

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
        
        NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:@"Lifetime Risk Score: "];
        [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [@"Lifetime Risk Score: " length])];
        [attribString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[attribString length])];
        [attribString addAttribute:NSFontAttributeName value:[UIFont fontWithName: @"Helvetica-Bold" size:17.0] range:NSMakeRange(0,[attribString length])];
        
        NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithString:@"For official recommendations, please refer to the guide from the American College of Cardiology-"];
        
        NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle2.lineBreakMode = NSLineBreakByWordWrapping;
        [finalString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [finalString length])];
        
        [finalString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[finalString length])];
        
        [attribString appendAttributedString:finalString];
        
        self.lifeTimeRiskDescriptionAttributedText = attribString;
    }
    
}

@end
