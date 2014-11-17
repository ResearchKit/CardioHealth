//
//  APHActivitySummaryView.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHActivitySummaryView.h"
#import "APHTheme.h"

NSString *const kDatasetDateKey = @"datasetDateKey";
NSString *const kDatasetValueKey = @"datasetValueKey";
NSString *const kDatasetSegmentNameKey = @"datasetSegmentNameKey";

@interface APHActivitySummaryView()

@property (nonatomic, strong) CAShapeLayer *circle;
@property (nonatomic, strong) NSArray *segmentValues;
@property (nonatomic, strong) NSArray *segementColors;

@property (nonatomic) double lastPercentage;
@property (nonatomic) double sumQuantity;

@end

@implementation APHActivitySummaryView

- (void)commonInit
{
    self.backgroundColor = [UIColor whiteColor];
    self.segementColors = @[
                            [APHTheme colorForActivityInactive],
                            [APHTheme colorForActivitySedentary],
                            [APHTheme colorForActivityModerate],
                            [APHTheme colorForActivityVigorous]
                           ];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)layoutSubviews
{
    // Add the CAShapeLayer
    // Set up the shape of the circle
    int radius = self.frame.size.width * 0.3;
    _circle = [CAShapeLayer layer];
    // Make a circular shape
    _circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                              cornerRadius:radius].CGPath;
    // Center the shape in self.view
    _circle.position = CGPointMake(CGRectGetMidX(self.frame)-radius,
                                   CGRectGetMidY(self.frame)-radius*2);
    
    // Configure the apperence of the circle
    _circle.fillColor = [UIColor clearColor].CGColor;
    _circle.strokeColor = [APHTheme colorForActivityOutline].CGColor;
    _circle.lineWidth = 20;
    
    // Add to parent layer
    [self.layer addSublayer:self.circle];
    
    CAShapeLayer *border = [CAShapeLayer layer];
    border.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 64)].CGPath;
    border.fillColor = [UIColor clearColor].CGColor;
    border.strokeColor = [APHTheme colorForDividerLine].CGColor;
    border.lineWidth = 1.0;
    
    [self.layer addSublayer:border];
    
    [self drawLegend];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (void)drawWithSegmentValues:(NSArray *)values
{
    if (values) {
        self.segmentValues = values;
        self.sumQuantity = [[self.segmentValues valueForKeyPath:@"@sum.datasetValueKey"] doubleValue];
        
        [self drawCircle];
    }
}

#pragma mark - Percent

- (double)percentageOfValue:(double)value
{
    double percentage = 0.0;
    
    percentage = value / self.sumQuantity;
    
    NSLog(@"%f", percentage);
    
    return percentage;
}

#pragma mark - Drawing
#pragma mark Legend

- (void)drawLegend
{
    int radius = 10;
    
    for (NSInteger idx = 0; idx < 4; idx++) {
        CAShapeLayer *dot = [CAShapeLayer layer];
        // Make a circular shape
        dot.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                              cornerRadius:radius].CGPath;
        dot.position = CGPointMake(10 + self.frame.size.width/4 * idx + (radius*2), self.frame.size.height - 54);
    
        // Configure the apperence of the circle
        dot.fillColor = [[self.segementColors objectAtIndex:idx] CGColor];
        dot.strokeColor = [UIColor clearColor].CGColor;
        dot.lineWidth = 1;
        
        // Add to parent layer
        [self.layer addSublayer:dot];
    }
}

#pragma mark Circle

- (void)drawCircle
{
    [CATransaction begin];
    {
        [CATransaction setAnimationDuration:1.5];
        [CATransaction setCompletionBlock:^{
            NSLog(@"Animation Completed.");
        }];
        
        for (NSInteger idx = 0; idx < self.numberOfSegments; idx++) {
            CAShapeLayer* strokePart = [[CAShapeLayer alloc] init];
            strokePart.fillColor = [[UIColor clearColor] CGColor];
            strokePart.frame = self.circle.bounds;
            strokePart.path = self.circle.path;
            strokePart.lineCap = self.circle.lineCap;
            strokePart.lineWidth = self.circle.lineWidth;
            
            strokePart.strokeColor = [[self.segementColors objectAtIndex:idx] CGColor];
            
            if (idx == 0) {
                strokePart.strokeStart = 0.0;
                
                NSDictionary *segmentValue = [self.segmentValues objectAtIndex:idx];
                
                strokePart.strokeEnd = [self percentageOfValue:[segmentValue[kDatasetValueKey] floatValue]];
            } else {
                NSDictionary *segmentValue = [self.segmentValues objectAtIndex:idx];
                
                strokePart.strokeStart = self.lastPercentage;
                strokePart.strokeEnd = strokePart.strokeStart + [self percentageOfValue:[segmentValue[kDatasetValueKey] doubleValue]];
            }
            
            self.lastPercentage = strokePart.strokeEnd;
            
            NSLog(@"Start/End: %f/%f", strokePart.strokeStart, strokePart.strokeEnd);
            
            [self.circle addSublayer:strokePart];
            
            CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
            NSArray* times = @[ @(0.0), // Note: This works because both the times and the stroke start/end are on scales of 0..1
                                @(strokePart.strokeStart),
                                @(strokePart.strokeEnd),
                                @(1.0) ];
            NSArray* values = @[ @(strokePart.strokeStart),
                                 @(strokePart.strokeStart),
                                 @(strokePart.strokeEnd),
                                 @(strokePart.strokeEnd) ];
            
            animation.keyTimes = times;
            animation.values = values;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            
            [strokePart addAnimation:animation forKey:@"drawCircleAnimation"];
        }
    }
    [CATransaction commit];
}

- (void)setHideAllLabels:(BOOL)hideAllLabels
{
    _hideAllLabels = hideAllLabels;
    
    if (_hideAllLabels) {
        [self setHideInsideLabels:_hideAllLabels];
        [self setHideOutsideLabels:_hideAllLabels];
    }
}

@end
