//
//  APHHeartAgeFinalStepViewController.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 9/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <APCAppleCore/APCAppleCore.h>
#import "APHHeartAgeVersusView.h"

@interface APHHeartAgeResultsViewController : APCStepViewController

@property (weak, nonatomic) IBOutlet APCCircularProgressView *circularProgress;
@property (weak, nonatomic) IBOutlet APHHeartAgeVersusView *ageVersusHeartAge;
@property (weak, nonatomic) IBOutlet UILabel *tenYearRiskText;
@property (weak, nonatomic) IBOutlet UILabel *improvementText;

@end
