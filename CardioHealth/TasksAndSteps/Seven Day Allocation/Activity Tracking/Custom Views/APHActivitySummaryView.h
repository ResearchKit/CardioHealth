//
//  APHActivitySummaryView.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APHActivitySummaryView : UIView

@property (nonatomic) NSUInteger numberOfSegments;

@property (nonatomic) BOOL hideAllLabels;
@property (nonatomic) BOOL hideInsideLabels;
@property (nonatomic) BOOL hideOutsideLabels;
@property (nonatomic) BOOL hideLegend;

- (void)drawWithSegmentValues:(NSArray *)values;

@end
