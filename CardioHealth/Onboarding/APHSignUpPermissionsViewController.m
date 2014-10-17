//
//  APHSignUpPermissionsViewController.m
//  Parkinson
//
//  Created by Ramsundar Shandilya on 10/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHSignUpPermissionsViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "APHAppDelegate.h"

@interface APHSignUpPermissionsViewController ()

@end

@implementation APHSignUpPermissionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareData
{
    NSMutableArray *items = [NSMutableArray new];
    
    NSDictionary *initialOptions = ((APHAppDelegate *)[UIApplication sharedApplication].delegate).initializationOptions;
    NSArray *servicesArray = initialOptions[kAppServicesListRequiredKey];
    
    for (NSNumber *type in servicesArray) {
        
        APCSignUpPermissionsType permissionType = type.integerValue;
        
        switch (permissionType) {
            case kSignUpPermissionsTypeHealthKit:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kSignUpPermissionsTypeHealthKit;
                item.caption = NSLocalizedString(@"Health Kit", @"");
                item.detailText = NSLocalizedString(@"Lorem ipsum dolor sit amet, etos et ya consectetur adip isicing elit, sed.", @"");
                [items addObject:item];
            }
                break;
            case kSignUpPermissionsTypeLocation:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kSignUpPermissionsTypeLocation;
                item.caption = NSLocalizedString(@"Location Services", @"");
                item.detailText = NSLocalizedString(@"Lorem ipsum dolor sit amet, etos et ya consectetur adip isicing elit, sed.", @"");
                [items addObject:item];
            }
                break;
            case kSignUpPermissionsTypeCoremotion:
            {
                if ([CMMotionActivityManager isActivityAvailable]){
                    APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                    item.permissionType = kSignUpPermissionsTypeCoremotion;
                    item.caption = NSLocalizedString(@"Core Motion", @"");
                    item.detailText = NSLocalizedString(@"Lorem ipsum dolor sit amet, etos et ya consectetur adip isicing elit, sed.", @"");
                    [items addObject:item];
                }
            }
                break;
            case kSignUpPermissionsTypePushNotifications:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kSignUpPermissionsTypePushNotifications;
                item.caption = NSLocalizedString(@"Push Notifications", @"");
                item.detailText = NSLocalizedString(@"Lorem ipsum dolor sit amet, etos et ya consectetur adip isicing elit, sed.", @"");
                [items addObject:item];
            }
                break;
                
            default:
                break;
        }
    }
    
    self.permissions = items;
}


- (IBAction)next:(id)sender {
    [self finishSignUp];
}

@end
