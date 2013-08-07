#import <UIKit/UIKit.h>
#import "JDCarouselControl.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (weak, nonatomic) IBOutlet JDCarouselControl *carousel;

@property (strong, nonatomic) NSArray *elementsToInsert;
@property (strong, nonatomic) NSArray *titlesArray;

@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (weak, nonatomic) IBOutlet UIButton *disableButton;

- (IBAction)removeAll:(id)sender;
- (IBAction)stepperValueChanged:(id)sender;
- (IBAction)carouselValueChanged:(id)sender;
- (IBAction)disableButtonPress:(id)sender;

@end
