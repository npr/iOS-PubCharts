//
//  NPRRootViewController.m
//  PubCharts
//
//  Created by Michael Seifollahi on 1/2/14.
//  Copyright (c) 2014 NPR. All rights reserved.
//

#import "NPRRootViewController.h"

#import "NPRCrustChart.h"

#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 \
    green:((c>>16)&0xFF)/255.0 \
    blue:((c>>8)&0xFF)/255.0 \
    alpha:((c)&0xFF)/255.0]

@interface NPRRootViewController ()

@property (nonatomic, strong) NSArray *aPercentages;
@property (nonatomic, strong) NSArray *aMessages;

@property (nonatomic, strong) UILabel *lblPercent;
@property (nonatomic, strong) UILabel *lblMessage;

@property (nonatomic, strong) NPRCrustChart *chart;

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;

@end

@implementation NPRRootViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"CrustChart";
    
    self.aPercentages = @[@33.0f, @27.0f, @22.0f, @52.0f];
    self.aMessages = @[@"of people surveyed prefer blue chart segments",
                       @"of people surveyed prefer red chart segments",
                       @"of people surveyed prefer slightly lighter shades of blue chart segments",
                       @"of people surveyed don't like colors"];

    NSArray *colors = @[HEXCOLOR(0x6083c2ff), [UIColor redColor],
                        HEXCOLOR(0xd0dcedff), [UIColor lightGrayColor]];
    self.chart =
        [[NPRCrustChart alloc] initWithFrame:
                             CGRectMake(20.0f, 84.0f, 280.0f, 280.0f)
                                   withValues:self.aPercentages
                                   withColors:colors];
    
    [self.chart addTarget:self
                   action:@selector(sectionSelected:)
         forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.chart];
    
    UIView *mask =
        [[UIView alloc] initWithFrame:CGRectMake(0.0f, 364.0f, 320.0f, 400.0f)];
    [mask setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:mask];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Accessors

- (UILabel *)lblPercent
{
    if (_lblPercent == nil) {
        _lblPercent = [[UILabel alloc] init];
        [_lblPercent setTextAlignment:NSTextAlignmentCenter];
        [_lblPercent setTextColor:HEXCOLOR(0x3d3d3dff)];
        [_lblPercent setFrame:CGRectMake(70.0f, 184.0f, 180.0f, 80.0f)];
        [_lblPercent setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:64.0f]];
    }
    
    if (![[self.view subviews] containsObject:_lblPercent]) {
        [self.view insertSubview:_lblPercent belowSubview:self.chart];
    }
    
    return _lblPercent;
}

- (UILabel *)lblMessage
{
    if (_lblMessage == nil) {
        _lblMessage = [[UILabel alloc] init];
        [_lblMessage setFrame:CGRectMake(40.0f, 364.0f, 240.0f, 200.0f)];
        [_lblMessage setNumberOfLines:0];
        [_lblMessage setTextColor:HEXCOLOR(0x3d3d3dff)];
        [_lblMessage setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f]];
    }
    
    if (![[self.view subviews] containsObject:_lblMessage]) {
        [self.view addSubview:_lblMessage];
    }
    
    return _lblMessage;
}

- (UIDynamicAnimator *)dynamicAnimator
{
    if (_dynamicAnimator == nil) {
        _dynamicAnimator =
        [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[self.lblPercent]];
        collision.translatesReferenceBoundsIntoBoundary = YES;
        
        CGFloat yO = self.lblPercent.frame.origin.y;
        [collision addBoundaryWithIdentifier:@"home" fromPoint:CGPointMake(0, yO) toPoint:CGPointMake(320.0f, yO)];
        
        [_dynamicAnimator addBehavior:collision];
        [_dynamicAnimator addBehavior:self.gravityBehavior];
    }
    
    return _dynamicAnimator;
}

- (UIGravityBehavior *)gravityBehavior
{
    if (_gravityBehavior == nil) {
        _gravityBehavior =
        [[UIGravityBehavior alloc] init];
        [_gravityBehavior addItem:self.lblPercent];
    }
    
    return _gravityBehavior;
}

#pragma mark - Private Interface

- (void)sectionSelected:(NPRCrustChart *)chart
{
    if (![[self.dynamicAnimator behaviors]
          containsObject:self.gravityBehavior]) {
        
        [self.dynamicAnimator addBehavior:self.gravityBehavior];
    }
    
    NSLog(@"Chart segment selected %@", chart.currentSegment);
    
    if (chart.currentSegment == nil) {
        [UIView animateWithDuration:0.5f animations:^{
            [self.gravityBehavior setGravityDirection:CGVectorMake(0.0f, 1.0f)];
            [self.lblMessage setAlpha:0.0f];
        }];
    } else {
        [self.gravityBehavior setGravityDirection:CGVectorMake(0.0f, -1.0f)];
        [UIView animateWithDuration:0.5f animations:^{
            
            [self.lblPercent setText:
             [NSString stringWithFormat:@"  %.0f%%",
              [chart percentageForCurrentSegment]]];
            
            [self.lblMessage setText:
             [self.aMessages objectAtIndex:[chart.currentSegment integerValue]]];
            [self.lblMessage setAlpha:1.0f];
        }];
    }
    
}

@end
