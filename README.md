iOS-PubCharts
=============

Open source native charting library for iOS.

This class draws a CrustChart (a pie chart without the center) with supplied values and colors.  The user can tap or swipe around the chart to highlight the individual segments, sending the UIControlEventValueChanged key to the observer.
 
This was a product of NPR's Serendipity Day #9, for more details on Serendipity Day, checkout http://www.npr.org/blogs/inside/2011/10/14/141312774/happy-accidents-the-joy-of-serendipity-days

##Usage##

The constructor accepts a frame, and two NSArrays (one for values, one for colors).

```
- (id)initWithFrame:(CGRect)frame withValues:(NSArray *)values
         withColors:(NSArray *)colors;
```

##TODO##

This release has little validation, other than converting sums >< 100 to percentages, but future updates will validate the colors parameter has sufficient colors for the segments provided and / or add some automatic color selection.

This has not been tested with transforms / NSLayoutConstraints yet either.

Future additions will include more chart types as time permits.
