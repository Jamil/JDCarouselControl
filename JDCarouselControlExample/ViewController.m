#import "ViewController.h"

#define BLUE_ULTRALIGHT colorWithRed:0.58 green:0.659 blue:0.702
#define BLUE_DARK colorWithRed:0.165 green:0.275 blue:0.357

@interface ViewController ()

@property (nonatomic) NSInteger prevSegmentIndex;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.prevSegmentIndex = 0;
    self.elementsToInsert = @[[UIImage imageNamed:@"CloudIcon"], @"Foo", [UIImage imageNamed:@"EyeIcon"], @"Bar", [UIImage imageNamed:@"DropIcon"], @"Baz"];
    self.titlesArray = @[@"cloud", @"foo", @"eye", @"bar", @"rain", @"baz"];
}

-(void)viewDidAppear:(BOOL)animated {
    [self setupCarousel];
}

-(void)setupCarousel {
    self.carousel.color = [UIColor BLUE_DARK alpha:1.0];
    self.carousel.textColor = [UIColor BLUE_ULTRALIGHT alpha:1.0];
    self.stepper.value++;
    [self stepperValueChanged:self.stepper];
}

- (IBAction)removeAll:(id)sender {
    while (self.carousel.numberOfSegments)
        [self.carousel removeSegmentAtIndex:(self.carousel.numberOfSegments - 1)];
    self.stepper.value = 0;
}

- (IBAction)stepperValueChanged:(id)sender {
    if (self.stepper.value > self.prevSegmentIndex) {
        int indexToInsert = ((int)self.stepper.value - 1) % (int)[self.elementsToInsert count];
        if ([[self.elementsToInsert objectAtIndex:indexToInsert] isKindOfClass:[NSString class]]) {
            [self.carousel insertSegmentWithTitle:[self.elementsToInsert objectAtIndex:indexToInsert]];
        }
        else if ([[self.elementsToInsert objectAtIndex:indexToInsert] isKindOfClass:[UIImage class]]) {
            [self.carousel insertSegmentWithImage:[self.elementsToInsert objectAtIndex:indexToInsert]];
        }
    }
    else if (self.stepper.value < self.prevSegmentIndex) {
        [self.carousel removeSegmentAtIndex:(self.carousel.numberOfSegments-1)];
    }
    self.prevSegmentIndex = self.stepper.value;
}

- (IBAction)carouselValueChanged:(id)sender {
    self.displayLabel.text = [self.titlesArray objectAtIndex:(self.carousel.selectedSegmentIndex % self.titlesArray.count)];
}

- (IBAction)disableButtonPress:(id)sender {
    self.carousel.enabled = !self.carousel.enabled;
    [self.disableButton setTitle:(self.carousel.enabled ? @"Disable" : @"Enable") forState:UIControlStateNormal];
    [self.disableButton setTitle:(self.carousel.enabled ? @"Disable" : @"Enable") forState:UIControlStateHighlighted];
    [self.disableButton setTitle:(self.carousel.enabled ? @"Disable" : @"Enable") forState:UIControlStateSelected];
}

@end
