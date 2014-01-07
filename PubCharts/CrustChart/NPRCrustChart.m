//
//  NPRCircleChart.m
//  PubCharts
//
//  Created by Michael Seifollahi on 1/2/14.
//  Copyright (c) 2014 NPR. All rights reserved.
//

/** Helper method to convert from Hexadecimal color to a UIColor.  Includes
 * alpha value.
 *
 * @param hexadecimal color value in the format 0xabababff
 *    last 2 hexes are for alpha.
 * @return UIColor
 */
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 \
    green:((c>>16)&0xFF)/255.0 \
    blue:((c>>8)&0xFF)/255.0 \
    alpha:((c)&0xFF)/255.0]

/** CoreGraphics starts arcs at 3 o'clock, this offset brings it to 12 o'clock.
 */
#define ZERO_OFFSET - 2 * M_PI_4

/** Quick conversion of Radians to Degrees.
 */
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

#define DEFAULT_RADIUS 30.0f
#define DEFAULT_LINE_WIDTH 12.0f

#import "NPRCrustChart.h"

@interface NPRCrustChart()

    @property (nonatomic) CGFloat radius;

    @property (nonatomic, strong) NSArray *aPercentages;
    @property (nonatomic, strong) NSMutableArray *maSegments;
    @property (nonatomic, strong) NSArray *aColors;
    @property (nonatomic, strong) CAShapeLayer *bgCircle;

    /**-------------------------------------------------------------------------
     * @name Class Methods
     *  ------------------------------------------------------------------------
     */

    /** Convert the given array (treated as CGFloats) to a percentage of their
     sum.
     
     @param NSArray the values to sum and convert
     @return NSArray the calculated percentages
     */
    + (NSArray *)convertArrayToPercentages:(NSArray *)arrayIn;

    /**-------------------------------------------------------------------------
     * @name Instance Methods (Private)
     *  ------------------------------------------------------------------------
     */

    /** Determine if the given UITouch is a swipe, away from the center, across 
     the same segment (last touch point -> current touch point).  If so, return 
     YES.
     
     @param UITouch the touch to test
     @return BOOL YES if a swipe outward on a segment
     */
    - (BOOL)didSwipeActivateWithTouch:(UITouch *)touch;

    /** Calculate the distance of the given CGPoint from the center, using
     the Pythagorean Theorem.
     
     @param CGPoint the point to calculate the distance to
     @return CGFloat the calculated distance
     */
    - (CGFloat)distanceFromCenter:(CGPoint)point;

    /** Determine if the given CGPoint from a touch falls within the rules for
     activating a segment.  Returns an NSNumber so that a touch not activating
     any segment can return nil.
     
     @param CGPoint the point to test
     @return NSNumber the active segment for the point (can be nil)
     */
    - (NSNumber *)findActiveSegmentForTouchPoint:(CGPoint)point;

    /** Convert the given percentage to radians.
     
     @param CGFloat the percentage
     @return CGFloat the measurement in radians
     */
    - (CGFloat)convertPercentToRadians:(CGFloat)percent;

    /** Create the path segment for the given index using the default radius.
     
     @param NSUInteger the index
     @return UIBezierPath the path
     */
    - (UIBezierPath *)createPathForSegmentAtIndex:(NSUInteger)index;

    /** Create the path segment for the given index using the given radius.
     
     @param NSUInteger the index
     @param CGFloat the radius
     @return UIBezierPath the path
     */
    - (UIBezierPath *)createPathForSegmentAtIndex:(NSUInteger)index
                                       withRadius:(CGFloat)radius;

    /** Create the CAShapeLayer segment for the given index.
     
     @param NSUInteger index
     @return CAShapeLayer the shape layer
     */
    - (CAShapeLayer *)createSegmentAtIndex:(NSUInteger)index;

    /** Sum the percentages up to the given index.  Used to calculate the
     percentage for each segment.
     
     @param NSUInteger the index
     @return CGFloat the sum
     */
    - (CGFloat)sumPercentagesUpToIndex:(NSUInteger)index;

    /** Get the calculated center point based on the frame.  Should be half way
     between the width & height, irrespective of each other.
     
      -----------------
     |                 |
     |                 |
     |        X        |
     |                 |
     |                 |
      -----------------
     
      ---
     |   |
     |   |
     | X |
     |   |
     |   |
      ---
     
     @return CGPoint the center point
     */
    - (CGPoint)getCenterPoint;

    /** Animate the given segment radius / line width Up / Down.
     
     @param NSUInteger
     */
    - (void)animateSegmentUp:(NSUInteger)segment;
    - (void)animateSegmentDown:(NSUInteger)segment;
@end

@implementation NPRCrustChart

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame withValues:(NSArray *)values
         withColors:(NSArray *)colors {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.aPercentages = [self.class convertArrayToPercentages:values];
        self.aColors = [colors copy];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.currentSegment = nil;
        
        self.maSegments = [NSMutableArray array];
        
        for (NSUInteger i = 0; i < [self.aPercentages count]; i++) {
            [self.maSegments addObject:
             [self createSegmentAtIndex:i]];
        }

    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Set the fill color (BG)
    [[UIColor clearColor] setFill];
    CGContextFillRect(ctx, rect);
    
    CGFloat radius = self.radius;

    // Draw outer masking ring
    [[UIColor whiteColor] setStroke];
    
    CGFloat longestDimension = CGRectGetWidth(rect) > CGRectGetHeight(rect)
        ? CGRectGetWidth(rect) : CGRectGetHeight(rect);
    
    CGFloat maskRadius = longestDimension / 2;
    CGContextSetLineWidth(ctx, (maskRadius - radius) * 2);
    
    CGContextAddArc(ctx, self.frame.size.width / 2, self.frame.size.height / 2,
                    maskRadius, 0, M_PI * 2, 0);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    // Add the arc path
    CGContextAddArc(ctx, self.frame.size.width / 2, self.frame.size.height / 2,
                    radius, 0, M_PI * 2, 0);
    
    // Set the stroke colour
    [HEXCOLOR(0xeaeef8ff) setStroke];

    // Set Line width and cap
    CGContextSetLineWidth(ctx, DEFAULT_LINE_WIDTH);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    // Draw it
    CGContextDrawPath(ctx, kCGPathStroke);
}

#pragma mark - Getters

- (CGFloat)radius
{
    if (_radius == 0.0f) {
        
        CGPoint center = [self getCenterPoint];
        
        if (center.x > center.y) {
            _radius = center.y;
        } else {
            _radius = center.x;
        }
        
        _radius -= 2 * DEFAULT_LINE_WIDTH;
    }
    
    return _radius;
}

#pragma mark - Setters

- (void)setCurrentSegment:(NSNumber *)currentSegment
{
    if (currentSegment == nil) {
        
        if (_currentSegment != nil) {
            //Animate currentSegment out
            [self animateSegmentDown:[_currentSegment integerValue]];
        }
            
    } else if (_currentSegment == currentSegment) {
        
        // Bounce on out
        
    } else if (_currentSegment == nil) {

        // Animate the newly assigned currentSegment into glory
        [self animateSegmentUp:[currentSegment integerValue]];
        
    } else if (currentSegment != nil) {
        
        // Animate currentSegment out, and animate the new segment in
        [self animateSegmentDown:[_currentSegment integerValue]];
        [self animateSegmentUp:[currentSegment integerValue]];
        
    }
    
    _currentSegment = currentSegment;
}

#pragma mark - Touch Interface

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    [self setCurrentSegment:[self findActiveSegmentForTouchPoint:lastPoint]];
    
    // Track continuously
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    
    if ([self didSwipeActivateWithTouch:[[event touchesForView:self] anyObject]]) {
        
//        [self animateSegmentWayUp:[self findActiveSegmentForTouchPoint:lastPoint]];
        
    } else {
        
        [self setCurrentSegment:[self findActiveSegmentForTouchPoint:lastPoint]];
        
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    // Track continuously
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Private Interface

+ (NSArray *)convertArrayToPercentages:(NSArray *)arrayIn
{
    CGFloat sum = 0.0f;

    for (NSNumber *num in arrayIn) {
        sum += [num floatValue];
    }
    
    // If the sum is exactly 100.0f, it's already a percentage.
    if (sum == 100.0f) {
        
        return arrayIn;
    }
    
    // If it's less or greater than 100.0f, convert the segments to percentages.
    NSMutableArray *percentages = [NSMutableArray array];
    
    for (NSNumber *num in arrayIn) {
        // Add the percentage as an NSNumber with the @ literal.
        [percentages addObject:@(100.0f * [num floatValue] / sum)];
    }
    
    return percentages;
}

- (BOOL)didSwipeActivateWithTouch:(UITouch *)touch
{
    CGPoint prev = [touch previousLocationInView:self];
    CGPoint cur = [touch locationInView:self];
    
    if ([self distanceFromCenter:cur] > [self distanceFromCenter:prev]) {
        // Swipe is moving away from the center point.
        
        if ([self findActiveSegmentForTouchPoint:prev]
            == [self findActiveSegmentForTouchPoint:cur]) {
            
            // Previous and current segments are in the same segment.
            return YES;
        }
    }
    
    return NO;
}

- (CGFloat)distanceFromCenter:(CGPoint)point
{
    // Pyhtagoras knew his stuff.
    return sqrt(
                ( pow((point.x - [self getCenterPoint].x), 2) ) +
                ( pow((point.y - [self getCenterPoint].y), 2) )
                );
}

- (NSNumber *)findActiveSegmentForTouchPoint:(CGPoint)point
{
    // Distance from center
    float dx = point.x - [self getCenterPoint].x;
    float dy = point.y - [self getCenterPoint].y;
    
    // ArcTangent to degress
    CGFloat deltaAngle = RADIANS_TO_DEGREES((atan2(dy,dx) - ZERO_OFFSET));
    
    if (deltaAngle < 0) {
        deltaAngle = 360.0f + deltaAngle;
    }
    
    CGFloat runningTotal = 0.0f;
    
    for (NSUInteger i = 0; i < [self.aPercentages count]; i++) {
        
        runningTotal += ([[self.aPercentages objectAtIndex:i] floatValue] / 100.0f);
        
        if (deltaAngle <= runningTotal * 360.0f) {
            return [NSNumber numberWithInteger:i];
        }
    }
    
    return nil;
}

- (CGFloat)convertPercentToRadians:(CGFloat)percent
{
    return (percent / 100.0f) * (2 *  M_PI);
}

- (UIBezierPath *)createPathForSegmentAtIndex:(NSUInteger)index
{
    return [self createPathForSegmentAtIndex:index
                                  withRadius:self.radius];
}

- (UIBezierPath *)createPathForSegmentAtIndex:(NSUInteger)index
                                   withRadius:(CGFloat)radius
{
    CGFloat percentage = [[self.aPercentages objectAtIndex:index] floatValue];
    
    CGFloat start = ZERO_OFFSET;
    
    if (index > 0) {
        
        start = ZERO_OFFSET + [self convertPercentToRadians:
                               [self sumPercentagesUpToIndex:index - 1]];
    }
    
    return
    [UIBezierPath bezierPathWithArcCenter:[self getCenterPoint]
                                   radius:radius
                               startAngle:start
                                 endAngle:start + [self convertPercentToRadians:percentage]
                                clockwise:YES];
}

- (CAShapeLayer *)createSegmentAtIndex:(NSUInteger)index
{
    CAShapeLayer *shape = [CAShapeLayer layer];
    
    // @TODO: Validation for this
    UIColor *color = [self.aColors objectAtIndex:index];

    shape.path = [self createPathForSegmentAtIndex:index].CGPath;
    shape.lineCap = kCGLineCapButt;
    shape.lineWidth = 12.0f;
    shape.zPosition = 1 + index;
    shape.opacity = 0.0f;
    shape.strokeColor = [color CGColor];
    shape.fillColor = [[UIColor clearColor] CGColor];
    
    [self.layer addSublayer:shape];
    
    NSString *timing = kCAMediaTimingFunctionLinear;
    if (index == 0) {
        timing = kCAMediaTimingFunctionEaseIn;
    } else if (index == [self.aPercentages count] - 1) {
        timing = kCAMediaTimingFunctionEaseOut;
    }
    
    // Animate the opacity to hide the actual value until we start animating
    CABasicAnimation *animationOp = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animationOp.beginTime = CACurrentMediaTime() + 0.5 * index;
    animationOp.duration = 0.25f;
    animationOp.timingFunction = [CAMediaTimingFunction functionWithName:timing];
    animationOp.repeatCount = 1;
    animationOp.autoreverses = NO;
    animationOp.removedOnCompletion = NO;
    animationOp.fillMode = kCAFillModeForwards;
    animationOp.fromValue = @0.0f;
    animationOp.toValue = @1.0f;

    [shape addAnimation:animationOp forKey:@"animateOpacity"];
    
    // Animate the stroke end to "Draw" the segment
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.beginTime = CACurrentMediaTime() + 0.5 * index;
    animation.duration = 0.5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:timing];
    animation.repeatCount = 1;
    animation.autoreverses = NO;
    animation.fromValue = @0.0f;
    animation.toValue = @1.0f;
    
    [shape addAnimation:animation forKey:@"animateStrokeEnd"];
    
    return shape;
}

- (CGFloat)sumPercentagesUpToIndex:(NSUInteger)index
{
    CGFloat percentages = 0.0f;
    
    for (NSUInteger i = 0; i <= index; i++) {
        percentages += [[self.aPercentages objectAtIndex:i] floatValue];
    }
    
    return percentages;
}

- (CGPoint)getCenterPoint
{
    return CGPointMake(CGRectGetWidth(self.bounds) / 2,
                       CGRectGetHeight(self.bounds) / 2);
}

- (void)animateSegmentWayUp:(NSUInteger)segment
{
    CGFloat newWidth = 36.0f;
    
    // Add 1/4 of line width to the radius, we are increasing the line width
    // by 50%, so add half of that to the radius so it grows outward only
    UIBezierPath *path =
    [self createPathForSegmentAtIndex:segment
                           withRadius:
     self.radius + (newWidth - DEFAULT_LINE_WIDTH) / 2];
    
    CAShapeLayer *shape = [self.maSegments objectAtIndex:segment];
    
    shape.path = path.CGPath;
    shape.lineWidth = newWidth;
}

- (void)animateSegmentUp:(NSUInteger)segment
{
    CGFloat newWidth = 24.0f;
    
    // Add 1/4 of line width to the radius, we are increasing the line width
    // by 50%, so add half of that to the radius so it grows outward only
    UIBezierPath *path =
        [self createPathForSegmentAtIndex:segment
                               withRadius:
         self.radius + (newWidth - DEFAULT_LINE_WIDTH) / 2];
    
    CAShapeLayer *shape = [self.maSegments objectAtIndex:segment];
    
    shape.path = path.CGPath;
    shape.lineWidth = newWidth;
}

- (void)animateSegmentDown:(NSUInteger)segment
{
    UIBezierPath *path =
        [self createPathForSegmentAtIndex:segment];
    
    CAShapeLayer *shape = [self.maSegments objectAtIndex:segment];
    shape.path = path.CGPath;
    shape.lineWidth = DEFAULT_LINE_WIDTH;
}

#pragma mark - Public Interface

- (CGFloat)percentageForCurrentSegment
{
    if (self.currentSegment != nil) {
        return [[self.aPercentages
                objectAtIndex:[self.currentSegment intValue]] floatValue];
    }
    
    return 0.0f;
}

- (CGFloat)percentageForSegment:(NSNumber *)segment
{
    if ([segment intValue] < [self.aPercentages count]) {
        return [[self.aPercentages
                objectAtIndex:[segment intValue]] floatValue];
    }
    
    return 0.0f;
}

@end
