JDCarouselControl
=================

`JDCarouselControl` is a subclass of `UIControl` which mimics some of the behaviour of `UISegmentedControl` in a visually different way. It's still somewhat crude so the functionality is rather limited, and don't expect it to be anywhere near bug-free.

![](http://s16.postimg.org/rvgpe3byt/Browser_Preview_tmp_2.gif)

You can change the ratio of the inner to the outer radius using the `#define`'d value; but make sure that the view placement radius is adjusted correctly. It isn't something you can change dynamically because I haven't found a quantitative relationship between the two. So if you change `INNER_PROPORTION`, make sure to play around with `VIEW_RADIUS_PLACEMENT_PROPORTION` such that the segment views are centred within the drawn segments. Just as the radius placement proportion is the ratio of the radius of the view placement to the radius of the outer circle, `VIEW_SCALING_FACTOR` is the ratio of the *size* of the views to the radius of the outer circle. This value seems to work for most of the use cases I've encountered.




