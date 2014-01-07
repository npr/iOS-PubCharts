//
//  NPRCircleChart.h
//  PubCharts
//
//  Created by Michael Seifollahi on 1/2/14.
//  Copyright (c) 2014 NPR. All rights reserved.
//

#import <UIKit/UIKit.h>

/** This class draws a CrustChart (a pie chart without the center) with supplied
 values and colors.  The user can tap or swipe around the chart to highlight the
 individual segments, sending the UIControlEventValueChanged key to the observer.
 
 This was a product of NPR's Serendipity Day #9, for more details on
 Serendipity Day, checkout 
 http://www.npr.org/blogs/inside/2011/10/14/141312774/happy-accidents-the-joy-of-serendipity-days
 
 
 */
@interface NPRCrustChart : UIControl

/**-----------------------------------------------------------------------------
 * @name Properties
 *  ----------------------------------------------------------------------------
 */
@property (nonatomic, strong) NSNumber *currentSegment;

/**-----------------------------------------------------------------------------
 * @name Instance Methods (Public)
 *  ----------------------------------------------------------------------------
 */

/** Constructor accepting frame, array of values and array of colors.
 
 @param CGRect frame
 @param NSArray the values or percentages of the segments
 @param NSArray the colors to assign to each segment
 */
- (id)initWithFrame:(CGRect)frame withValues:(NSArray *)values
         withColors:(NSArray *)colors;

/** Return the calculated (or provided) percentage of the current highlighted
 segment as a CGFloat.
 
 @return CGFloat the percentage
 */
- (CGFloat)percentageForCurrentSegment;

/** Return the calculated (or provided) percentage of the given segment index
 as a CGFloat.
 
 @param NSNumber the segment index
 @return CGFloat the percentage
 */
- (CGFloat)percentageForSegment:(NSNumber *)segment;

@end
