//
//  APHWalkingTestComparisonViewController.m
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

#import "APHWalkingTestComparisonViewController.h"

@interface APHWalkingTestComparisonViewController ()

@end

@implementation APHWalkingTestComparisonViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.graphView.datasource = self.comparisonItem.comparisonObject;
    self.graphView.tintColor = self.comparisonItem.tintColor;
    self.graphView.landscapeMode = YES;
    
    CGFloat zScore = [self.comparisonItem.comparisonObject zScoreForDistanceWalked:self.comparisonItem.distanceWalked];
    CGFloat myScore = [self.comparisonItem.comparisonObject distancePercentForZScore:zScore];
    self.graphView.value = myScore;
    
    [self setupAppearance];
    
    self.titleLabel.text = NSLocalizedString(@"6-Minute Walk Test Comparison", nil);
    
    NSLengthFormatter* lengthFormatter = [NSLengthFormatter new];
    NSString* distanceWalkedString = [lengthFormatter unitStringFromValue:(double)self.comparisonItem.distanceWalked
                                                           unit:NSLengthFormatterUnitYard];
    
    self.distanceLabel.text = distanceWalkedString;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.graphView refreshGraph];
}

- (void)setupAppearance
{
    self.titleLabel.font = [UIFont appRegularFontWithSize:24.0f];
    self.titleLabel.textColor = self.comparisonItem.tintColor;
    
    NSString *text = NSLocalizedString(@"You vs Others", nil);
    
    NSMutableAttributedString *attirbutedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attirbutedString addAttribute:NSForegroundColorAttributeName value:[UIColor appTertiaryRedColor] range:[text rangeOfString:@"You"]];
    [attirbutedString addAttribute:NSForegroundColorAttributeName value:[UIColor appSecondaryColor2] range:[text rangeOfString:@"vs"]];
    [attirbutedString addAttribute:NSForegroundColorAttributeName value:self.comparisonItem.tintColor range:[text rangeOfString:@"Others"]];
    self.subtitleLabel.attributedText = attirbutedString;
    
    self.subtitleLabel.font = [UIFont appRegularFontWithSize:16.0f];
    
    self.distanceLabel.font = [UIFont appRegularFontWithSize:16.0f];
    self.distanceLabel.textColor = [UIColor appSecondaryColor2];
    
    [self.collapseButton setImage:[[UIImage imageNamed:@"collapse_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.collapseButton.imageView setTintColor:self.comparisonItem.tintColor];
    
    self.tintView.backgroundColor = self.comparisonItem.tintColor;
}

/***********************************/
#pragma mark - Orientation methods
/***********************************/

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

/***********************************/
#pragma mark - IBActions
/***********************************/

- (IBAction)dismiss:(id)__unused sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
