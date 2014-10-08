//
//  APHSignInViewController.m
//  Parkinson
//
//  Created by Karthik Keyan on 9/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHCardioHealthAppDelegate.h"
#import "APHSignInViewController.h"

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
        
        APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
        APCUser * user = appDelegate.dataSubstrate.currentUser;
        
        if (!user.userName) {
            user.userName = self.userHandleTextField.text;
            user.password = self.passwordTextField.text;
            [user signInOnCompletion:^(NSError *error) {
                [spinnerController dismissViewControllerAnimated:YES completion:^{
                    if (error) {
                        [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:error.message];
                    }
                    else
                    {
                        user.signedIn = YES;
                    }
                }];
                
            }];
            
        }
        else if ([self.userHandleTextField.text isEqualToString:user.userName]) {
            [user signInOnCompletion:^(NSError *error) {
                [spinnerController dismissViewControllerAnimated:YES completion:^{
                    if (error) {
                        [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:error.message];
                    }
                    else
                    {
                        user.signedIn = YES;
                    }
                }];
                
            }];
        }
        else
        {
            [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:NSLocalizedString(@"Username does not match the existing username. Please delete the app to login as new user.", @"")];
        }
    }
    else {
        [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:errorMessage];
    }
}


@end
