//
//  APHLearnStudyDetailsViewController.m
//  CardioHealth
//
//  Created by Ramsundar Shandilya on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHLearnStudyDetailsViewController.h"

@interface APHLearnStudyDetailsViewController () <RKSTTaskViewControllerDelegate>

@end

@implementation APHLearnStudyDetailsViewController

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
    [self studyDetailsFromJSONFile:@"StudyOverview"];
    
    
    APCTableViewStudyDetailsItem *reviewConsentItem = [APCTableViewStudyDetailsItem new];
    reviewConsentItem.caption = NSLocalizedString(@"Review Consent", nil);
    reviewConsentItem.iconImage = [UIImage imageNamed:@"consent_icon"];
    reviewConsentItem.tintColor = [UIColor appTertiaryPurpleColor];
    
    APCTableViewRow *rowItem = [APCTableViewRow new];
    rowItem.item = reviewConsentItem;
    
    APCTableViewSection *section = [self.items firstObject];
    NSMutableArray *rowItems = [NSMutableArray arrayWithArray:section.rows];
    [rowItems addObject:rowItem];
    section.rows = [NSArray arrayWithArray:rowItems];
    
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
    
    APCTableViewStudyDetailsItem *studyDetails = [self itemForIndexPath:indexPath];
    
    if (indexPath.row == 4) {
        APCShareViewController *shareViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"ShareVC"];
        shareViewController.hidesOkayButton = YES;
        [self.navigationController pushViewController:shareViewController animated:YES];
        
    } else if (indexPath.row == 5) {
        [self showConsent];
    } else {
        APCStudyDetailsViewController *detailsViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"StudyDetailsVC"];
        detailsViewController.studyDetails = studyDetails;
        [self.navigationController pushViewController:detailsViewController animated:YES];
    }
}

#pragma mark - Consent

- (void)showConsent
{
    RKSTConsentDocument* consent = [[RKSTConsentDocument alloc] init];
    consent.title = @"Demo Consent";
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    
//    RKSTConsentSignature *participantSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Participant" name:nil signatureImage:nil dateString:nil];
    RKSTConsentSignature *participantSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Participant"
                                                                                 name:nil
                                                                       signatureImage:nil
                                                                           dateString:nil
                                                                           identifier:@"participant"];
    [consent addSignature:participantSig];
    
//    RKSTConsentSignature *investigatorSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Investigator" name:@"Jake Clemson" signatureImage:[UIImage imageNamed:@"signature.png"] dateString:@"9/2/14"];
    RKSTConsentSignature *investigatorSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Investigator"
                                                                                name:@"Jake Clemson"
                                                                      signatureImage:[UIImage imageNamed:@"signature.png"]
                                                                          dateString:@"9/2/14"
                                                                          identifier:@"investigator"];
    [consent addSignature:investigatorSig];
    
    
    
    
    NSMutableArray* components = [NSMutableArray new];
    
    NSArray* scenes = @[@(RKSTConsentSectionTypeOverview),
                        @(RKSTConsentSectionTypeActivity),
                        @(RKSTConsentSectionTypeSensorData),
                        @(RKSTConsentSectionTypeDeIdentification),
                        @(RKSTConsentSectionTypeCombiningData),
                        @(RKSTConsentSectionTypeUtilizingData),
                        @(RKSTConsentSectionTypeImpactLifeTime),
                        @(RKSTConsentSectionTypePotentialRiskUncomfortableQuestion),
                        @(RKSTConsentSectionTypePotentialRiskSocial),
                        @(RKSTConsentSectionTypeAllowWithdraw)];
    for (NSNumber* type in scenes) {
        RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:type.integerValue];
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    {
        RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:RKSTConsentSectionTypeCustom];
        c.summary = @"Custom Scene summary";
        c.title = @"Custom Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        c.customImage = [UIImage imageNamed:@"image_example.png"];
        [components addObject:c];
    }
    
    {
        RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:RKSTConsentSectionTypeOnlyInDocument];
        c.summary = @"OnlyInDocument Scene summary";
        c.title = @"OnlyInDocument Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    consent.sections = [components copy];
    
    RKSTVisualConsentStep *step = [[RKSTVisualConsentStep alloc] initWithDocument:consent];
    RKSTConsentReviewStep *reviewStep = [[RKSTConsentReviewStep alloc] initWithSignature:participantSig inDocument:consent];
//    RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithidentifier:@"consent" steps:@[step,reviewStep]];
    RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithIdentifier:@"consent" steps:@[step, reviewStep]];
//    RKSTTaskViewController *consentVC = [[RKSTTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    RKSTTaskViewController *consentVC = [[RKSTTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    
    consentVC.taskDelegate = self;
    [self presentViewController:consentVC animated:YES completion:nil];
    
}

#pragma mark - TaskViewController Delegate methods

- (void)taskViewControllerDidComplete: (RKSTTaskViewController *)taskViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController
{
    [taskViewController suspend];
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController didFailOnStep:(RKSTStep *)step withError:(NSError *)error
{
    // Handle the failure gracefully.
}

@end
