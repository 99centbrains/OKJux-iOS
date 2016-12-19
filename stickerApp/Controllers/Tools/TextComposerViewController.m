//
//  TextComposerViewController.m
//  catwang
//
//  Created by 99centbrains on 12/5/13.
//
//

#import "TextComposerViewController.h"
#import "KSLabel.h"

@interface TextComposerViewController ()<UITextFieldDelegate, UIBarPositioningDelegate, UIToolbarDelegate, UIPickerViewDelegate, UIPickerViewDataSource>{

    IBOutlet UITextField *ibo_displayLabel;

    IBOutlet UIView *ibo_renderView;
    IBOutlet UIToolbar *ibo_navbar;
    
    UIPickerView *pickerView;
    NSMutableArray *fontsPackage;
  
    int i_fontSize;
    UIFont *labelFont;
    
    NSString *fontName;
    KSLabel *fancyLabel;
    
    IBOutlet UIScrollView *palletView;
}

@end

@implementation TextComposerViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    i_fontSize = 72;
    
    ibo_renderView.layer.shouldRasterize = YES;
    ibo_renderView.layer.rasterizationScale = 2;
    
    fontsPackage =  [[NSMutableArray alloc] initWithObjects:
                     @"Arial Rounded MT Bold",
                     @"ROCKY AOE",
                     @"Arfmoochikncheez",
                     @"BubbleGum",
                     @"The Skinny",
                     @"Grind Zero",
                     @"Cooper Black",
                     @"Soup of Justice",
                     @"Double Feature",
                     @"MineCrafter 3",
                     nil];
    
    fontName = @"Cooper Black";
    
    labelFont = [UIFont fontWithName:fontName size:i_fontSize];
    ibo_displayLabel.font = labelFont;
    ibo_displayLabel.delegate = self;
}

- (void) viewDidAppear:(BOOL)animated {
    [self iba_chooseColor];
    
    fancyLabel = [[KSLabel alloc] initWithFrame:ibo_displayLabel.frame];
    fancyLabel.text = ibo_displayLabel.text;
    fancyLabel.font = labelFont;
    fancyLabel.adjustsFontSizeToFitWidth = YES;
    fancyLabel.textAlignment = NSTextAlignmentCenter;
    fancyLabel.numberOfLines = 1;
    [fancyLabel setMinimumScaleFactor:5/[UIFont labelFontSize]];
    [fancyLabel setDrawOutline:YES];
    [fancyLabel setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"i_gradient_1.png"]]];
    [fancyLabel setOutlineColor:[UIColor blackColor]];
    [fancyLabel setDrawGradient:NO];
    [ibo_renderView addSubview:fancyLabel];

    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(pickerView.frame.origin.x,
                                                                pickerView.frame.origin.y,
                                                                pickerView.frame.size.width,
                                                                pickerView.frame.size.height)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    [ibo_displayLabel becomeFirstResponder];
}


- (IBAction)iba_showKeyboard:(id)sender{
    if (![ibo_displayLabel isFirstResponder]){
        [ibo_displayLabel becomeFirstResponder];
    }
}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [fontsPackage count];
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [fontsPackage objectAtIndex:row];
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Let's print in the console what the user had chosen;
    fontName = [fontsPackage objectAtIndex:row];
    
    labelFont = [UIFont fontWithName:fontName size:i_fontSize];
    fancyLabel.font = labelFont;
    NSLog(@"Your Selected item: %@", [fontsPackage objectAtIndex:row]);
}

- (void)iba_chooseColor {
    NSMutableArray *colorPallet = [[NSMutableArray alloc] init];
    for (int i = 1; i<=6; i++){
        NSString *colorName = [NSString stringWithFormat:@"i_gradient_%d.png" , i];
        [colorPallet addObject:colorName];
    }
    
    for (int i = 1; i<=11; i++){
        NSString *colorName = [NSString stringWithFormat:@"i_pattern_%d.png" , i];
        [colorPallet addObject:colorName];
    }
    
    for (int i = 1; i<=28; i++){
        NSString *colorName = [NSString stringWithFormat:@"i_swatch_%d.png" , i];
        [colorPallet addObject:colorName];
    }
  
    int i = 0;
    for (NSString * color in colorPallet){
        UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(
                                                                          5 + (palletView.frame.size.height + 5) * i,
                                                                          0,
                                                                          palletView.frame.size.height,
                                                                          palletView.frame.size.height)];
      
        UIColor *bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:color]];
        tempButton.backgroundColor = bgColor;
        
        tempButton.layer.cornerRadius = palletView.frame.size.height/2; // this value vary as per your desire
        tempButton.clipsToBounds = YES;
        tempButton.layer.borderWidth = 2;
        tempButton.layer.borderColor = [UIColor blackColor].CGColor;
        
        [tempButton setBackgroundImage:[UIImage imageNamed:color] forState:UIControlStateNormal];
        [tempButton addTarget:self
                       action:@selector(chooseColor:)
             forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
      
        [palletView addSubview:tempButton];
        tempButton = nil;
        i++;
    }
    
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in palletView.subviews) {
        scrollViewHeight += view.frame.size.height;
    }
    scrollViewHeight += [colorPallet count] * 5;
    [palletView setContentSize:(CGSizeMake(scrollViewHeight+10, palletView.frame.size.height))];
}

- (void) chooseColor:(UIButton *)sender {
    fancyLabel.textColor = sender.backgroundColor;
}

- (IBAction)iba_textComposerDone:(id)sender {
    [self.delegate textComposerDidFinish:self withTextGraphic:[self imageWithImage:[self render]]];

}

- (UIImage *)render {
    ibo_displayLabel.hidden = YES;
    UIGraphicsBeginImageContextWithOptions(ibo_renderView.bounds.size, NO, 8);
    [ibo_renderView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"crop image h: %f", image.size.height);
    NSLog(@"crop image w: %f", image.size.width);
    
    return image;
}

- (UIImage *)imageWithImage:(UIImage *)image {
    float w = ibo_renderView.bounds.size.width *  4;
    float h = ibo_renderView.bounds.size.height *  4;
    
    CGRect bounds = CGRectMake(0.0, 0.0, w, h);
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 1);
    
    [image drawInRect:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    NSLog(@"Image Size %@", NSStringFromCGSize(newImage.size));
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)iba_textComposerCancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^(void){
        [ibo_displayLabel resignFirstResponder];
    }];
}

- (IBAction) iba_textViewSizeUp:(UISlider *)sender {
    i_fontSize = [sender value];
    labelFont = [UIFont fontWithName:fontName size:i_fontSize];
    fancyLabel.font = labelFont;
}

- (IBAction)iba_doneWithText:(id)sender {
    NSLog(@"Done");
    [ibo_displayLabel resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"Begin Editing");
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"End Editing");
}

- (IBAction)textDidChange:(UITextField *)textField{
    NSLog(@"Text Changed");
    fancyLabel.text = textField.text;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"TextChange");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    fancyLabel.text = textField.text;
    [ibo_displayLabel resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [ibo_displayLabel resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

@end
