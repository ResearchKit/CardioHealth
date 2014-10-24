//
//  APHIntroductionViewController.m
//  Parkinson
//
//  Created by Henry McGilton on 10/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHIntroductionViewController.h"

static  NSString  *kSuperClassName = @"APCIntroductionViewController";

@interface APHIntroductionViewController ()

@end

@implementation APHIntroductionViewController

- (UIImage *)imageOfName:(NSString *)name
{
    UIImage  *image = [UIImage imageNamed:name];
    return  image;
}

- (void)setupWithInstructionalImages:(NSArray *)imageNames andParagraphs:(NSArray *)paragraphs
{
    [super setupWithInstructionalImages:imageNames andParagraphs:paragraphs];
}

#pragma  mark  -  View Controller Methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:kSuperClassName bundle:[NSBundle appleCoreBundle]];
    if (self != nil) {
        
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
