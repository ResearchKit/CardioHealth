//
//  APHStackedCircleView.m
//  CardioHealth
//
//  Created by Farhan Ahmed on 11/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHStackedCircleView.h"

NSString *const kDatasetDateKey = @"datasetDateKey";
NSString *const kDatasetValueKey = @"datasetValueKey";
NSString *const kDatasetSegmentNameKey = @"datasetSegmentNameKey";
NSString *const kDatasetSegmentColorKey = @"datasetSegmentColorKey";

static CGFloat kMetersPerMile = 1609.344;

@interface APHStackedCircleView()

@property (nonatomic, strong) CAShapeLayer *circle;
@property (nonatomic, strong) CAShapeLayer *border;
@property (nonatomic, strong) CAShapeLayer *dot;

@property (nonatomic, strong) NSArray *segments;

@property (nonatomic, strong) NSMutableArray *legendLabels;

@property (nonatomic, strong) UILabel *insideLabel;
@property (nonatomic, strong) UILabel *insideCaption;

@property (nonatomic) double sumQuantity;
@property (nonatomic) CGFloat center;
@property (nonatomic) NSUInteger radius;

@end

@implementation APHStackedCircleView

#pragma mark - Initialize

- (void)commonInit
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.circle = [CAShapeLayer layer];
    [self.layer addSublayer:self.circle];
    
    self.border = [CAShapeLayer layer];
    [self.layer addSublayer:self.border];
    
    self.dot = [CAShapeLayer layer];
    [self.layer addSublayer:self.dot];
    
    self.insideLabel = [self addLabelWithTitle:@"0"
                                         color:[UIColor blackColor]
                                      position:CGPointMake(0, 0)];
    self.insideLabel.font = [UIFont systemFontOfSize:42.0];
    [self addSubview:self.insideLabel];
    
    self.insideCaption = [self addLabelWithTitle:NSLocalizedString(@"Distance", @"Distance")
                                           color:[UIColor lightGrayColor]
                                        position:CGPointMake(0, 0)];
    self.insideCaption.font = [UIFont systemFontOfSize:21.0];
    [self addSubview:self.insideCaption];
    
    self.legendLabels = [NSMutableArray array];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews
{
    self.radius = MIN(CGRectGetWidth(self.bounds)/3, CGRectGetHeight(self.bounds)/3);
    
    self.circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*self.radius, 2.0*self.radius)
                                                  cornerRadius:self.radius].CGPath;
    // Center the shape in self.view
    self.circle.position = CGPointMake(CGRectGetMidX(self.frame)-self.radius, CGRectGetMidY(self.frame)-self.radius*2);
    
    // Configure the apperence of the circle
    self.circle.fillColor = [UIColor clearColor].CGColor;
    self.circle.strokeColor = [[UIColor colorWithWhite:0.973 alpha:1.000] CGColor];
    self.circle.lineWidth = 20;
    
    self.border.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 64)].CGPath;
    self.border.fillColor = [UIColor clearColor].CGColor;
    self.border.strokeColor = [[UIColor colorWithWhite:0.836 alpha:1.000] CGColor];
    self.border.lineWidth = 1.0;
    
    CGFloat circleDiameter = self.radius * 2;
    CGFloat labelFrameWidth = circleDiameter/sqrt(2.0);
    
    CGRect insideLabelFrame = CGRectMake((CGRectGetWidth(self.bounds) - labelFrameWidth)/2,
                                           (CGRectGetHeight(self.bounds) - labelFrameWidth)/2 - 20,
                                           labelFrameWidth,
                                           labelFrameWidth);
    self.insideLabel.frame = insideLabelFrame;
    
    CGRect insideCaptionFrame = CGRectMake((CGRectGetWidth(self.bounds) - labelFrameWidth)/2,
                                             (CGRectGetHeight(self.bounds) - labelFrameWidth)/2 + 20,
                                             labelFrameWidth,
                                             labelFrameWidth);
    self.insideCaption.frame = insideCaptionFrame;
}

#pragma mark - Entry point

- (void)plotSegmentValues:(NSArray *)values
{
    if (values) {
        self.segments = values;
        self.sumQuantity = [[self.segments valueForKeyPath:@"@sum.datasetValueKey"] doubleValue];
        
        self.insideLabel.text = [NSString stringWithFormat:@"%.2f mi", self.sumQuantity/kMetersPerMile];
        self.insideCaption.text = self.insideCaptionText;
        
        [self resetPlot];
        
        if (!self.hideLegend) {
            [self setupLegend];
        }
        
        if (self.sumQuantity == 0) {
            [self resetPlot];
        } else {
            [self plotStackedCircle];
        }
    }
}

#pragma mark - Drawing
#pragma mark Stacked Circle

- (void)plotStackedCircle
{
    [CATransaction begin];
    {
        [CATransaction setAnimationDuration:1.5];
        [CATransaction setCompletionBlock:^{
            NSLog(@"Animation Completed.");
        }];
        
        double lastPercentage = 0;
        
        for (NSInteger idx = 0; idx < [self.segments count]; idx++) {
            CAShapeLayer* strokePart = [CAShapeLayer layer];
            strokePart.fillColor = [[UIColor clearColor] CGColor];
            strokePart.frame = self.circle.bounds;
            strokePart.path = self.circle.path;
            strokePart.lineCap = self.circle.lineCap;
            strokePart.lineWidth = self.circle.lineWidth;
            
            NSDictionary *segmentValue = [self.segments objectAtIndex:idx];
            
            strokePart.strokeColor = [[segmentValue valueForKey:kDatasetSegmentColorKey] CGColor];
            
            if ([segmentValue[kDatasetValueKey] doubleValue] != 0) {
                
                CGFloat percentValueOfDatasetValue = [self percentageOfValue:[segmentValue[kDatasetValueKey] floatValue]];
                
                if (idx == 0) {
                    strokePart.strokeStart = 0.0;
                    strokePart.strokeEnd = percentValueOfDatasetValue;
                } else {
                    strokePart.strokeStart = lastPercentage;
                    strokePart.strokeEnd = strokePart.strokeStart + percentValueOfDatasetValue;
                }
                
                lastPercentage = strokePart.strokeEnd;
                
                NSLog(@"Start/End: %f/%f", strokePart.strokeStart, strokePart.strokeEnd);
                
                [self.circle addSublayer:strokePart];
                
                CGRect boundingBox = CGPathGetBoundingBox(strokePart.path);
                
                if (percentValueOfDatasetValue != 1.0) {
                    
                    CGFloat angle = (strokePart.strokeStart + strokePart.strokeEnd) * M_PI; // in radians
                    
                    //NSInteger offset = ((angle - M_PI_2) > M_PI) ? strokePart.lineWidth + 25 : strokePart.lineWidth + 20;
                    NSInteger offset = strokePart.lineWidth + 20;
                    
                    CGPoint labelCenter = CGPointMake(cos(angle - M_PI_2) * (self.radius + offset) + boundingBox.size.width/2,
                                                      sin(angle - M_PI_2) * (self.radius + offset) + boundingBox.size.height/2);
                    
                    CATextLayer *textLayer = [CATextLayer layer];
                    textLayer.string = [NSString stringWithFormat:@"%0.0f%%", percentValueOfDatasetValue * 100];
                    textLayer.fontSize = 21.0;
                    textLayer.foregroundColor = strokePart.strokeColor;
                    textLayer.frame = CGRectMake(labelCenter.x, labelCenter.y, 40, 21);
                    textLayer.contentsScale = [[UIScreen mainScreen] scale];
                    
                    [self.circle addSublayer:textLayer];
                }
                
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
    }
    [CATransaction commit];
}

#pragma mark Legend

- (void)drawLegend
{
    NSUInteger radius = 10;
    
    for (NSInteger idx = 0; idx < [self.segments count]; idx++) {
        CAShapeLayer *dot = [CAShapeLayer layer];
        // Make a circular shape
        dot.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                              cornerRadius:radius].CGPath;
        dot.position = CGPointMake(10 + self.frame.size.width/4 * idx + (radius*2), self.frame.size.height - 54);
        
        // Configure the apperence of the circle
        dot.fillColor = [[[self.segments objectAtIndex:idx] valueForKey:kDatasetSegmentColorKey] CGColor];
        dot.strokeColor = [UIColor clearColor].CGColor;
        dot.lineWidth = 1;
        
        // Add to parent layer
        [self.layer addSublayer:dot];
        
        CGPoint labelPosition = CGPointMake(self.frame.size.width/4 * idx - 10, self.frame.size.height - 27);
        CGRect labelFrame = CGRectMake(labelPosition.x, labelPosition.y, 100, 21);
        
        UILabel *label = [self.legendLabels objectAtIndex:idx];
        
        label.frame = labelFrame;
    }
}

- (void)setupLegend
{
    if ([self.legendLabels count] == 0) {
        for (NSDictionary *segment in self.segments) {
            UILabel *label = [self addLabelWithTitle:[segment valueForKey:kDatasetSegmentNameKey]
                                               color:[UIColor lightGrayColor]
                                            position:CGPointMake(0, 0)];
            [self addSubview:label];
            
            [self.legendLabels addObject:label];
        }
        
        [self drawLegend];
    }
}

#pragma mark Reset

- (void)resetPlot
{
    [self.circle.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
}

#pragma mark - Helpers
#pragma mark Percent

- (double)percentageOfValue:(double)value
{
    double percentage = 0.0;
    
    percentage = value / self.sumQuantity;
    
    NSLog(@"%f", percentage);
    
    return percentage;
}

#pragma mark Create Labels

- (UILabel *)addLabelWithTitle:(NSString *)title color:(UIColor *)color position:(CGPoint)position
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(position.x, position.y, 100, 21)];
    label.text = title;
    label.textColor = color;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14.0];
    
    return label;
}

#pragma mark - Accessors

- (void)setHideAllLabels:(BOOL)hideAllLabels
{
    _hideAllLabels = hideAllLabels;
    
    if (_hideAllLabels) {
        [self setHideInsideLabels:_hideAllLabels];
        [self setHideOutsideLabels:_hideAllLabels];
    }
}
@end
