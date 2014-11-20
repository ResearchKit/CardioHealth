//
//  APHStackedCircleView.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kDatasetDateKey;
extern NSString *const kDatasetValueKey;
extern NSString *const kDatasetSegmentNameKey;
extern NSString *const kDatasetSegmentColorKey;

@interface APHStackedCircleView : UIView

@property (nonatomic) BOOL hideAllLabels;
@property (nonatomic) BOOL hideInsideLabels;
@property (nonatomic) BOOL hideOutsideLabels;
@property (nonatomic) BOOL hideLegend;

@property (nonatomic, strong) NSArray *scale;
@property (nonatomic, strong) NSString *insideCaptionText;

- (void)plotSegmentValues:(NSArray *)values;

@end
