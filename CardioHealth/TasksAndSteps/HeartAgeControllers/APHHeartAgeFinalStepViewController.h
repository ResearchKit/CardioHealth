//
//  APHHeartAgeFinalStepViewController.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 9/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <APCAppleCore/APCAppleCore.h>
#import "APHHeartAgeVersusView.h"

@interface APHHeartAgeFinalStepViewController : APCStepViewController

@property (weak, nonatomic) IBOutlet APCCircularProgressView *circularProgress;
@property (weak, nonatomic) IBOutlet APHHeartAgeVersusView *ageVersusHeartAge;

@end
