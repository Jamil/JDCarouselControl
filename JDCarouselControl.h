#import <UIKit/UIKit.h>

typedef enum segmentType {
    ImageType, TextType
} SegmentType;

@interface JDCarouselControl : UIControl

@property (nonatomic) float radius;
@property (nonatomic, readonly) NSInteger numberOfSegments;
@property (nonatomic, readonly) NSInteger selectedSegmentIndex;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *color;

- (void)insertSegments:(NSArray *)segments;
- (void)insertSegmentWithTitle:(NSString *)title;
- (void)insertSegmentWithImage:(UIImage *)image;
- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment;
- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment;
- (void)removeSegmentAtIndex:(NSUInteger)index;

@end
