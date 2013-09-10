#import "JDCarouselControl.h"

#define INNER_PROPORTION 0.6
#define VIEW_RADIUS_PLACEMENT_PROPORTION 0.8
#define VIEW_SCALING_FACTOR 0.3

#define DISABLED_ALPHA 0.5

@interface JDCarouselControl ()

typedef struct margins {
    CGFloat hMargin;
    CGFloat vMargin;
} Margins;

@property (nonatomic) NSMutableArray *items;

@property (nonatomic) CGFloat diameter;
@property (nonatomic) Margins margins;

@property (nonatomic) CGFloat innerRadius;
@property (nonatomic) CGFloat innerDiameter;
@property (nonatomic) Margins innerMargins;

@property (nonatomic) float arcLength;

@property (nonatomic) int prevNumberOfIndices;

@property (nonatomic, readwrite) NSInteger numberOfSegments;
@property (nonatomic, readwrite) NSInteger selectedSegmentIndex;
@property (nonatomic, readwrite) NSInteger previousIndex;

@property (nonatomic) NSMutableSet *indicesToFillImagesAt;

@end

@implementation JDCarouselControl

#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialSetup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initialSetup];
    }
    return self;
}

-(void)_initialSetup {
    self.selectedSegmentIndex = 0;
    self.color = self.tintColor;            // default color set to tintColor
    self.textColor = [UIColor blackColor];  // default selected text color is black
    self.backgroundColor = [UIColor clearColor];
    self.indicesToFillImagesAt = [[NSMutableSet alloc] initWithCapacity:2];
}

- (void)drawRect:(CGRect)rect
{
    // Update the dimensions so we know exactly what to draw
    [self _updateDimensions];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Define the CGRects for inner & outer circles
    CGRect outerCircleRect = CGRectMake(self.margins.hMargin, self.margins.vMargin, self.diameter, self.diameter);
    CGRect innerCircleRect = CGRectMake(self.innerMargins.hMargin, self.innerMargins.vMargin, self.innerDiameter, self.innerDiameter);
    
    // Just the stroke, for the outer circle
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextStrokeEllipseInRect(context, outerCircleRect);
    // And now the inner
    CGContextStrokeEllipseInRect(context, innerCircleRect);
    
    // And the arcs
    [self _drawSegments];
}

-(void)_drawSegments {
    CGPoint centerd = {self.frame.size.width/2, self.frame.size.height/2};
    
    if (self.numberOfSegments < 1) {
        // don't draw any radial lines
        return;
    }
    
    // We'll start from the conventional 0º and head ccw
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Stroke Paths
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    for (int i = 0; i < self.numberOfSegments; i++) {
        CGContextMoveToPoint(context, centerd.x, centerd.y);
        CGContextMoveToPoint(context, centerd.x + cos(i*self.arcLength)*self.innerRadius, centerd.y + sin(i*self.arcLength)*self.innerRadius);
        CGContextAddLineToPoint(context, centerd.x + cos(i*self.arcLength)*self.radius, centerd.y + sin(i*self.arcLength)*self.radius);
    }
    CGContextStrokePath(context);
    
    // Fill selected segment index
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, centerd.x + cos(self.selectedSegmentIndex*self.arcLength)*self.innerRadius, centerd.y + sin(self.selectedSegmentIndex*self.arcLength)*self.innerRadius);
    
    CGContextAddLineToPoint(context, centerd.x + cos(self.selectedSegmentIndex*self.arcLength)*self.radius, centerd.y + sin(self.selectedSegmentIndex*self.arcLength)*self.radius);
    CGContextAddArc(context, centerd.x, centerd.y, self.radius, self.arcLength*self.selectedSegmentIndex, self.arcLength*(self.selectedSegmentIndex + 1), 0);
    CGContextAddLineToPoint(context, centerd.x + cos((self.selectedSegmentIndex + 1)*self.arcLength)*self.innerRadius, centerd.y + sin((self.selectedSegmentIndex + 1)*self.arcLength)*self.innerRadius);
    CGContextAddArc(context, centerd.x, centerd.y, self.innerRadius, self.arcLength*(self.selectedSegmentIndex + 1), self.arcLength*self.selectedSegmentIndex, 1);
    
    CGContextSetFillColorWithColor(context, (self.enabled ? self.color.CGColor : [self.color colorWithAlphaComponent:DISABLED_ALPHA].CGColor));
    CGContextFillPath(context);
}

-(void)setNeedsLayout {
    if (self.prevNumberOfIndices != self.numberOfSegments) {
        [self setNeedsDisplay];
        [self _updateDimensions];
        [self _layoutSegments];
    }
    self.prevNumberOfIndices = self.numberOfSegments;
}

-(void)setRadius:(CGFloat)radius {
    if (!(radius > self.frame.size.width/2 || radius > self.frame.size.height/2)) {
        _radius = radius;
        self.diameter = radius*2;
    }
}

-(void)setInnerRadius:(CGFloat)innerRadius {
    if (self.innerRadius >= self.radius)
        return;
    
    _innerRadius = innerRadius;
    self.innerDiameter = innerRadius*2;
}

// Segment inserting -- always calls a common private method _insertSegment

- (void)insertSegments:(NSArray *)segments {
    for (id item in segments) {
        [self _insertSegment:item atIndex:self.numberOfSegments];
    }
}

- (void)insertSegmentWithTitle:(NSString *)title {
    [self _insertSegment:title atIndex:self.numberOfSegments];
}

- (void)insertSegmentWithImage:(UIImage *)image
{
    [self _insertSegment:image atIndex:self.numberOfSegments];
}

-(void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment {
    [self _insertSegment:title atIndex:segment];
}

- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment
{
    [self _insertSegment:image atIndex:segment];
}

-(void)removeSegmentAtIndex:(NSUInteger)index {
    if (index >= [self.items count]) return;
    
    [[self.items objectAtIndex:index] removeFromSuperview];
    [self.items removeObjectAtIndex:index];
    
    [self setNeedsLayout];
}

-(int)numberOfSegments {
    return [_items count];
}

#pragma mark Touch Handling

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self sendActionsForControlEvents:UIControlEventTouchDown];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    NSInteger tappedIndex = [self _tappedSegmentIndex:location];
    if (tappedIndex != -1) {
        // Handle Select
        
        [self setNeedsDisplay];
        self.previousIndex = self.selectedSegmentIndex;
        
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        if (tappedIndex != self.selectedSegmentIndex) {
            [self.indicesToFillImagesAt addObject:[NSNumber numberWithInt:tappedIndex]];
            [self.indicesToFillImagesAt addObject:[NSNumber numberWithInt:self.previousIndex]];
            self.selectedSegmentIndex = tappedIndex;
            [self _updateLabelColors];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

-(NSInteger)_tappedSegmentIndex:(CGPoint)tapLocation {
    /* In order to determine the tapped segment index, we'll have to use a polar co-ordinate system – first determine the distance between the tapped location and the center (r), and then the angle of that point from 0º (theta). We can then do the following tests:
     1. Is r between innerRadius and radius?
     If it is, we know it's a valid touch and HAS to be mapped to a segment index. Proceed to (2)
     If it isn't, we know it is not a valid touch and CANNOT be mapped to a segment index (return -1)
     2. Divide the theta value by the arc length of the individual segments, cast it to an integer. This will be the segment index tapped.
     But how do we get the r and theta values? It should be a simple conversion, but we need to find the rectangular co-ordinates with respect to the center first.
     x is (center.x - tapLocation.x)
     y is (center.y - tapLocation.y)
     Now use Py. to find r, and theta is simply atan(y/x)
     */
    
    CGPoint centerd = {self.frame.size.width/2, self.frame.size.height/2};
    
    float x = tapLocation.x - centerd.x;
    float y = tapLocation.y - centerd.y;
    
    float R = sqrtf(x*x + y*y);
    float thetaR = atanf(y/x); // This is the 'raw theta'; it's positive in Q2 and Q4 and negative in Q1 and Q3. It's not an absolute angle relative to 0 (CLOCKWISE)
    float theta;
    
    if (x >= 0 && y < 0) // Q1
        theta = 2*M_PI + thetaR;
    else if (x >= 0 && y >= 0) // Q4
        theta = thetaR;
    else if (x < 0 && y < 0) // Q2
        theta = M_PI + thetaR;
    else if (x < 0 && y >= 0) // Q3
        theta = M_PI + thetaR;
    else return -1;
    
    if (R > self.radius || R < self.innerRadius)
        return -1;
    
    return (int)(theta/self.arcLength);
}

#pragma mark View

-(void)_updateDimensions {
    // First deal with the larger circle
    self.radius = ((self.frame.size.width < self.frame.size.height) ? self.frame.size.width/2.2 : self.frame.size.height/2.2);
    CGFloat vMargins = self.frame.size.height - self.diameter;
    CGFloat hMargins = self.frame.size.width - self.diameter;
    Margins margins = {hMargins/2, vMargins/2};
    self.margins = margins;
    
    // Now we'll define the dimensions of the smaller circle with respect to the bounds
    self.innerRadius = self.radius * INNER_PROPORTION;
    CGFloat vMarginsInner = self.frame.size.height - self.innerDiameter;
    CGFloat hMarginsInner = self.frame.size.width - self.innerDiameter;
    Margins innerMargins = {hMarginsInner/2, vMarginsInner/2};
    self.innerMargins = innerMargins;
    
    // Now we'll deal with getting the angles of the segments
    self.arcLength = (self.numberOfSegments ? (2*M_PI / self.numberOfSegments) : 2*M_PI);
}

-(void)_layoutSegments {
    /* The challenge here is placing each view such that it's within and centred within each circular segment. We'll do this by applying the following 'transformation' starting from the point (center.x + radius*cos(arcLength), center.y + radius*sin(arcLength)) – the end point of each radial line drawn in drawRect
     1. Translate arcLength/2 clockwise (in polar co-ordinates, on the theta-axis)
     2. Scale radius by VIEW_RADIUS_PLACEMENT_PROPORTION (in polar co-ordinates, on the r-axis)
     */
    
    CGPoint centerd = {self.frame.size.width/2, self.frame.size.height/2};
    
    const float size_x = self.radius*VIEW_SCALING_FACTOR;
    const float size_y = self.radius*VIEW_SCALING_FACTOR;
    const float scalingFactor = VIEW_RADIUS_PLACEMENT_PROPORTION;
    
    for (int i = 0; i < self.numberOfSegments; i++) {
        [[self.items objectAtIndex:i] setFrame:CGRectMake(centerd.x + cos(i*self.arcLength + self.arcLength/2)*self.radius*scalingFactor - size_x/2, centerd.y + sin(i*self.arcLength + self.arcLength/2)*self.radius*scalingFactor - size_y/2, size_x, size_y)];
        [self _updateLabelColors];
    }
}

-(void)_updateLabelColors {
    for (int i = 0; i < self.numberOfSegments; i++) {
        if ([[[self.items objectAtIndex:i] viewWithTag:1] isKindOfClass:[UILabel class]]) {
            UILabel *textLabel = (UILabel*)[[self.items objectAtIndex:i] viewWithTag:1];
            if (i == self.selectedSegmentIndex) {
                textLabel.textColor = self.textColor;
            }
            else {
                textLabel.textColor = self.color;
            }
        }
        else if ([[[self.items objectAtIndex:i] viewWithTag:1] isKindOfClass:[UIImageView class]]) {
            // Check to see if we need to reload this image, otherwise skip over it
            if ([self.indicesToFillImagesAt member:[NSNumber numberWithInt:i]]) {
                UIImageView *imgView = (UIImageView*)[[self.items objectAtIndex:i] viewWithTag:1];
                if (i == self.selectedSegmentIndex) {
                    imgView.image = [self _fillImage:imgView.image withColor:self.textColor];
                }
                else {
                    imgView.image = [self _fillImage:imgView.image withColor:self.color];
                }
            }
        }
    }
    
    [self.indicesToFillImagesAt removeAllObjects];
}

-(void)_insertSegment:(id)content atIndex:(NSUInteger)index {
    if (!_items) _items = [[NSMutableArray alloc] init];
    
    UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    item.userInteractionEnabled = NO;
    
    if ([content isKindOfClass:[NSString class]]) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.radius*VIEW_SCALING_FACTOR,self.radius*VIEW_SCALING_FACTOR)];
        label.text = content;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = self.color;
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.1f;
        label.tag = 1;
        [item addSubview:label];
    }
    else if ([content isKindOfClass:[UIImage class]]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.radius*VIEW_SCALING_FACTOR,self.radius*VIEW_SCALING_FACTOR)];
        imageView.image = [self _fillImage:content withColor:self.color];
        imageView.tag = 1;
        [item addSubview:imageView];
    }
    
    [self addSubview:item];
    
    if (index >= self.items.count) [self.items addObject:item];
    else [self.items insertObject:item atIndex:index];
    
    [self.indicesToFillImagesAt addObject:[NSNumber numberWithInt:index]];
    
    [self setNeedsLayout];
}

-(UIImage *)_fillImage:(UIImage *)mask withColor:(UIColor *)color {
    CGImageRef maskImage = mask.CGImage;
    CGFloat width = mask.size.width;
    CGFloat height = mask.size.height;
    CGRect bounds = CGRectMake(0,0,width,height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGContextClipToMask(bitmapContext, bounds, maskImage);
    CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
    CGContextFillRect(bitmapContext, bounds);
    
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    
    UIImage *result = [UIImage imageWithCGImage:mainViewContentBitmapContext];
    return result;
}

@end
