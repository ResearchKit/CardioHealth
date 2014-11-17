//
//  APHActivitySummaryView.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHActivitySummaryView.h"

@interface APHActivitySummaryView()

@property (nonatomic, strong) CAShapeLayer *circle;
@property (nonatomic, strong) NSArray *segmentValues;

@property (nonatomic) double lastPercentage;

@end

@implementation APHActivitySummaryView

- (void)commonInit
{
    self.backgroundColor = [UIColor whiteColor];
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
    NSLog(@"Width %f (%f)", self.frame.size.width, self.frame.size.width * 0.3);
    
    int radius = self.frame.size.width * 0.3;
    _circle = [CAShapeLayer layer];
    // Make a circular shape
    _circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                              cornerRadius:radius].CGPath;
    // Center the shape in self.view
    _circle.position = CGPointMake(CGRectGetMidX(self.frame)-radius,
                                   CGRectGetMidY(self.frame)-radius);
    
    // Configure the apperence of the circle
    _circle.fillColor = [UIColor clearColor].CGColor;
    _circle.strokeColor = [UIColor colorWithWhite:0.973 alpha:1.000].CGColor;
    _circle.lineWidth = 20;
    
    // Add to parent layer
    [self.layer addSublayer:self.circle];
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
        [self drawCircle];
    }
}

- (double)percentageOfValue:(double)value
{
    double percentage = 0.0;
    
    NSNumber *valueSum = [self.segmentValues valueForKeyPath:@"@sum.value"];
    
    percentage = value / [valueSum doubleValue];
    
    NSLog(@"%f", percentage);
    
    return percentage;
}

- (void)drawCircle
{
    [CATransaction begin];
    {
        [CATransaction setAnimationDuration:1.5];
        [CATransaction setCompletionBlock:^{
            NSLog(@"Animation Completed.");
        }];
        
        for (NSInteger idx = 0; idx < self.numberOfSegments; idx++) {
            UIColor *segmentColor = nil;
            
            switch (idx) {
                case 0:
                    // Inactive
                    segmentColor = [UIColor colorWithRed:0.176 green:0.706 blue:0.980 alpha:1.000];
                    break;
                case 1:
                    // Sedentary
                    segmentColor = [UIColor colorWithRed:0.608 green:0.196 blue:0.867 alpha:1.000];
                    break;
                case 2:
                    // Moderate
                    segmentColor = [UIColor colorWithRed:0.145 green:0.851 blue:0.443 alpha:1.000];
                    break;
                case 3:
                    // Vigorous
                    segmentColor = [UIColor colorWithRed:0.957 green:0.745 blue:0.290 alpha:1.000];
                    break;
                default:
                    break;
            }
            
            CAShapeLayer* strokePart = [[CAShapeLayer alloc] init];
            strokePart.fillColor = [[UIColor clearColor] CGColor];
            strokePart.frame = self.circle.bounds;
            strokePart.path = self.circle.path;
            strokePart.lineCap = self.circle.lineCap;
            strokePart.lineWidth = self.circle.lineWidth;
            
            strokePart.strokeColor = segmentColor.CGColor;
            
            if (idx == 0) {
                strokePart.strokeStart = 0.0;
                
                NSDictionary *segmentValue = [self.segmentValues objectAtIndex:idx];
                
                strokePart.strokeEnd = [self percentageOfValue:[segmentValue[@"value"] floatValue]];
            } else {
                NSDictionary *segmentValue = [self.segmentValues objectAtIndex:idx];
                
                strokePart.strokeStart = self.lastPercentage;
                strokePart.strokeEnd = strokePart.strokeStart + [self percentageOfValue:[segmentValue[@"value"] doubleValue]];
            }
            
            self.lastPercentage = strokePart.strokeEnd;
            
            NSLog(@"Start/End: %f/%f", strokePart.strokeStart, strokePart.strokeEnd);
            
            [self.circle addSublayer:strokePart];
            
            CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath: @"strokeEnd"];
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
