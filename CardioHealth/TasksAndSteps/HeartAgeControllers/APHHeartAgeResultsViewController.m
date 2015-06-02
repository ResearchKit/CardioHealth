// 
//  APHHeartAgeResultsViewController.m 
//  MyHeart Counts 
// 
// Copyright (c) 2015, Stanford Medical. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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

static CGFloat kTitleFontSize = 17.0f;

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
    
    if ((self.actualAge >= 40) && (self.actualAge <= 59))
    {
        if (![self.taskViewController.task.identifier isEqualToString:kKludgeIdentifierForHeartAgeTaskB]) {
            [self.heartAndRiskData addObject:kHeartAgeResults];
        }
        
        [self.heartAndRiskData addObject:kTenYearRisk];
        [self.heartAndRiskData addObject:kLifeTimeRisk];
        
        [self.summaryData addObject:kHeartAgeSummaryTitle];
        [self.summaryData addObject:kTenYearRisk];
        [self.summaryData addObject:kLifeTimeRisk];
    }
    
    else if ((self.actualAge >= 20) && (self.actualAge <= 59))
        
    {
        if (![self.taskViewController.task.identifier isEqualToString:kKludgeIdentifierForHeartAgeTaskB]) {
            [self.heartAndRiskData addObject:kHeartAgeResults];
        }
        
        [self.heartAndRiskData addObject:kLifeTimeRisk];
        
        [self.summaryData addObject:kHeartAgeSummaryTitle];
        [self.summaryData addObject:kLifeTimeRisk];
    }
    
    else if ((self.actualAge >= 40) && (self.actualAge <= 79))
        
    {
        if (![self.taskViewController.task.identifier isEqualToString:kKludgeIdentifierForHeartAgeTaskB]) {
            [self.heartAndRiskData addObject:kHeartAgeResults];
        }
        
        [self.heartAndRiskData addObject:kTenYearRisk];
        
        [self.summaryData addObject:kHeartAgeSummaryTitle];
        [self.summaryData addObject:kTenYearRisk];
    }
    
    else if ((self.actualAge >= 18) && (self.actualAge <= 20))
        
    {
        if (![self.taskViewController.task.identifier isEqualToString:kKludgeIdentifierForHeartAgeTaskB]) {
            [self.heartAndRiskData addObject:kHeartAgeResults];
        }
        
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

- (void)doneButtonTapped:(UIBarButtonItem *) __unused sender
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
    NSString *objectId = @"";
    
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

- (CGFloat) tableView:(UITableView *) __unused tableView heightForHeaderInSection:(NSInteger)section
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView
{
    return self.numberOfSections;
}

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger)section
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
            titleSummaryCell.hideLinkButton = YES;
            cell = titleSummaryCell;

        }
        else if ([objectId isEqualToString:kTenYearRisk])
        {
            APHHeartAgeRecommendationCell *titleSummaryCell = [tableView dequeueReusableCellWithIdentifier:@"LifeTimeRiskScoreSummaryCell"];
            
            titleSummaryCell.recommendationText.attributedText = self.tenYearRiskDescriptionAttributedText;
            titleSummaryCell.hideLinkButton = NO;
            cell = titleSummaryCell;
        }
        else if ([objectId isEqualToString:kHeartAgeSummaryTitle])
        {
            APHHeartAgeSummaryTitleCell *titleSummaryCell = [tableView dequeueReusableCellWithIdentifier:@"HeartAgeSummaryTitleCell"];
            
            cell = titleSummaryCell;
        }
        else if ([objectId isEqualToString:kEighteenToTwentyInstructions]) {
            APHInstructionsForBelowTwentyTableViewCell *titleSummaryCell = [tableView dequeueReusableCellWithIdentifier:@"eighteenToTwentyInstructions"];
            
            titleSummaryCell.descriptionLabel.text = NSLocalizedString(@"Due to your current age we have no way to perform any calculations to give you any further information about your risk for ASVCD.\n", nil);
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

- (APHHeartAgeSummaryCell *)configureHeartAgeEstimateCellAtIndexPath:(NSIndexPath *) __unused indexPath
{
    APHHeartAgeSummaryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kHeartAgeCellIdentifier];
    
    cell.heartAgeTitle = NSLocalizedString(@"Your Heart Age Estimate", @"Your Heart Age Estimate");
    cell.actualAgeLabel = NSLocalizedString(@"Actual Age", @"Actual Age");
    cell.heartAgeLabel = NSLocalizedString(@"Heart Age", @"Heart Age");
    
    //These have been switched around.
    NSString *heartAgeCaption = nil;
    
    if ((self.actualAge >= 40) && (self.actualAge <= 79)) {
        if (self.heartAge < 40) {
            heartAgeCaption = @"< 40";
        } else if (self.heartAge > 79) {
            heartAgeCaption = @"> 79";
        } else {
            heartAgeCaption = [NSString stringWithFormat:@"%lu", (unsigned long)self.heartAge];
        }
    } else {
        heartAgeCaption = @"N/A";
    }
    
    
    cell.actualAgeValue = heartAgeCaption;
    cell.heartAgeValue =[NSString stringWithFormat:@"%lu", (unsigned long)self.actualAge];
    
    cell.heartAge.textColor = [UIColor blackColor];
    
    
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
        
        cell.riskEstimateDescription.text = NSLocalizedString(@"According to your answers, your calculated risk of developing Heart Disease or Stroke within 10 years is:", @"According to your answers, your calculated risk of developing Heart Disease or Stroke within 10 years is:");
        
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
        
        cell.calculatedRisk.textColor = [UIColor blackColor];
        
    } else {
        cell.riskCellTitle.text = NSLocalizedString(@"Lifetime Risk Estimate", @"Lifetime risk estimate");
        
        calculatedRisk = [NSString stringWithFormat:@"%lu%%", (long)[self.lifetimeRisk integerValue]];
        
        optimalRisk = [NSString stringWithFormat:@"%lu%%", (long)[self.optimalLifetimeRisk integerValue]];
        
        cell.riskEstimateDescription.text = NSLocalizedString(@"According to your answers, your calculated risk of developing Heart Disease or Stroke within your lifetime is:", @"According to your answers, your calculated risk of developing Heart Disease or Stroke within your lifetime is:" );
        
        cell.calculatedRisk.textColor = [UIColor blackColor];
    }

    cell.calculatedRisk.text = calculatedRisk;
    cell.optimalFactorRisk.text = optimalRisk;
    
    return cell;
}


- (IBAction)ASCVDRiskEstimatorActionButton:(id) __unused sender {
    
    APHRiskEstimatorWebViewController *viewController = [[APHRiskEstimatorWebViewController alloc] init];
    

    [self presentViewController:viewController animated:YES completion:nil];
    
}

#pragma mark - Helper methods 

- (void)createAttributedStrings {
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
        [paragraphStyle setAlignment:NSTextAlignmentLeft];

        NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"10-Year Risk Score: ", @"10-Year Risk Score: ")];
        [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [@"10-Year Risk Score: " length])];
        
        [attribString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[attribString length])];
        [attribString addAttribute:NSFontAttributeName value:[UIFont fontWithName: @"Helvetica-Bold" size:kTitleFontSize] range:NSMakeRange(0,[attribString length])];
        
        NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"In general a 10-year risk > 7.5% is considered high and warrants discussion with your doctor. There may be other medical or family history that can increase your risk and these should be discussed with your doctor.\n\nFor official recommendations, please refer to the guide from the American College of Cardiology -", @"In general a 10-year risk > 7.5% is considered high and warrants discussion with your doctor. There may be other medical or family history that can increase your risk and these should be discussed with your doctor.")];
        
        NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle2.lineBreakMode = NSLineBreakByWordWrapping;
        [finalString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [finalString length])];
        
        [finalString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[finalString length])];
        
        [attribString appendAttributedString:finalString];
        
        
        self.tenYearRiskDescriptionAttributedText = attribString;
    }
    
    {

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
        
        NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"Lifetime Risk Score: ", @"Lifetime Risk Score: ")];
        [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [@"Lifetime Risk Score: " length])];
        [attribString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[attribString length])];
        [attribString addAttribute:NSFontAttributeName value:[UIFont fontWithName: @"Helvetica-Bold" size:kTitleFontSize] range:NSMakeRange(0,[attribString length])];
        
        NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"This is based on data comparing risk factors and the likelihood of developing heart disease or stroke over a lifetime. In the US, approximately 1 in 2 men and 1 in 3 women will develop cardiovascular disease in their life. Having more optimal risk factors is associated with a lower lifetime risk.\n", nil)];
        
        NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle2.lineBreakMode = NSLineBreakByWordWrapping;
        [finalString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [finalString length])];
        
        [finalString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[finalString length])];
        
        [attribString appendAttributedString:finalString];
        
        self.lifeTimeRiskDescriptionAttributedText = attribString;
    }
    
}

@end
