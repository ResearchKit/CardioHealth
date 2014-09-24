//
//  APHSignInViewController.m

//
//  Created by Karthik Keyan on 9/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import APCAppleCore;
#import "APHCardioHealthAppDelegate.h"
#import "APHSignInViewController.h"

static NSString *const kLoggedInKey = @"LoggedIn";

@interface APHSignInViewController ()

@end

@implementation APHSignInViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userHandleTextField.font = [UITableView textFieldFont];
    self.userHandleTextField.textColor = [UITableView textFieldTextColor];
    
    self.passwordTextField.font = [UITableView textFieldFont];
    self.passwordTextField.textColor = [UITableView textFieldTextColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) isContentValid:(NSString **)errorMessage {
    BOOL isContentValid = NO;
    
    if (self.userHandleTextField.text.length == 0) {
        *errorMessage = NSLocalizedString(@"Please enter your user name or email", @"");
        isContentValid = NO;
    }
    else if (self.passwordTextField.text.length == 0) {
        *errorMessage = NSLocalizedString(@"Please enter your password", @"");
        isContentValid = NO;
    }
    else {
        isContentValid = YES;
    }
    
    return isContentValid;
}

- (void) signIn {
    NSString *errorMessage;
    if ([self isContentValid:&errorMessage]) {
        APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
        [self presentViewController:spinnerController animated:YES completion:nil];
        
        APCSageNetworkManager *networkManager = (APCSageNetworkManager *)[(APHCardioHealthAppDelegate *)[[UIApplication sharedApplication] delegate] networkManager];
        
        [networkManager signIn:self.userHandleTextField.text password:self.passwordTextField.text success:^(NSURLSessionDataTask *task, id responseObject) {
            [NSObject performInMainThread:^{
                [spinnerController dismissViewControllerAnimated:YES completion:nil];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLoggedInKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)APCUserLoginNotification object:nil];
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [NSObject performInMainThread:^{
                [spinnerController dismissViewControllerAnimated:YES completion:nil];
                 
                 if (error.code == kAPCServerPreconditionNotMet) {
                     [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)APCUserLoginNotification object:nil];
                 }
                 else {
                     [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:error.message];
                 }
             }];
        }];
    }
    else {
        [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:errorMessage];
    }
}

@end
