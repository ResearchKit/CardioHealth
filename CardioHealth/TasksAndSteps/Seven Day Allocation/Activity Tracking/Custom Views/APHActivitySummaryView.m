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

static CGFloat kMetersPerMile = 1609.344;

@interface APHActivitySummaryView()

@property (nonatomic, strong) CAShapeLayer *circle;
@property (nonatomic, strong) CAShapeLayer *border;
@property (nonatomic, strong) CAShapeLayer *dotInactive;
@property (nonatomic, strong) CAShapeLayer *dotSedentary;
@property (nonatomic, strong) CAShapeLayer *dotModerate;
@property (nonatomic, strong) CAShapeLayer *dotVigorous;

@property (nonatomic, strong) NSArray *segmentValues;
@property (nonatomic, strong) NSArray *segementColors;

@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UILabel *distanceCaption;
@property (nonatomic, strong) UILabel *inactiveCaption;
@property (nonatomic, strong) UILabel *sedentaryCaption;
@property (nonatomic, strong) UILabel *moderateCaption;
@property (nonatomic, strong) UILabel *vigorousCaption;

@property (nonatomic) double lastPercentage;
@property (nonatomic) double sumQuantity;
@property (nonatomic) NSUInteger radius;

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
    [self setupChartView];
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

- (void)setupChartView
{
    // Add the CAShapeLayer
    self.circle = [CAShapeLayer layer];
    // Add to parent layer
    [self.layer addSublayer:self.circle];
    
    self.border = [CAShapeLayer layer];
    [self.layer addSublayer:self.border];
    
    self.distanceLabel = [self addLabelWithTitle:@"0.00 mi"
                                           color:[UIColor blackColor]
                                        position:CGPointMake(0, 0)];
    self.distanceLabel.font = [UIFont systemFontOfSize:42.0];
    [self addSubview:self.distanceLabel];
    
    self.distanceCaption = [self addLabelWithTitle:NSLocalizedString(@"Distance", @"Distance")
                                             color:[UIColor lightGrayColor]
                                          position:CGPointMake(0, 0)];
    self.distanceCaption.font = [UIFont systemFontOfSize:21.0];
    [self addSubview:self.distanceCaption];
    
    self.inactiveCaption = [self addLabelWithTitle:NSLocalizedString(@"Inactive", @"Inactive")
                                             color:[UIColor lightGrayColor]
                                          position:CGPointMake(0, 0)];
    [self addSubview:self.inactiveCaption];
    
    self.sedentaryCaption = [self addLabelWithTitle:NSLocalizedString(@"Sedentary", @"Sedentary")
                                              color:[UIColor lightGrayColor]
                                           position:CGPointMake(0, 0)];
    [self addSubview:self.sedentaryCaption];
    
    self.moderateCaption = [self addLabelWithTitle:NSLocalizedString(@"Moderate", @"Moderate")
                                             color:[UIColor lightGrayColor]
                                          position:CGPointMake(0, 0)];
    [self addSubview:self.moderateCaption];
    
    self.vigorousCaption = [self addLabelWithTitle:NSLocalizedString(@"Vigorous", @"Vigorous")
                                             color:[UIColor lightGrayColor]
                                          position:CGPointMake(0, 0)];
    [self addSubview:self.vigorousCaption];
}

- (void)layoutSubviews
{
    self.radius = self.frame.size.width * 0.3;
    // Make a circular shape
    self.circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*self.radius, 2.0*self.radius)
                                              cornerRadius:self.radius].CGPath;
    // Center the shape in self.view
    self.circle.position = CGPointMake(CGRectGetMidX(self.frame)-self.radius,
                                   CGRectGetMidY(self.frame)-self.radius*2);
    
    // Configure the apperence of the circle
    self.circle.fillColor = [UIColor clearColor].CGColor;
    self.circle.strokeColor = [APHTheme colorForActivityOutline].CGColor;
    self.circle.lineWidth = 20;
    
    self.border.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 64)].CGPath;
    self.border.fillColor = [UIColor clearColor].CGColor;
    self.border.strokeColor = [APHTheme colorForDividerLine].CGColor;
    self.border.lineWidth = 1.0;
    
    CGFloat circleDiameter = self.radius * 2;
    CGFloat labelFrameWidth = circleDiameter/sqrt(2.0);
    
    CGRect distanceLabelFrame = CGRectMake((CGRectGetWidth(self.bounds) - labelFrameWidth)/2,
                                                  (CGRectGetHeight(self.bounds) - labelFrameWidth)/2 - 20,
                                                  labelFrameWidth,
                                                  labelFrameWidth);
    self.distanceLabel.frame = distanceLabelFrame;
    
    CGRect distanceCaptionFrame = CGRectMake((CGRectGetWidth(self.bounds) - labelFrameWidth)/2,
                                           (CGRectGetHeight(self.bounds) - labelFrameWidth)/2 + 20,
                                           labelFrameWidth,
                                           labelFrameWidth);
    self.distanceCaption.frame = distanceCaptionFrame;
    
    [self drawLegend];
}

- (void)drawWithSegmentValues:(NSArray *)values
{
    if (values) {
        self.segmentValues = values;
        self.sumQuantity = [[self.segmentValues valueForKeyPath:@"@sum.datasetValueKey"] doubleValue];
        
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", self.sumQuantity/kMetersPerMile];
        
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
        
        CGPoint labelPosition = CGPointMake(self.frame.size.width/4 * idx - 10, self.frame.size.height - 27);
        CGRect labelFrame = CGRectMake(labelPosition.x, labelPosition.y, 100, 21);
        
        switch (idx) {
            case 0:
                self.inactiveCaption.frame = labelFrame;
                break;
            case 1:
                self.sedentaryCaption.frame = labelFrame;
                break;
            case 2:
                self.moderateCaption.frame = labelFrame;
                break;
            default:
                self.vigorousCaption.frame = labelFrame;
                break;
        }
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

- (UILabel *)addLabelWithTitle:(NSString *)title color:(UIColor *)color position:(CGPoint)position
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(position.x, position.y, 100, 21)];
    label.text = title;
    label.textColor = color;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14.0];
    
    return label;
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
