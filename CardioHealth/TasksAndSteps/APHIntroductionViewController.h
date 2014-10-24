//
//  APHIntroductionViewController.h
//  Parkinson
//
//  Created by Henry McGilton on 10/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <APCAppleCore/APCAppleCore.h>

@interface APHIntroductionViewController : APCIntroductionViewController

- (UIImage *)imageOfName:(NSString *)name;

- (void)setupWithInstructionalImages:(NSArray *)imageNames andParagraphs:(NSArray *)paragraphs;

@end
